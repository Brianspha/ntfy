import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:ntfy/database/cache_db.dart';
import 'package:ntfy/models/nft_metadata.dart';
import 'package:ntfy/models/skynetUpload.dart';
import 'package:ntfy/pages/minted_nft_view_page.dart';
import 'package:ntfy/scoped_models/app_store.dart';
import 'package:ntfy/service_locator.dart';
import 'package:ntfy/ui/shared/app_colors.dart';
import 'package:lipsum/lipsum.dart' as lipsum;
import 'package:ntfy/utils/nft_functions.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:web3dart/web3dart.dart';

class MintedNFTsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MintedNFTsPageState();
  }
}

class MintedNFTsPageState extends State<MintedNFTsPage> {
  List<NFTMetaData> images = [];
  var isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    getMinted().then((value) => {
          setState(() {
            this.images = value;
            this.isLoading = false;
          })
        });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        backgroundColor: AppColors.primaryColor,
        body: ScopedModelDescendant<AppStore>(
            builder: (BuildContext context, Widget child, AppStore model) {
          return LoadingOverlay(
              isLoading: isLoading,
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SizedBox(
                      height: 40,
                    ),
                    Text(
                      'Minted NFTs',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 30,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: images.length > 0
                            ? GridView.builder(
                                physics: ScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                                itemBuilder: (context, index) {
                                  return RawMaterialButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              MintedNFTViewPage(
                                                  nftData: images[index],
                                                  index: index),
                                        ),
                                      );
                                    },
                                    child: Hero(
                                      tag: 'logo$index',
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          image: DecorationImage(
                                            image: NetworkImage(
                                                images[index].signature_url),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                itemCount: images.length,
                              )
                            : Center(
                                child: FittedBox(
                                    child: Text(
                                  "No NFTs minted",
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.black),
                                )),
                              ),
                      ),
                    )
                  ],
                ),
              ));
        }));
  }

  Future<List<NFTMetaData>> getMinted() async {
    var dio = Dio();
    var nfts = new List<NFTMetaData>();
    var user = await locator.get<CacheDB>().getDefaultSettings();
    if (user.private_key != null &&
        user.private_key != "NULL" &&
        user.token_address != null &&
        user.token_address != "NULL" &&
        user.network_url != null &&
        user.network_url != "NULL") {
      var totalSupply =
          await locator.get<NFTFunctions>().query("totalSupply", []);
      var credentials = EthPrivateKey.fromHex(user.private_key);
      var userAddress = await credentials.extractAddress();
      if (totalSupply.length > 0) {
        var length = totalSupply[0].toInt();
        for (var i = 0; i < length; i += 1) {
          var exists = await locator
              .get<NFTFunctions>()
              .query("tokenExists", [new BigInt.from(i + 1)]);
          if (exists[0]) {
            var ownedByUser = await locator
                .get<NFTFunctions>()
                .query("ownerOf", [new BigInt.from(i + 1)]);
            //   print("ownedByUser: $ownedByUser");
            var uri = await locator
                .get<NFTFunctions>()
                .query("tokenURI", [new BigInt.from(i + 1)]);
            //    print("uri: $uri");
            var data = await dio.get(uri[0]);
            data.data = json.decode(data.data);
            //    print("converted data: ${data.data}");
            var nftData = new NFTMetaData(
                signature_url: data.data["signature_url"],
                description: data.data["description"],
                nft_name: data.data["nft_name"],
                time_stamp: data.data["time_stamp"]);
            //    print("found nft data: $nftData");
            if (ownedByUser[0].toString().toLowerCase() ==
                userAddress.hex.toLowerCase()) {
              nftData.owned = true;
            } else {
              nftData.owned = false;
            }
            nfts.add(nftData);
          }
        }
      }
    }

    return Future.value(nfts);
  }
}

import 'package:loading_overlay/loading_overlay.dart';
import 'package:ntfy/database/cache_db.dart';
import 'package:ntfy/service_locator.dart';
import 'package:ntfy/ui/shared/app_colors.dart';
import 'package:ntfy/utils/nft_functions.dart';

import 'package:web3dart/web3dart.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ntfy/models/nft_metadata.dart';
import 'package:ntfy/models/skynetUpload.dart';

class MintedNFTViewPage extends StatefulWidget {
  final NFTMetaData nftData;
  final int index;
  MintedNFTViewPage({@required this.nftData, @required this.index});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MintedNFTViewPageState(this.nftData, this.index);
  }
}

class MintedNFTViewPageState extends State<MintedNFTViewPage> {
  final NFTMetaData nftData;
  final int index;
  bool isLoading = false;
  MintedNFTViewPageState(this.nftData, this.index);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SafeArea(
      child: Scaffold(
        body: LoadingOverlay(
          isLoading: isLoading,
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width,
                  minHeight: MediaQuery.of(context).size.height),
              child: IntrinsicHeight(
                  child: Column(
                children: <Widget>[
                  Expanded(
                    child: Hero(
                      tag: index,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(30)),
                          image: DecorationImage(
                            image: NetworkImage(nftData.signature_url),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 340,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("NFT Name",
                                  style: TextStyle(
                                    color: Colors.lightBlueAccent,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                  )),
                              Text(
                                nftData.nft_name,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text("Description",
                                  style: TextStyle(
                                    color: Colors.lightBlueAccent,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                  )),
                              Text(nftData.description,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  )),
                              SizedBox(
                                height: 5,
                              ),
                              Text("Time Stamp",
                                  style: TextStyle(
                                    color: Colors.lightBlueAccent,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                  )),
                              Text(
                                  new DateTime.fromMillisecondsSinceEpoch(
                                          nftData.time_stamp)
                                      .toString(),
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  )),
                            ],
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: FlatButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                padding: EdgeInsets.symmetric(vertical: 15),
                                color: Colors.lightBlueAccent,
                                child: Center(
                                  child: FittedBox(
                                    child: Text(
                                      'Back',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            if (nftData.owned)
                              Expanded(
                                child: FlatButton(
                                  onPressed: () async {
                                    setState(() {
                                      this.isLoading = true;
                                    });
                                    var userSettings = await locator
                                        .get<CacheDB>()
                                        .getDefaultSettings();
                                    var credentials =
                                        await EthPrivateKey.fromHex(
                                                userSettings.private_key)
                                            .extractAddress();
                                    var results = await locator
                                        .get<NFTFunctions>()
                                        .submit("burnToken",
                                            [new BigInt.from(index + 1)]);
                                    if (results.isNotEmpty) {
                                      showSnackBar(context,
                                          "Successfully burnt token with transaction hash $results");
                                      Navigator.of(context).pop();
                                    } else {
                                      showSnackBar(context,
                                          "Something went wrong whilst burning token with error $results");
                                    }
                                    setState(() {
                                      this.isLoading = false;
                                    });
                                  },
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                  color: Colors.lightBlueAccent,
                                  child: Center(
                                    child: FittedBox(
                                      child: Text(
                                        'Burn',
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              )),
            ),
          ),
        ),
      ),
    );
  }
}

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar(
    BuildContext parentContext, String message) {
  return ScaffoldMessenger.of(parentContext).showSnackBar(SnackBar(
    backgroundColor: AppColors.primaryColor,
    content: Text(message, style: TextStyle(color: Colors.white, fontSize: 16)),
  ));
}

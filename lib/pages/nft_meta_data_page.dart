import 'dart:math';
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:ntfy/database/cache_db.dart';
import 'package:ntfy/scoped_models/app_store.dart';
import 'package:ntfy/service_locator.dart';
import 'package:ntfy/ui/shared/app_colors.dart';
import 'package:ntfy/utils/nft_functions.dart';
import 'package:ntfy/utils/skynet_functions.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:web3dart/web3dart.dart';

class NFTMetaDataPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return NFTMetaDataPageState();
  }
}

class NFTMetaDataPageState extends State<NFTMetaDataPage> {
  var isLoading = false;
  final titleControler = TextEditingController();
  final descriptionControler = TextEditingController();
  var valid = true, validDescription = true;
  @override
  void dispose() {
    titleControler.dispose();
    descriptionControler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(body: ScopedModelDescendant<AppStore>(
        builder: (BuildContext context, Widget child, AppStore model) {
      return LoadingOverlay(
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
                    tag: 'logo${new Random(100123123123123123).nextInt(123)}',
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30)),
                        image: DecorationImage(
                          image: MemoryImage(model.getSelectedImage()),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "NFT Name",
                        style: TextStyle(
                          color: Colors.lightBlueAccent,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextField(
                        style: TextStyle(color: Colors.black),
                        controller: this.titleControler,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                            borderSide: BorderSide(
                                width: 1, color: AppColors.primaryColor),
                          ),
                          hintText: 'Name for the NFT',
                          errorText: valid ? null : 'NFT Name required',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      Text(
                        "NFT Description",
                        style: TextStyle(
                          color: Colors.lightBlueAccent,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextField(
                        style: TextStyle(color: Colors.black),
                        maxLines: 5,
                        controller: this.descriptionControler,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                            borderSide: BorderSide(
                                width: 1, color: AppColors.primaryColor),
                          ),
                          hintText: 'Description for the NFT',
                          errorText: validDescription
                              ? null
                              : 'NFT description required',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
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
                          Expanded(
                            child: FlatButton(
                              onPressed: () async {
                                setState(() {
                                  valid = titleControler.text.isNotEmpty;
                                  validDescription =
                                      descriptionControler.text.isNotEmpty;
                                });

                                var userSettings = await locator
                                    .get<CacheDB>()
                                    .getDefaultSettings();
                                setState(() {
                                  this.isLoading = true;
                                });
                                if (validDescription &&
                                    valid &&
                                    (userSettings != null &&
                                        userSettings.network_url.isNotEmpty) &&
                                    (userSettings != null &&
                                        userSettings.private_key.isNotEmpty) &&
                                    (userSettings != null &&
                                        userSettings.token_address.isNotEmpty)) {
                                  var skyLink = await locator
                                      .get<SkynetFunctions>()
                                      .uploadFile(
                                      model.getImagePath,
                                      titleControler.text,
                                      descriptionControler.text);
                                  print("skyLink upload: $skyLink");
                                  locator
                                      .get<NFTFunctions>()
                                      .loadContract()
                                      .then((value) async {
                                    var credentials = await EthPrivateKey.fromHex(
                                        userSettings.private_key)
                                        .extractAddress();
                                    var results = await locator
                                        .get<NFTFunctions>()
                                        .submit("mintToken", [
                                      EthereumAddress.fromHex(credentials.hex),
                                      "https://siasky.net/$skyLink"
                                    ]);
                                    print(
                                        "results of submitting NFT data: $results");
                                    setState(() {
                                      this.isLoading = false;
                                    });
                                    showSnackBar(context,
                                        "Successfully minted new NFT with transaction receipt of $results");
                                  });
                                } else {
                                  this.isLoading = false;
                                  showSnackBar(context,
                                      "Unable to mint NFT, please ensure you have set the default token address, account and the network url");
                                }
                              },
                              padding: EdgeInsets.symmetric(vertical: 15),
                              color: Colors.lightBlueAccent,
                              child: Center(
                                  child: FittedBox(
                                      child: Text(
                                        'MINT',
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ))),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              ],
            )),
          ),
        ),
        isLoading: isLoading,
      );
    })));
  }
}

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar(
    BuildContext parentContext, String message) {
  return ScaffoldMessenger.of(parentContext).showSnackBar(SnackBar(
    backgroundColor: AppColors.primaryColor,
    content: Text(message, style: TextStyle(color: Colors.white, fontSize: 16)),
  ));
}

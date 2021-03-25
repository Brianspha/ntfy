import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:ntfy/database/cache_db.dart';
import 'package:ntfy/models/token.dart';
import 'package:ntfy/models/user.dart';
import 'package:ntfy/scoped_models/app_store.dart';
import 'package:ntfy/ui/shared/app_colors.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:prompt_dialog/prompt_dialog.dart';
import 'package:scoped_model/scoped_model.dart';

import '../service_locator.dart';

class TokenSettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return TokenSettingsPageState();
  }
}

class TokenSettingsPageState extends State<TokenSettingsPage> {
  List<Token> tokens = new List<Token>();
  var selectedAccount = 0;
  var isLoading = true;
  var tokenAddressController = TextEditingController();
  var valid = true;
  @override
  void initState() {
    getCachedTokens()
        .then((results) => {
              this.tokens = results,
              setState(() {
                this.isLoading = false;
              })
            })
        // ignore: missing_return
        ?.onError((error, stackTrace) {
      setState(() {
        this.isLoading = false;
        this.tokens = [];
      });
    });
    ;
    // TODO: implement initState
    super.initState();
  }

  // set up the AlertDialog

  @override
  Widget build(BuildContext parentContext) {
    User currentSettings = User();

    // TODO: implement build
    return Scaffold(
      body: SafeArea(
        child: ScopedModelDescendant<AppStore>(
            builder: (BuildContext context, Widget child, AppStore model) {
          AlertDialog alert = AlertDialog(
            title: Text("New Token Address",
                style: TextStyle(color: Colors.black, fontSize: 16)),
            content: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 100,
              child: TextField(
                style: TextStyle(color: Colors.black),
                controller: tokenAddressController,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                    borderSide:
                        BorderSide(width: 1, color: AppColors.primaryColor),
                  ),
                  hintText: 'Token Address',
                  errorText: valid ? null : 'Token Address String required',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            actions: [
              FlatButton(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.of(parentContext, rootNavigator: true).pop();
                },
              ),
              FlatButton(
                child: Text("Save"),
                onPressed: () {
                  if (tokenAddressController.text.isEmpty ||
                      tokenAddressController.text.length < 42 ||
                      tokenAddressController.text.length > 42) {
                    setState(() {
                      valid = false;
                    });
                    showSnackBar(parentContext, 0,
                        "Token Address must be 42 characters long");
                  } else {
                    setState(() {
                      valid = true;
                      print("${tokenAddressController.text}");
                      var tokenName = "Test Name"; //@dev to call function
                      setState(() {
                        this.isLoading = true;
                      });
                      print('this.tokens.length: ${this.tokens.length}');
                      if (this.tokens.length == 0) {
                        model.setDefaultTokenAddress(Token(
                            token_address: tokenAddressController.text,
                            token_name: "SampleNFT",
                            isDefault: 0));
                        locator<CacheDB>()
                            .saveToken(Token(
                                token_address: tokenAddressController.text,
                                token_name: "SampleNFT",
                                isDefault: 1))
                            .then((value) {
                          print('results of saving new token ${value.toMap()}');
                          setState(() {
                            this.isLoading = false;
                            tokens.add(Token(
                                token_address: tokenAddressController.text,
                                token_name: "SampleNFT",
                                isDefault: 1));
                          });
                        }).catchError((onError) {
                          print('error saving token $onError');
                          setState(() {
                            this.isLoading = false;
                          });
                        });
                      } else {
                        locator<CacheDB>()
                            .saveToken(Token(
                                token_address: tokenAddressController.text,
                                token_name: "SampleNFT",
                                isDefault: 0))
                            .then((value) {
                          print('results of saving new token $value');
                          setState(() {
                            this.isLoading = false;
                            tokens.add(Token(
                                token_address: tokenAddressController.text,
                                token_name: "SampleNFT",
                                isDefault: 0));
                          });
                        }).catchError((onError) {
                          print('error saving token $onError');
                          setState(() {
                            this.isLoading = false;
                          });
                        });
                      }
                      // ignore: unnecessary_statements
                      //   tokenAddressController = new TextEditingController();
                      showSnackBar(parentContext, 0,
                          "Added new token ${tokenAddressController.text}");
                      Navigator.of(parentContext, rootNavigator: true).pop();
                    });
                  }
                },
              ),
            ],
          );
          return Scaffold(
            resizeToAvoidBottomInset: true,
            body: LoadingOverlay(
                isLoading: isLoading,
                child: SafeArea(
                  child: Hero(
                    tag: new Random(100000012301231).nextInt(123123123),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: Icon(Icons.arrow_back),
                              color: AppColors.primaryColor,
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(50, 0, 50, 0),
                              child: FittedBox(
                                child: Text(
                                  "Token Settings",
                                  style: TextStyle(
                                      color: AppColors.primaryColor,
                                      fontSize: 20),
                                ),
                              ),
                            ),
                            Container(
                              width: 50,
                              height: 50,
                            )
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 10, 10, 10),
                          child: FittedBox(
                            child: Text(
                              "Select Default NFT Token Address or Remove",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 40, 0, 10),
                          child: Container(
                            width: MediaQuery.of(parentContext).size.width,
                            height:
                                MediaQuery.of(parentContext).size.height * 0.5,
                            child: this.tokens.length == 0
                                ? Center(
                                    child: FittedBox(
                                      child: Text(
                                        "No Tokens Found",
                                        style: TextStyle(
                                            color: AppColors.primaryColor,
                                            fontSize: 20),
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: tokens.length,
                                    shrinkWrap: true,
                                    itemBuilder: (parentContext, index) {
                                      return Card(
                                          child: ListTile(
                                              leading: IconButton(
                                                iconSize: 25,
                                                onPressed: () {
                                                  setState(() {
                                                    deleteToken(tokens[index]
                                                            .token_address)
                                                        .then((deleted) {
                                                      if (deleted) {
                                                        model.setDefaultTokenAddress(
                                                            Token(
                                                                token_name:
                                                                    "NULL",
                                                                token_address:
                                                                    "NULL",
                                                                isDefault: 0));
                                                        showSnackBar(
                                                            parentContext,
                                                            index,
                                                            "Deleted token ${tokens[index].token_address}");
                                                      } else {
                                                        showSnackBar(
                                                            parentContext,
                                                            index,
                                                            "Could not delete token ${tokens[index].token_address}");
                                                      }
                                                      tokens.removeAt(index);
                                                      this.isLoading = false;
                                                    }).catchError((onError) {
                                                      print(
                                                          'error deleting token: $onError');
                                                    });
                                                  });
                                                },
                                                icon: Icon(
                                                  Icons.cancel,
                                                  color: AppColors.primaryColor,
                                                ),
                                              ),
                                              trailing: Radio(
                                                value: index,
                                                groupValue:
                                                    this.selectedAccount,
                                                onChanged: (value) {
                                                  setState(() {
                                                    print(
                                                        'selected account: $value');
                                                    this.selectedAccount =
                                                        value;
                                                    tokens[index].isDefault =
                                                        value;
                                                    model
                                                        .setDefaultTokenAddress(
                                                            tokens[index]);
                                                    updateDefaultSettings(model
                                                            .getCurrentUser)
                                                        .then((value) {
                                                      print(
                                                          'Changed default token results: $value');
                                                      showSnackBar(
                                                          parentContext,
                                                          index,
                                                          "Successfully changed default token address to ${tokens[index].token_address}");
                                                    });
                                                  });
                                                },
                                              ),
                                              subtitle: Text(
                                                tokens[index].token_name,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 13),
                                              ),
                                              title: FittedBox(
                                                child: Text(
                                                  tokens[index].token_address,
                                                  style: TextStyle(
                                                      color: AppColors
                                                          .primaryColor,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              )));
                                    },
                                  ),
                          ),
                        ),
                        RawMaterialButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return alert;
                              },
                            );
                          },
                          child: FittedBox(
                            child: Center(
                              child: Text(
                                "Add Token Address",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 16),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                )),
          );
        }),
      ),
    );
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar(
      BuildContext parentContext, int index, String message) {
    return ScaffoldMessenger.of(parentContext).showSnackBar(SnackBar(
      backgroundColor: AppColors.primaryColor,
      content:
          Text(message, style: TextStyle(color: Colors.white, fontSize: 16)),
    ));
  }
}

Future<bool> updateDefaultSettings(User settings) async {
  var results = await locator<CacheDB>().updateDefaultSettings(settings);
  return results;
}

Future<bool> deleteToken(String token_address) async {
  var deleted =
      await Future.value(locator<CacheDB>().deleteToken(token_address));
  return deleted == 1 ? true : false;
}

Future<List<Token>> getCachedTokens() async {
  var tokens = await Future.value(locator<CacheDB>().getTokens());
  tokens.map((e) => print('token: ${e.toString()}'));
  return Future.value(tokens);
}

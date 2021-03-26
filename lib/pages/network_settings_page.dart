import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:ntfy/database/cache_db.dart';
import 'package:ntfy/models/account.dart';
import 'package:ntfy/models/network.dart';
import 'package:ntfy/models/token.dart';
import 'package:ntfy/models/user.dart';
import 'package:ntfy/scoped_models/app_store.dart';
import 'package:ntfy/ui/shared/app_colors.dart';
import 'package:ntfy/utils/constants.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:prompt_dialog/prompt_dialog.dart';
import 'package:scoped_model/scoped_model.dart';

import '../service_locator.dart';

class NetworkSettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return NetworkSettingsPageState();
  }
}

class NetworkSettingsPageState extends State<NetworkSettingsPage> {
  List<Network> networks = new List<Network>();
  var isLoading = true;
  var selectedAccount = 0;
  final networkNameController = TextEditingController();
  final networkURLController = TextEditingController();
  final networkBlockExplorerController = TextEditingController();
  var valid = true;
  @override
  void initState() {
    getCachedNetworks()
        .then((results) => {
              this.networks = results,
              setState(() {
                this.isLoading = false;
              })
            })
        // ignore: missing_return
        ?.onError((error, stackTrace) {
      setState(() {
        this.isLoading = false;
        this.networks = [];
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
                title: Text("New Wallet Address",
                    style: TextStyle(color: Colors.black, fontSize: 16)),
                content: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * .3,
                    child: Column(
                      children: [
                        TextField(
                          style: TextStyle(color: Colors.black),
                          controller: networkNameController,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(4)),
                              borderSide:
                              BorderSide(width: 1, color: AppColors.primaryColor),
                            ),
                            hintText: 'Network Name',
                            errorText: valid ? null : 'Network Name String required',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        TextField(
                          style: TextStyle(color: Colors.black),
                          controller: networkURLController,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(4)),
                              borderSide:
                              BorderSide(width: 1, color: AppColors.primaryColor),
                            ),
                            hintText: 'Network URL ',
                            errorText: valid ? null : 'Network URL  required',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        TextField(
                          style: TextStyle(color: Colors.black),
                          controller: networkBlockExplorerController,
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(4)),
                              borderSide:
                              BorderSide(width: 1, color: AppColors.primaryColor),
                            ),
                            hintText: 'Network Block Explorer URL ',
                            errorText: valid ? null : 'Block Explorer URL required',
                            border: OutlineInputBorder(),
                          ),
                        )
                      ],
                    )),
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
                      var matchNetworkURL = new RegExp(urlPattern, caseSensitive: false)
                          .hasMatch(networkURLController.text);
                      var matchNetworkBlockExplorerURL =
                      new RegExp(urlPattern, caseSensitive: false)
                          .hasMatch(networkBlockExplorerController.text);
                      print(
                          'valid matchNetworkURL: $matchNetworkURL valid matchNetworkBlockExplorerURL: $matchNetworkBlockExplorerURL');
                      if ((networkURLController.text.isEmpty ||
                          networkNameController.text.isEmpty ||
                          networkBlockExplorerController.text.isEmpty) ||
                          (!matchNetworkURL || !matchNetworkBlockExplorerURL) ||
                          (networkNameController.text.length == 0 &&
                              networkNameController.text.length < 6)) {
                        setState(() {
                          valid = false;
                        });
                        showSnackBar(parentContext,
                            "Network URL and Block Explorer must follow the format 'http://url or https://url' and the network name must be atleast 6 characters in length", AppColors.red);
                      } else {
                        setState(() {
                          setState(() {
                            valid = true;
                            this.isLoading = true;
                          });
                          print('this.networks.length: ${this.networks.length}');
                          if (this.networks.length == 0) {
                            model.setDefaultNetworkURL(new Network(
                              network_block_explorer: networkBlockExplorerController.text,
                            network_url: networkURLController.text,
                            network_name: networkNameController.text,
                            isDefault: 1));
                            locator<CacheDB>()
                                .saveNetwork(new Network(
                                network_block_explorer: networkBlockExplorerController.text,
                                network_url: networkURLController.text,
                                network_name: networkNameController.text,
                                isDefault: 1))
                                .then((value) {
                              print('results of saving new account ${value.toMap()}');
                              setState(() {
                                this.isLoading = false;
                                this.networks.add(new Network(
                                    network_block_explorer: networkBlockExplorerController.text,
                                    network_url: networkURLController.text,
                                    network_name: networkNameController.text,
                                    isDefault: 1));
                              });
                              showSnackBar(parentContext,
                                  "Added new Account ${networkNameController.text}",AppColors.primaryColor);
                            }).catchError((onError) {
                              print('error saving account $onError');
                              setState(() {
                                this.isLoading = false;
                              });
                              showSnackBar(parentContext,
                                  "Something went wrong whilst adding new network ${networkNameController.text}",AppColors.primaryColor);
                            });
                          } else {
                            //@dev inconsistent coding will refactor later
                            locator<CacheDB>()
                                .saveNetwork(new Network(
                                network_block_explorer: networkBlockExplorerController.text,
                                network_url: networkURLController.text,
                                network_name: networkNameController.text,
                                isDefault: 0))
                                .then((value) {
                              print('results of saving new account $value');
                              setState(() {
                                this.isLoading = false;
                                this.networks.add(new Network(
                                    network_block_explorer: networkBlockExplorerController.text,
                                    network_url: networkURLController.text,
                                    network_name: networkNameController.text,
                                    isDefault: 0));
                              });
                              showSnackBar(parentContext,
                                  "Added new Network ${networkNameController.text}",AppColors.primaryColor);
                            }).catchError((onError) {
                              print('error saving account $onError');
                              setState(() {
                                this.isLoading = false;
                              });
                              showSnackBar(parentContext,
                                  "Something went wrong whilst adding new account ${networkNameController.text}",AppColors.red);
                            });
                          }
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
                                  "Network Settings",
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
                              "Select Default Network or Remove",
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
                            child: this.networks.length == 0
                                ? Center(
                                    child: FittedBox(
                                      child: Text(
                                        "No Networks Found",
                                        style: TextStyle(
                                            color: AppColors.primaryColor,
                                            fontSize: 20),
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: networks.length,
                                    shrinkWrap: true,
                                    itemBuilder: (parentContext, index) {
                                      return Card(
                                          child: ListTile(
                                              leading: IconButton(
                                                iconSize: 25,
                                                onPressed: () {
                                                  setState(() {
                                                    deleteNetwork(
                                                            networks[index]
                                                                .network_name)
                                                        .then((deleted) {
                                                      if (deleted) {
                                                        model.setDefaultNetworkURL(new Network(
                                                          network_url: "NULL",network_name: "NULL", network_block_explorer: "NULL",isDefault: 0));
                                                        showSnackBar(
                                                            parentContext,
                                                            "Deleted network ${networks[index].network_name}",AppColors.primaryColor);
                                                      } else {
                                                        showSnackBar(
                                                            parentContext,
                                                            "Could not delete network  ${networks[index].network_name}",AppColors.red);
                                                      }
                                                      networks.removeAt(index);
                                                      this.isLoading = false;
                                                    }).catchError((onError) {
                                                      print(
                                                          'error deleting network: $onError');
                                                      showSnackBar(
                                                          parentContext,
                                                          "Could not delete network  ${networks[index].network_name}",AppColors.red);

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
                                                        'selected network: $value');
                                                    this.selectedAccount =
                                                        value;
                                                    networks[index].isDefault =
                                                        value;
                                                    model.setDefaultNetworkURL(
                                                        networks[index]);
                                                    updateDefaultSettings(model
                                                            .getCurrentUser)
                                                        .then((value) {
                                                      print(
                                                          'Changed default account results: $value');
                                                      showSnackBar(
                                                          parentContext,
                                                          "Successfully changed default account address to ${networks[index].network_name}", AppColors.primaryColor);
                                                    });
                                                  });
                                                },
                                              ),
                                              subtitle: Text(
                                                networks[index].network_url,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 13),
                                              ),
                                              title: Text(
                                                networks[index].network_name,
                                                style: TextStyle(
                                                    color:
                                                        AppColors.primaryColor,
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.bold),
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
                                "Add New Network",
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
      BuildContext parentContext,  String message, Color color) {
    return ScaffoldMessenger.of(parentContext).showSnackBar(SnackBar(
      backgroundColor: color,
      content:
          Text(message, style: TextStyle(color: Colors.white, fontSize: 16)),
    ));
  }
}


Future<bool> deleteNetwork(String network_name) async {
  var deleted =
      await Future.value(locator<CacheDB>().deleteNetwork(network_name));
  return deleted == 1 ? true : false;
}

Future<List<Network>> getCachedNetworks() async {
  var networks = await Future.value(locator<CacheDB>().getNetworks());
  networks.map((e) => print('network: ${e.toString()}'));
  return Future.value(networks);
}

Future<bool> updateDefaultSettings(User settings) async {
  var results = await locator<CacheDB>().updateDefaultSettings(settings);
  return results;
}

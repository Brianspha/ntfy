import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:ntfy/database/cache_db.dart';
import 'package:ntfy/models/account.dart';
import 'package:ntfy/models/token.dart';
import 'package:ntfy/models/user.dart';
import 'package:ntfy/scoped_models/app_store.dart';
import 'package:ntfy/ui/shared/app_colors.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:prompt_dialog/prompt_dialog.dart';
import 'package:scoped_model/scoped_model.dart';

import '../service_locator.dart';

class WalletSettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return WalletSettingsPageState();
  }
}

class WalletSettingsPageState extends State<WalletSettingsPage> {
  List<Account> accounts = new List<Account>();
  var isLoading = true;
  var selectedAccount = 0;
  final privateKeyController = TextEditingController();
  final accountNameController = TextEditingController();

  var valid = true;
  @override
  void initState() {
    getCachedAccounts()
        .then((results) => {
              this.accounts = results,
              setState(() {
                this.isLoading = false;
              })
            })
        // ignore: missing_return
        ?.onError((error, stackTrace) {
      setState(() {
        this.isLoading = false;
        this.accounts = [];
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
                      controller: privateKeyController,
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                          borderSide: BorderSide(
                              width: 1, color: AppColors.primaryColor),
                        ),
                        hintText: 'Private Key',
                        errorText: valid ? null : 'Private Key String required',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                    ),
                    TextField(
                      style: TextStyle(color: Colors.black),
                      controller: accountNameController,
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                          borderSide: BorderSide(
                              width: 1, color: AppColors.primaryColor),
                        ),
                        hintText: 'Account Name',
                        errorText: valid ? null : 'Account Name required',
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
                  print(
                      "accountNameController.text.length: ${accountNameController.text.length} accountNameController.text: ${accountNameController.text}");
                  if ((privateKeyController.text.isEmpty ||
                          accountNameController.text.isEmpty) ||
                      (privateKeyController.text.length < 64 &&
                          privateKeyController.text.length > 64) ||
                      (accountNameController.text.length == 0 &&
                          accountNameController.text.length < 6)) {
                    setState(() {
                      valid = false;
                    });
                    showSnackBar(parentContext, 0,
                        "Private Key Address must be 64 characters long as well as the name must contain atleast 6 characters");
                  } else {
                    setState(() {
                      setState(() {
                        valid = true;
                        this.isLoading = true;
                      });
                      print('this.accounts.length: ${this.accounts.length}');
                      if (this.accounts.length == 0) {
                        model.setDefaultAccount(new Account(
                            account_name: accountNameController.text,
                            private_key: privateKeyController.text,
                            isDefault: 1));
                        locator<CacheDB>()
                            .saveAccount(new Account(
                                account_name: accountNameController.text,
                                private_key: privateKeyController.text,
                                isDefault: 1))
                            .then((value) {
                          print(
                              'results of saving new account ${value.toMap()}');
                          setState(() {
                            this.isLoading = false;
                            this.accounts.add(new Account(
                                account_name: accountNameController.text,
                                private_key: privateKeyController.text,
                                isDefault: 1));
                          });
                          showSnackBar(parentContext, 0,
                              "Added new Account ${accountNameController.text}");
                        }).catchError((onError) {
                          print('error saving account $onError');
                          setState(() {
                            this.isLoading = false;
                          });
                          showSnackBar(parentContext, 0,
                              "Something went wrong whilst adding new account ${accountNameController.text}");
                        });
                      } else {
                        //@dev inconsistent coding will refactor later
                        locator<CacheDB>()
                            .saveAccount(new Account(
                                account_name: accountNameController.text.toLowerCase(),
                                private_key: privateKeyController.text,
                                isDefault: 0))
                            .then((value) {
                          print('results of saving new account $value');
                          setState(() {
                            this.isLoading = false;
                            this.accounts.add(new Account(
                                account_name: accountNameController.text,
                                private_key: privateKeyController.text,
                                isDefault: 0));
                          });
                          showSnackBar(parentContext, 0,
                              "Added new Account ${accountNameController.text}");
                        }).catchError((onError) {
                          print('error saving account $onError');
                          setState(() {
                            this.isLoading = false;
                          });
                          showSnackBar(parentContext, 0,
                              "Something went wrong whilst adding new account ${accountNameController.text}");
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
                                  "Account Settings",
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
                              "Select Default Wallet Address or Remove",
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
                            child: this.accounts.length == 0
                                ? Center(
                                    child: FittedBox(
                                      child: Text(
                                        "No Accounts Found",
                                        style: TextStyle(
                                            color: AppColors.primaryColor,
                                            fontSize: 20),
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: accounts.length,
                                    shrinkWrap: true,
                                    itemBuilder: (parentContext, index) {
                                      return Card(
                                          child: ListTile(
                                              leading: IconButton(
                                                iconSize: 25,
                                                onPressed: () {
                                                  setState(() {
                                                    deleteAccount(
                                                            accounts[index]
                                                                .private_key)
                                                        .then((deleted) {
                                                      if (deleted) {
                                                        model.setDefaultAccount(new Account(
                                                            account_name: "NULL",
                                                            private_key: "NULL",
                                                            isDefault: 1));
                                                        showSnackBar(
                                                            parentContext,
                                                            index,
                                                            "Deleted account ${accounts[index].private_key}");
                                                      } else {
                                                        showSnackBar(
                                                            parentContext,
                                                            index,
                                                            "Could not delete account ${accounts[index].private_key}");
                                                      }
                                                      accounts.removeAt(index);
                                                      this.isLoading = false;
                                                    }).catchError((onError) {
                                                      print(
                                                          'error deleting account: $onError');
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
                                                    accounts[index].isDefault =
                                                        value;
                                                    model.setDefaultAccount(
                                                        accounts[index]);
                                                    updateDefaultSettings(model
                                                            .getCurrentUser)
                                                        .then((value) {
                                                      print(
                                                          'Changed default account results: $value');
                                                      showSnackBar(
                                                          parentContext,
                                                          index,
                                                          "Successfully changed default account address to ${accounts[index].private_key}");
                                                    });
                                                  });
                                                },
                                              ),
                                              subtitle: Text(
                                                accounts[index].private_key,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 13),
                                              ),
                                              title: Text(
                                                accounts[index].account_name,
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
                                "Add Wallet Address",
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

Future<bool> deleteAccount(String private_address) async {
  var deleted =
      await Future.value(locator<CacheDB>().deleteAccount(private_address));
  return deleted == 1 ? true : false;
}

Future<List<Account>> getCachedAccounts() async {
  var accounts = await Future.value(locator<CacheDB>().getAddresses());
  accounts.map((e) => print('account: ${e.toString()}'));
  return Future.value(accounts);
}

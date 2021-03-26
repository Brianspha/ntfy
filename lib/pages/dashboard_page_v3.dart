import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ntfy/database/cache_db.dart';
import 'package:ntfy/models/user.dart';
import 'package:ntfy/scoped_models/app_store.dart';
import 'package:ntfy/service_locator.dart';
import 'package:ntfy/ui/shared/app_colors.dart';
import 'package:scoped_model/scoped_model.dart';

class DashBoardPageV3 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return DashBoardPageV3State();
  }
}

class DashBoardPageV3State extends State<DashBoardPageV3>
    with TickerProviderStateMixin {
  TabController _tabController;
  var isLoading = true;
  User user = User(
      token_name: "NULL",
      setting_id: -1,
      account_name: "NULL",
      token_address: "NULL",
      private_key: "NULL",
      network_name: "NULL",
      network_url: "NULL");
  @override
  void initState() {
    getDefaultSettings().then((results) => {
          print(
            'results of getting user settings: ${results.toMap()}',
          ),
          setState(() {
            this.user = results == null ? this.user : results;
            this.isLoading = false;
          })
        });
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SafeArea(child: ScopedModelDescendant<AppStore>(
        builder: (BuildContext context, Widget child, AppStore model) {
      return Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          // color: Colors.red,
          child: SingleChildScrollView(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
              ),
              Center(
                child: FittedBox(
                  child: Text(
                    "Account 1",
                    style: TextStyle(fontSize: 20, color: AppColors.grey),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
              ),
              Center(
                child: FittedBox(
                  child: Text(
                    "\$ ${new Random().nextInt(1233)}",
                    style: TextStyle(fontSize: 13, color: AppColors.grey),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
              ),
              Center(
                child: Container(
                  child: Card(
                    child: Text(
                      "0x88E2B69f8069E318E64358B4E6208A3E73e5d159".substring(
                              0, 2) +
                          ".." +
                          "0x88E2B69f8069E318E64358B4E6208A3E73e5d159"
                              .substring(
                                  "0x88E2B69f8069E318E64358B4E6208A3E73e5d159"
                                          .length -
                                      6,
                                  "0x88E2B69f8069E318E64358B4E6208A3E73e5d159"
                                      .length),
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 2,
                  ),
                  height: MediaQuery.of(context).size.height * .03,
                  width: MediaQuery.of(context).size.width * .3,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(60),
                    topRight: Radius.circular(60),
                  ),
                ),
                height: 40,
                child: Center(
                  child: TabBar(
                    isScrollable: true,
                    labelColor: Colors.grey,
                    controller: _tabController,
                    tabs: <Widget>[
                      Tab(
                        child: Text(
                          "Mint NFT",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      Tab(
                        child: Text("View Minted",
                            style: TextStyle(color: Colors.black)),
                      ),
                      Tab(
                        child: Text("Settings",
                            style: TextStyle(color: Colors.black)),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(1, 0, 0, 0),
                child: Container(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      Container(
                        height: 30,
                        width: 30,
                        child: Text("Heey"),
                      ),
                      Container(
                        height: 30,
                        width: 30,
                        child: Text("Heey"),
                      ),
                      Container(
                        height: 30,
                        width: 30,
                        child: Text("Heey"),
                      )
                    ],
                  ),
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width - 20,
                ),
              )
            ],
          )),
        ),
      );
    }));
  }
}

Future<User> getDefaultSettings() async {
  var user = await locator.get<CacheDB>().getDefaultSettings();
  return Future.value(user);
}

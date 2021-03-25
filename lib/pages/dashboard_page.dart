import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:ntfy/database/cache_db.dart';
import 'package:ntfy/models/user.dart';
import 'package:ntfy/pages/minted_nfts_page.dart';
import 'package:ntfy/pages/select_image_page.dart';
import 'package:ntfy/pages/settings_page.dart';
import 'package:ntfy/scoped_models/app_store.dart';
import 'package:ntfy/service_locator.dart';
import 'package:ntfy/ui/shared/app_colors.dart';
import 'package:scoped_model/scoped_model.dart';

class FrontWidget extends StatefulWidget {
  Function open;

  FrontWidget(this.open);

  @override
  FrontWidgetState createState() => FrontWidgetState();
}

class FrontWidgetState extends State<FrontWidget>
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
  void didUpdateWidget(covariant FrontWidget oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    print("oldWidget.user is ${oldWidget.createState().user.token_name}");
    print("widget.user is ${widget.createState().user.token_name}");
  }

  @override
  Widget build(BuildContext context) {
    print("in dashboard");
    return ScopedModelDescendant<AppStore>(
        builder: (BuildContext context, Widget child, AppStore model) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: LoadingOverlay(
            isLoading: isLoading,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top,
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                    child: Container(
                      color: Color(0xffeaf2f8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        child: Text(
                          "Main Address",
                          style: TextStyle(
                            color: Color(0xff266ed5),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: FittedBox(
                      child: this.user.private_key.isNotEmpty &&
                              user.private_key != "NULL"
                          ? Text(
                              this.user.private_key.substring(0, 2) +
                                  ".." +
                                  this.user.private_key.substring(
                                      this.user.private_key.length - 4,
                                      this.user.private_key.length),
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            )
                          : Text("No Address Set",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              )),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                    child: Container(
                      color: Color(0xffeaf2f8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        child: Text(
                          "Network URL",
                          style: TextStyle(
                            color: Color(0xff266ed5),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: FittedBox(
                      child: this.user.network_url.isNotEmpty &&
                              user.network_url != "NULL"
                          ? Text(
                              this.user.network_url.substring(0, 3) +
                                  ".." +
                                  this.user.network_url.substring(
                                      this.user.network_url.length - 4,
                                      this.user.network_url.length),
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            )
                          : Text("No Network Set",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              )),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                    child: Container(
                      color: Color(0xffeaf2f8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        child: Text(
                          "Token Address",
                          style: TextStyle(
                            color: Color(0xff266ed5),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: FittedBox(
                      child: this.user.token_address.isNotEmpty &&
                              user.token_address != "NULL"
                          ? Text(
                              this.user.token_address.substring(0, 6) +
                                  ".." +
                                  this.user.token_address.substring(
                                      this.user.token_address.length - 4,
                                      this.user.token_address.length),
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            )
                          : Text("No Address Set",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              )),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 20,
                    ),
                    child: SizedBox(
                      height: 40,
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
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height - 80,
                    child: TabBarView(
                      controller: _tabController,
                      children: <Widget>[
                        buildContainerMintNFT(),
                        buildMintedNFTsPage(),
                        buildSettingsPage(),
                      ],
                    ),
                  )
                ],
              ),
            )),
      );
    });
  }

  Widget buildSettingsPage() {
    return SettingsPage();
  }

  Widget buildMintedNFTsPage() {
    return MintedNFTsPage();
  }

  Widget buildContainerMintNFT() {
    return Container(
      child: InkWell(
        child: Card(
          margin: EdgeInsets.symmetric(horizontal: 50, vertical: 100),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Icon(
              Icons.add,
              size: 50,
              color: AppColors.primaryColor,
            ),
          ),
        ),
        onTap: () {
          print('clicked on add NFT');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SelectImagePage()),
          );
        },
      ),
    );
  }

  Future<User> getDefaultSettings() async {
    var user = await locator.get<CacheDB>().getDefaultSettings();
    return Future.value(user);
  }

  Future<void> setApplicationLaunchStatus(int i) async {
    await locator.get<CacheDB>().setApplicationLaunchStatus(1);
  }
}

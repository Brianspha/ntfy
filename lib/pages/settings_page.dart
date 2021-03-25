import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:ntfy/pages/network_settings_page.dart';
import 'package:ntfy/pages/token_settings_page.dart';
import 'package:ntfy/pages/wallet_settings_page.dart';
import 'package:ntfy/scoped_models/app_store.dart';
import 'package:ntfy/ui/shared/app_colors.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SettingsPageState();
  }
}

class SettingsPageState extends State<SettingsPage> {
  var isLoading = false;
  @override
  Widget build(BuildContext context) {
    var settings = [
      RawMaterialButton(
        onPressed: () {

        },
        child: Hero(
          tag: 1,
          child: Card(
            elevation: 20,
            color: AppColors.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            child: InkWell(
              onTap: () {Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (context) => new TokenSettingsPage()));},
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.pending_actions,
                      size: 50,
                      color: Colors.white,
                    ),
                    Padding(padding: EdgeInsets.symmetric(vertical: 20)),
                    FittedBox(
                      child: Text(
                        "Token",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      RawMaterialButton(
        onPressed: () {},
        child: Hero(
          tag: 2,
          child: Card(
            elevation: 20,
            color: AppColors.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            child: InkWell(
              onTap: () {Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (context) => new WalletSettingsPage()));},
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 50,
                      color: Colors.white,
                    ),
                    Padding(padding: EdgeInsets.symmetric(vertical: 20)),
                    FittedBox(
                      child: Text(
                        "Wallet",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      RawMaterialButton(
        onPressed: () {},
        child: Hero(
          tag: 3,
          child: Card(
            elevation: 20,
            color: AppColors.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            child: InkWell(
              onTap: () {Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (context) =>new NetworkSettingsPage()));},
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.settings_ethernet,
                      size: 50,
                      color: Colors.white,
                    ),
                    Padding(padding: EdgeInsets.symmetric(vertical: 20)),
                    FittedBox(
                      child: Text(
                        "Network",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      )
    ];
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
                      'Settings',
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
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemBuilder: (context, index) {
                            return settings[index];
                          },
                          itemCount: settings.length,
                        ),
                      ),
                    )
                  ],
                ),
              ));
        }));
  }
}

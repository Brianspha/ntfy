import 'package:animated_splash/animated_splash.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ntfy/database/cache_db.dart';
import 'package:ntfy/models/account.dart';
import 'package:ntfy/models/network.dart';
import 'package:ntfy/models/token.dart';
import 'package:ntfy/models/user.dart';
import 'package:ntfy/pages/main_menu_V2.dart';
import 'package:ntfy/scoped_models/app_store.dart';
import 'package:ntfy/service_locator.dart';
import 'package:ntfy/utils/constants.dart';
import 'package:ntfy/utils/skynet_functions.dart';
import 'package:scoped_model/scoped_model.dart';

import 'application_introduction_page.dart';

class SplashScreenPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SplashScreenPageState();
  }
}

class SplashScreenPageState extends State<SplashScreenPage> {
  bool status = false;
  @override
  void initState() {
    // TODO: implement initState
    locator.get<CacheDB>().getApplicationLaunchedStatus().then((value) {
      setState(() {
        print('app lauch status: $value');
        this.status = value;
        if (value) {
          locator.get<CacheDB>().getDefaultSettings().then((settings) async{
            locator.get<Network>().network_name = settings.network_name;
            locator.get<Network>().network_url = settings.network_url;
            locator.get<Account>().private_key = settings.private_key;
            locator.get<Account>().account_name = settings.account_name;
            locator.get<Token>().token_address = settings.token_address;
            locator.get<Token>().token_name = settings.token_name;
          });
        } else {
          locator.get<CacheDB>().setApplicationLaunchStatus(1).then((value) {
            print('set app launch status');
          });
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(body: SafeArea(child: ScopedModelDescendant<AppStore>(
        builder: (BuildContext context, Widget child, AppStore model) {
      return AnimatedSplash(
        imagePath: 'assets/icons/idea.png',
        home: this.status ? MainMenuPageV2() : ApplicationWalkThroughPage(),
        duration: 2500,
        type: AnimatedSplashType.StaticDuration,
      );
    })));
  }
}

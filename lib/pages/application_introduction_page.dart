import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:ntfy/scoped_models/app_store.dart';
import 'package:ntfy/ui/shared/app_colors.dart';
import 'package:scoped_model/scoped_model.dart';

import 'dashboard_page_v2.dart';

class ApplicationWalkThroughPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ApplicationWalkThroughPageState();
  }
}

class ApplicationWalkThroughPageState
    extends State<ApplicationWalkThroughPage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(body: SafeArea(child: ScopedModelDescendant<AppStore>(
        builder: (BuildContext context, Widget child, AppStore model) {
      const bodyStyle = TextStyle(fontSize: 19.0);
      const pageDecoration = const PageDecoration(
        titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
        bodyTextStyle: bodyStyle,
        descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
        pageColor: Colors.white,
        imagePadding: EdgeInsets.zero,
      );
      final introKey = GlobalKey<IntroductionScreenState>();

      void _onIntroEnd(context) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => MainMenuPageV2()),
        );
      }

      Widget buildImage(IconData iconName) {
        return Align(
          child: Icon(
            iconName,
            size: 100,
            color: AppColors.primaryColor,
          ),
          alignment: Alignment.bottomCenter,
        );
      }

      return IntroductionScreen(
        key: introKey,
        pages: [
          PageViewModel(
            titleWidget: Wrap(
              children: [
                Center(
                  child: Text(
                    "Take pictures of your favourite objects or moments and mint them as NFTs straight from your camera roll",
                    style: TextStyle(color: Colors.black, fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
            body:
                "Instead of having to buy an entire share, invest any amount you want.",
            image: buildImage(Icons.camera),
            decoration: pageDecoration,
          ),
          PageViewModel(
            body:
          "Instead of having to buy an entire share, invest any amount you want.",
            titleWidget: Wrap(
              children: [
                Center(
                  child: Text(
                    "Transfer your minted NFTs to your loved ones",
                    style: TextStyle(color: Colors.black, fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
            image: buildImage(Icons.card_giftcard),
            decoration: pageDecoration,
          ),
          PageViewModel(
            body:
            "Instead of having to buy an entire share, invest any amount you want.",
            titleWidget: Wrap(
              children: [
                Center(
                  child: Text(
                    "Import your existing Ethereum wallets, and Existing NFT Token Contracts",
                    style: TextStyle(color: Colors.black, fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
            image: buildImage(Icons.import_export),
            decoration: pageDecoration,
          ),
        ],
        onDone: () => _onIntroEnd(context),
        //onSkip: () => _onIntroEnd(context), // You can override onSkip callback
        showSkipButton: true,
        skipFlex: 0,
        nextFlex: 0,
        skip: const Text('Skip'),
        next: const Icon(Icons.arrow_forward),
        done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
        dotsDecorator: const DotsDecorator(
          size: Size(10.0, 10.0),
          color: Color(0xFFBDBDBD),
          activeSize: Size(22.0, 10.0),
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
          ),
        ),
      );
    })));
  }
}

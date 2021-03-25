import 'package:flutter/material.dart';
import 'package:ntfy/database/cache_db.dart';
import 'package:ntfy/pages/application_introduction_page.dart';
import 'package:ntfy/pages/main_menu.dart';
import 'package:ntfy/pages/main_menu_V2.dart';
import 'package:ntfy/pages/select_image_page.dart';
import 'package:ntfy/pages/splash_screen_page.dart';
import 'package:ntfy/scoped_models/app_store.dart';
import 'package:ntfy/service_locator.dart';
import 'package:responsive_framework/responsive_wrapper.dart';
import 'package:responsive_framework/utils/scroll_behavior.dart';
import 'package:scoped_model/scoped_model.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    setupLocator();
    locator.get<CacheDB>().initDb();
    return ScopedModel<AppStore>(
        model: new AppStore(),
        child: MaterialApp(
            builder: (context, widget) => ResponsiveWrapper.builder(
                BouncingScrollWrapper.builder(context, widget),
                maxWidth: 1200,
                minWidth: 450,
                defaultScale: true,
                breakpoints: [
                  ResponsiveBreakpoint.resize(450, name: MOBILE),
                  ResponsiveBreakpoint.autoScale(800, name: TABLET),
                  ResponsiveBreakpoint.autoScale(1000, name: TABLET),
                  ResponsiveBreakpoint.resize(1200, name: DESKTOP),
                  ResponsiveBreakpoint.autoScale(2460, name: "4K"),
                ],
                background: Container(color: Color(0xFFF5F5F5))),
            title: 'nfta',
            theme: ThemeData(
                primaryColor: Color.fromARGB(255, 9, 202, 172),
                backgroundColor: Color.fromARGB(255, 26, 27, 30),
                textTheme: Theme.of(context).textTheme.apply(
                    fontFamily: 'Open Sans',
                    bodyColor: Colors.white,
                    displayColor: Colors.white)),
            home: SplashScreenPage()));
  }
}

import 'package:flutter/material.dart';
import 'package:ntfy/scoped_models/app_store.dart';
import 'package:ntfy/pages/dashboard_page.dart';
import 'package:scoped_model/scoped_model.dart';

class MainMenuPageV2 extends StatefulWidget {
  @override
  MainMenuPageV2State createState() => MainMenuPageV2State();
}

class MainMenuPageV2State extends State<MainMenuPageV2>
    with TickerProviderStateMixin {
  double left = 0;
  double direction;
  double MAX_LEFT = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<AppStore>(
        builder: (BuildContext context, Widget child, AppStore model) {
      return Scaffold(
        body: SafeArea(
          child: Builder(
            builder: (context) {
              MAX_LEFT = MediaQuery.of(context).size.width * 1.0 - 80;
              return _buildBody();
            },
          ),
        ),
      );
    });
  }

  Widget _buildBody() {
    return GestureDetector(
      onHorizontalDragUpdate: (update) {
        setState(() {
          print('currentDirection: $direction');
          left = left + update.delta.dx;
          direction = update.delta.direction;
          if (left <= 0) {
            left = 0;
          }

          if (left > MAX_LEFT) {
            left = MAX_LEFT;
          }
        });
      },
      onHorizontalDragEnd: (end) {
        animateWidget();
      },
      child: Container(
        color: Color(0xff191f39),
        child: Stack(
          children: <Widget>[
            Positioned(
              left: left,
              top: left * 0.2,
              bottom: left * 0.2 / 2,
              child: FrontWidget(open),
            ),
          ],
        ),
      ),
    );
  }

  void open() {
    if (left == MAX_LEFT) {
      setState(() {
        direction = 1;
      });
    } else {
      setState(() {
        direction = 0;
      });
    }

    animateWidget();
  }

  Animation _animation;

  void animateWidget() {
    bool increment = direction <= 0;

    AnimationController _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    )..addListener(() {
        setState(() {
          left = _animation.value;
        });
      });

    double temp_left = left;
    _animation = Tween(
      begin: temp_left,
      end: increment ? MAX_LEFT : 0.0,
    ).animate(CurvedAnimation(
        curve: Curves.fastLinearToSlowEaseIn, parent: _controller));

    _controller.forward();
  }
}

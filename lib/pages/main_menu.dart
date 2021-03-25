import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:ntfy/pages/select_image_page.dart';
import 'package:ntfy/scoped_models/app_store.dart';
import 'package:ntfy/ui/shared/app_colors.dart';
import 'package:scoped_model/scoped_model.dart';

class MainMenuPage extends StatefulWidget {
  @override
  MainMenuPageState createState() => MainMenuPageState();
}

class MainMenuPageState extends State<MainMenuPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ScopedModelDescendant<AppStore>(
          builder: (BuildContext context, Widget child, AppStore model) {
            return Container(
              child: Row(
                children: <Widget>[
                 if(!model.hideToolBar) LeftWidget(),
                  model.selectedTabIndex == 0
                      ? Expanded(child: SelectImagePage())
                      : model.selectedTabIndex == 1
                          ? Expanded(
                              child: Container(
                                color: Colors.transparent,
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                              ),
                            )
                          : Expanded(
                    child: RightWidget(),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class LeftWidget extends StatefulWidget {
  @override
  LeftWidgetState createState() => LeftWidgetState();
}

class LeftWidgetState extends State<LeftWidget> with TickerProviderStateMixin {
  List<String> _list = ["Mint NFT", "Minted", "Wallet Config"];

  List<GlobalKey> _keys = [
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
    GlobalKey(),
  ];

  int checkIndex = 0;

  Offset checkedPositionOffset = Offset(0, 0);
  Offset lastCheckOffset = Offset(0, 0);

  Offset animationOffset = Offset(0, 0);
  Animation _animation;
  AnimationController _animationController;

  @override
  void initState() {
    checkIndex = _list.length - 1;
    super.initState();

    SchedulerBinding.instance.endOfFrame.then((value) {
      calcuteCheckOffset();
      addAnimation();
    });
  }

  void calcuteCheckOffset() {
    lastCheckOffset = checkedPositionOffset;
    RenderBox renderBox = _keys[checkIndex].currentContext.findRenderObject();
    Offset widgetOffset = renderBox.localToGlobal(Offset(0, 0));
    Size widgetSise = renderBox.size;
    checkedPositionOffset = Offset(widgetOffset.dx + widgetSise.width,
        widgetOffset.dy + widgetSise.height-80);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: ScopedModelDescendant<AppStore>(
        builder: (BuildContext context, Widget child, AppStore model) {
      return Container(
        child: Stack(
          children: <Widget>[
            Container(
              width: 70,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                children: buildList(model),
              ),
            ),
            Positioned(
              top: animationOffset.dy,
              left: animationOffset.dx,
              child: CustomPaint(
                painter: CheckPointPainter(Offset(10, 0)),
              ),
            )
          ],
        ),
      );
    }));
  }

  List<Widget> buildList(AppStore model) {
    List<Widget> _widget_list = [];

    for (int i = 0; i < _list.length; i++) {
      _widget_list.add(Expanded(
        flex: 1,
        child: GestureDetector(
            onTap: () {
              indexChecked(i);
              setState(() {
                model.setSelectedTab(i);
                if(i==0){
                  model.setHideToolBar(true);
                }
              });
            },
            child: VerticalText(
                _list[i],
                _keys[i],
                checkIndex == i &&
                    (_animationController != null &&
                        _animationController.isCompleted))),
      ));
    }
    _widget_list.add(Padding(
      padding: EdgeInsets.only(
        top: 50,
        bottom: 50,
      ),
      child: Icon(
        Icons.info,
        color: Colors.white,
        size: 30,
      ),
    ));
    return _widget_list;
  }

  void indexChecked(int i) {
    if (checkIndex == i) return;

    setState(() {
      checkIndex = i;
      calcuteCheckOffset();
      addAnimation();
    });
  }

  void addAnimation() {
    _animationController =
        AnimationController(duration: Duration(milliseconds: 300), vsync: this)
          ..addListener(() {
            setState(() {
              animationOffset =
                  Offset(checkedPositionOffset.dx, _animation.value);
            });
          });

    _animation = Tween(begin: lastCheckOffset.dy, end: checkedPositionOffset.dy)
        .animate(CurvedAnimation(
            parent: _animationController, curve: Curves.easeInOutBack));
    _animationController.forward();
  }
}

class CheckPointPainter extends CustomPainter {
  double pointRadius = 10;
  double radius = 35;

  Offset offset;

  CheckPointPainter(this.offset);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..style = PaintingStyle.fill;

    double startAngle = -math.pi / 2;
    double sweepAngle = math.pi;

    paint.color = AppColors.primaryColor;

    canvas.drawArc(
        Rect.fromCircle(center: Offset(offset.dx, offset.dy), radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint);

    paint.color = AppColors.primaryColor;
    canvas.drawCircle(
        Offset(offset.dx - pointRadius / 2, offset.dy - pointRadius / 2),
        pointRadius,
        paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class VerticalText extends StatelessWidget {
  String name;
  bool checked;
  GlobalKey globalKey;

  VerticalText(this.name, this.globalKey, this.checked);

  @override
  Widget build(BuildContext context) {
    return RotatedBox(
      key: globalKey,
      quarterTurns: 3,
      child: Text(
        name,
        style: TextStyle(
          color: checked ? Colors.blueAccent[100] : Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }
}

class RightWidget extends StatefulWidget {
  @override
  RightWidgetState createState() => RightWidgetState();
}

class RightWidgetState extends State<RightWidget>
    with TickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 3);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: 15,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 50, left: 20),
            child: Text(
              "NFTY",
              style: TextStyle(
                color: Colors.black,
                fontSize: 25,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15, left: 10),
            child: SizedBox(
              height: 30,
              child: TabBar(
                isScrollable: true,
                unselectedLabelColor: Colors.black,
                labelColor: AppColors.primaryColor,
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.primaryColorLighter,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
                tabs: <Widget>[
                  Tab(
                    text: "Asian",
                  ),
                  Tab(
                    text: "American",
                  ),
                  Tab(
                    text: "Franch",
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: <Widget>[
                RightBody(),
                RightBody(),
                RightBody(),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class RightBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: 15,
      ),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              top: 20,
            ),
            child: Text(
              "Near you",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                Container(
                  width: 220,
                  margin: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        spreadRadius: 5,
                        blurRadius: 5,
                        offset: Offset(1, 2),
                        color: Color(0x33757575),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 220,
                  margin: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        spreadRadius: 5,
                        blurRadius: 5,
                        offset: Offset(1, 2),
                        color: Color(0x33757575),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 20,
            ),
            child: Text(
              "Popular",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                Container(
                  width: 220,
                  margin: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        spreadRadius: 5,
                        blurRadius: 5,
                        offset: Offset(1, 2),
                        color: Color(0x33757575),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 220,
                  margin: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        spreadRadius: 5,
                        blurRadius: 5,
                        offset: Offset(1, 2),
                        color: Color(0x33757575),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 50,
              bottom: 100,
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                margin: EdgeInsets.only(
                  right: 20,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                    color: Color(0xffED305A),
                    borderRadius: BorderRadius.circular(
                      30,
                    )),
                child: Text(
                  "View All",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

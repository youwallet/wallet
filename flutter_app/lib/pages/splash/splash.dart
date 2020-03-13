import 'dart:async';

import 'package:flutter/material.dart';
import 'package:youwallet/pages/tabs.dart';


class SplashWidget extends StatefulWidget {

  int tabIndex;

  SplashWidget({Key key, @required  this.tabIndex}) : super(key: key);

  @override
  _SplashWidgetState createState() => _SplashWidgetState();

}

class _SplashWidgetState extends State<SplashWidget> {

  int tabIndex;

//  _SplashWidgetState({Key key, @required this.tabIndex}) : super(key: key);

  var container = ContainerPage(tabIndex: 0);

  bool showAd = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        body: Stack(
            children: <Widget>[
              Offstage(
                child: container,
                offstage: showAd,
              ),
              Offstage(
                child: Container(
                  color: Colors.white,
                  child: Stack(
                    children: <Widget>[
                      Align(
                        alignment: Alignment(0.0, 0.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: Text(
                                '启动页面',
                                style: TextStyle(fontSize: 30.0, color: Colors.lightBlue),
                              ),
                            )
                          ],
                        ),
                      ),
                      SafeArea(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Align(
                                alignment: Alignment(1.0, 0.0),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 30.0, top: 20.0),
                                  padding: const EdgeInsets.only(
                                      left: 10.0, right: 10.0, top: 2.0, bottom: 2.0),
                                  child: CountDownWidget(
                                    onCountDownFinishCallBack: (bool value) {
                                      if (value) {
                                        setState(() {
                                          showAd = false;
                                        });
                                      }
                                    },
                                  ),
                                  decoration: BoxDecoration(
                                      color: Color(0xffEDEDED),
                                      borderRadius:
                                      const BorderRadius.all(Radius.circular(10.0))),
                                ),
                              ),
                            ],
                          ))
                    ],
                  ),
                ),
                offstage: !showAd,
              )
            ],
          )
    );
  }
}

class CountDownWidget extends StatefulWidget {
  final onCountDownFinishCallBack;

  CountDownWidget({Key key, @required this.onCountDownFinishCallBack})
      : super(key: key);

  @override
  _CountDownWidgetState createState() => _CountDownWidgetState();
}

class _CountDownWidgetState extends State<CountDownWidget> {
  var _seconds = 3;
  Timer _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '$_seconds',
      style: TextStyle(fontSize: 17.0),
    );
  }

  /// 启动倒计时的计时器。
  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {});
      if (_seconds <= 1) {
        widget.onCountDownFinishCallBack(true);
        _cancelTimer();
        return;
      }
      _seconds--;
    });
  }

  /// 取消倒计时的计时器。
  void _cancelTimer() {
    _timer?.cancel();
  }
}
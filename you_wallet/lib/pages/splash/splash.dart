import 'package:flutter/material.dart';
import 'dart:async';
import 'package:youwallet/model/wallet.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bugly/flutter_bugly.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash>{
  // String _platformVersion = 'Unknown';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    countDown();
    FlutterBugly.init(
      androidAppId: "0dad6da2da",
      iOSAppId: "a5e595c93b",
    ).then((_result) {
      setState(() {
        // _platformVersion = _result.message;
        print(_result.appId);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Center(
              child: new Image.asset(
                "images/logo.png",
                width: 120.0,
                height: 120.0,
                fit: BoxFit.fill,
              ),
            ),
            Text(
                'youWallet',
                style: TextStyle(
                  fontSize: 28.0,
                  height: 2.0,
                )
            )
//            new Container(
//              alignment: Alignment.topRight,
//              padding: const EdgeInsets.fromLTRB(0.0, 45.0, 10.0, 0.0),
//              child: OutlineButton(
//                child: new Text(
//                  "跳过",
//                  textAlign: TextAlign.center,
//                  style: new TextStyle(color: Colors.white),
//                ),
//                // StadiumBorder椭圆的形状
//                shape: new StadiumBorder(),
//                onPressed: () {
//                  go2HomePage();
//                },
//              ),
//            ),
          ],
        ),
    );
  }



  // 倒计时
  void countDown() {
    var _duration = new Duration(seconds: 5);
    new Future.delayed(_duration, go2HomePage);
  }

  // 前往首页
  // 如果用户在本地还没有钱包，则跳转钱包新建页面
  void go2HomePage() {
    List wallets = Provider.of<Wallet>(context).items;
    if (wallets.length == 0) {
      Navigator.pushReplacementNamed(context, 'wallet_guide');
    } else {
      Navigator.pushReplacementNamed(context, '/');
    }
  }
}

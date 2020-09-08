import 'package:flutter/material.dart';
import 'package:youwallet/global.dart';

// 显示token对应的logo
class TokenLogo extends StatelessWidget {
  final String address;

  TokenLogo({Key key, @required this.address}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map token = Global.hotToken.firstWhere(
        (element) => (element['address'] == this.address),
        orElse: () => ({}));
    if (token.isEmpty) {
      // return Icon(IconData(0xe648, fontFamily: 'iconfont'),size: 50.0, color: Colors.black26);
      return Stack(
        children: <Widget>[
          Container(
            width: 50.0,
            height: 50.0,
            decoration: new BoxDecoration(
                border: new Border.all(width: 2.4, color: Colors.transparent),
                borderRadius: new BorderRadius.all(new Radius.circular(25.0))),
          ),
          Positioned(
              child: Icon(IconData(0xe648, fontFamily: 'iconfont'),
                  size: 50.0, color: Colors.white)),
        ],
      );
    } else {
      return Stack(
        children: <Widget>[
          Container(
            width: 50.0,
            height: 50.0,
            decoration: new BoxDecoration(
                border: new Border.all(width: 2.4, color: Colors.transparent),
                color: Colors.white,
                borderRadius: new BorderRadius.all(new Radius.circular(25.0))),
          ),
          Positioned(
              top: -2.0,
              child: Icon(IconData(token['icon'], fontFamily: 'iconfont'),
                  size: 50.0, color: token['color'])),
        ],
      );
    }
  }
}

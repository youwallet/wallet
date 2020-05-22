import 'package:flutter/material.dart';
import 'package:youwallet/global.dart';

// 显示token对应的logo
class TokenLogo extends StatelessWidget {

  final String address;

  TokenLogo({
    Key key,
    @required this.address
  }): super(key: key);

  @override
  Widget build(BuildContext context) {
    Map token = Global.hotToken.firstWhere((element)=>(element['address'] == this.address),orElse: ()=>({}));
    if (token.isEmpty) {
      return CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 25.0,
          child: Icon(IconData(0xe648, fontFamily: 'iconfont'),size: 50.0, color: Colors.black26)
      );
    } else {
      return CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 25.0,
          child: Icon(IconData(token['icon'], fontFamily: 'iconfont'),size: 50.0, color: token['color'])
      );
    }
  }
}

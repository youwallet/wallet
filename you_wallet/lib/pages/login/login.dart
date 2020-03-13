
import 'package:flutter/material.dart';


class Login extends StatefulWidget {
  Login() : super();
  @override
  _LoginState createState()  => _LoginState();
}

class _LoginState extends State<Login> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: new Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new Container(
                margin: const EdgeInsets.only(bottom: 30.0),
                child: new Image.asset(
                    'images/new_wallet.png'
                ),
              ),
              new Container(
                margin: const EdgeInsets.only(top: 50.0, bottom: 20.0),
                child: new Image.asset(
                    'images/fingerprint.png'
                ),
              ),
              new Text('点击唤醒验证'),
            ],
          ),
        )
    );
  }
}

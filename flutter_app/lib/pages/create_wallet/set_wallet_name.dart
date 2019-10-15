
import 'package:flutter/material.dart';


class NewWalletName extends StatefulWidget {
  NewWalletName() : super();
  @override
  _NewWalletNameState createState()  => _NewWalletNameState();
}

class _NewWalletNameState extends State<NewWalletName> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("创建钱包"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new Placeholder(
                fallbackWidth: 100.0,
                fallbackHeight: 100.0,
                color: Colors.orange,
              ),
              new TextField(
                decoration: InputDecoration(
                  hintText: "输入钱包名称",
                ),
              ),
              new Container(
                margin: const EdgeInsets.only(top: 50.0, bottom: 60.0),
                child: new Image.asset(
                    'assets/images/logo.png'
                ),
              ),
              new Text('开启指纹'),
              new Text('设置免密登录'),
            ],
          ),
        )
    );
  }
}

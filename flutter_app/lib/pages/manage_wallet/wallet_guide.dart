
import 'package:flutter/material.dart';


class WalletGuide extends StatefulWidget {
  WalletGuide() : super();
  @override
  _WalletGuideState createState()  => _WalletGuideState();
}

class _WalletGuideState extends State<WalletGuide> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("返回"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new Text(
                  '创建您的第一个数字钱包',
                  style: new TextStyle(
                      fontSize: 28.0,
                      color: Colors.lightBlue
                  )
              ),
              new Container(
                  margin: const EdgeInsets.only(top: 50.0, bottom: 60.0),
                  child: new Image.asset(
                      'images/new_wallet.png'
                  ),
              ),
              new MaterialButton(
                color: Colors.blue,
                textColor: Colors.white,
                minWidth: 300, // 控制按钮宽度
                child: new Text('创建钱包'),
                onPressed: () {
                  Navigator.pushNamed(context, "set_wallet_name");
                },
              ),
              new MaterialButton(
                color: Colors.blue,
                textColor: Colors.white,
                minWidth: 300, // 控制按钮宽度
                child: new Text('导入钱包'),
                onPressed: () {
                  Navigator.pushNamed(context, "load_wallet");
                },
              ),
            ],
          ),
        )
    );
  }
}

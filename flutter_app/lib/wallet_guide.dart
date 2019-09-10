
import 'package:flutter/material.dart';


class WalletGuide extends StatefulWidget {
  WalletGuide() : super();
  @override
  _WalletGuideState createState()  => _WalletGuideState();
}

class _WalletGuideState extends State<WalletGuide> {


  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        appBar: AppBar(
          title: Text("youwallet"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new Text(
                  '创建您的第一个数字钱包',
                  style: new TextStyle(
                      fontSize: 28.0,
                      color: Color.fromARGB(100, 6, 147, 193)
                  )
              ),
              new Image.asset(
                  'assets/images/logo.png'
              ),
              new MaterialButton(
                color: Colors.blue,
                textColor: Colors.white,
                minWidth: 300, // 控制按钮宽度
                child: new Text('创建钱包'),
                onPressed: () {
                  // ...
                },
              ),
              new RaisedButton(
                child: new Text('导入钱包'),
                onPressed: () {
                  // ...
                },
              ),
            ],
          ),
        )
    );
  }
}

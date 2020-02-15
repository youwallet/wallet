
import 'package:flutter/material.dart';


class WalletSuccess extends StatefulWidget {
  WalletSuccess() : super();
  @override
  _WalletGuideState createState()  => _WalletGuideState();
}

class _WalletGuideState extends State<WalletSuccess> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
//        appBar: AppBar(
//          title: Text(""),
//        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
//              new Text(
//                  '创建成功',
//                  style: new TextStyle(
//                      fontSize: 28.0,
//                      color: Colors.lightBlue
//                  )
//              ),
              new Container(
                margin: const EdgeInsets.only(top: 50.0, bottom: 60.0),
                child: Icon(IconData(0xe617, fontFamily: 'iconfont'),size: 150.0, color: Colors.lightBlue),
              ),
              new MaterialButton(
                color: Colors.blue,
                textColor: Colors.white,
                minWidth: 150.0, // 控制按钮宽度
                child: new Text('查看钱包'),
                onPressed: () {
                  Navigator.popAndPushNamed(context, '/');
                },
              ),
            ],
          ),
        )
    );
  }
}

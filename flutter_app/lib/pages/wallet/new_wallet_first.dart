
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


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
        body: new Container(
          padding: const EdgeInsets.all(16.0), // 四周填充边距32像素
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
              new TextField(
                decoration: InputDecoration(
                  hintText: "输入钱包名称",
                ),
                onSubmitted: (text) async {//内容提交(按回车)的回调
                   print('钱包名称 =》 $text');
                   SharedPreferences prefs = await SharedPreferences.getInstance();
                   prefs.setString("new_wallet_name", text);
                   Navigator.pushNamed(context, "backup_wallet", arguments: <String, String>{});
//                   Navigator.pushNamed(context, "backup_wallet", arguments: <String, String>{
//                     'name': text,
//                   });
                },
              ),
              new Container(
                margin: const EdgeInsets.only(top: 50.0, bottom: 20.0),
                child: new Image.asset(
                    'images/fingerprint.png'
                ),
              ),
              new Text('开启指纹'),
              new Text('设置免密登录'),
//              new GestureDetector(
//                onTap: (){
//                  Navigator.pushNamed(context, "backup_wallet");
//                },//写入方法名称就可以了，但是是无参的
//                child: Text("点击这里进入备份提示页面"),
//              ),
            ],
          ),
        )
    );
  }
}

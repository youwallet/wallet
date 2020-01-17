
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youwallet/service/service_locator.dart';
import 'package:youwallet/service/local_authentication_service.dart';

class NewWalletName extends StatefulWidget {
  NewWalletName() : super();
  @override
  _NewWalletNameState createState()  => _NewWalletNameState();
}

class _NewWalletNameState extends State<NewWalletName> {

  final globalKey = GlobalKey<ScaffoldState>();
  final LocalAuthenticationService _localAuth = locator<LocalAuthenticationService>();
  TextEditingController _name = TextEditingController();

  void showSnackbar(String text) {
    final snackBar = SnackBar(content: Text(text));
    globalKey.currentState.showSnackBar(snackBar);
  }

  @override // override是重写父类中的函数
  void initState()  {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: globalKey,
        appBar: AppBar(
          title: Text("新建钱包"),
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
                controller: _name,
                decoration: InputDecoration(
                  hintText: "输入钱包名称",
                ),
              ),
              new SizedBox(
                height: 50.0,
              ),
              new MaterialButton(
                color: Colors.blue,
                textColor: Colors.white,
                minWidth: 150,
                child: new Text('下一步'),
                onPressed: () async {
                  if (_name.text.length == 0) {
                    this.showSnackbar('钱包名字不能为空');
                  } else {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    prefs.setString("new_wallet_name", _name.text);
                    Navigator.pushNamed(context, "keyboard_main").then((data){
                      print('你设置的交易密码是=》${data.toString()}');
                      prefs.setString("new_wallet_pw", data.toString());
                      Navigator.pushNamed(context, "backup_wallet", arguments: <String, String>{});
                    });
                  }
                },
              ),
//              new Container(
//                margin: const EdgeInsets.only(top: 50.0, bottom: 20.0),
//                child:  new GestureDetector(
//                  onTap: (){
//                    _localAuth.authenticate;
//                    this.showSnackbar('还不能识别指纹，直接输入钱包名字提交');
//                  },//写入方法名称就可以了，但是是无参的
//                  child: new Image.asset(
//                      'images/fingerprint.png'
//                  ),
//              ),
//              ),
//              new Text('开启指纹'),
//              new Text('设置免密登录'),
            ],
          ),
        )
    );
  }
}

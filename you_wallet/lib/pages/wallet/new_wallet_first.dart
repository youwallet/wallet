
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youwallet/service/service_locator.dart';
import 'package:youwallet/service/local_authentication_service.dart';
import 'package:youwallet/widgets/customButton.dart';

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
                  fillColor: Colors.black12,
                  filled: true,
                  hintText: "输入钱包名称",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0), // 设置圆角
                      borderSide: BorderSide.none // 设置不要边框
                  ),
                ),
              ),
              new SizedBox(
                height: 50.0,
              ),
              new CustomButton(
                  content: '下一步',
                  onSuccessChooseEvent:(res) async{
                    if (_name.text.length == 0) {
                      this.showSnackbar('钱包名字不能为空');
                    } else {
                      // 这里把名字直接保存在本地缓存中，不通过url传递
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      prefs.setString("new_wallet_name", _name.text);
                      Navigator.pushNamed(context, "backup_wallet", arguments: null);
//                    Navigator.pushNamed(context, "keyboard_main").then((data){
//                      print('你设置的交易密码是=》${data.toString()}');
//                      prefs.setString("new_wallet_pw", data.toString());
//                      Navigator.pushNamed(context, "backup_wallet", arguments: <String, String>{});
//                    });
                    }
                  }
              )
            ],
          ),
        )
    );
  }
}

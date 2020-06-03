
import 'package:flutter/material.dart';
import 'package:youwallet/service/token_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youwallet/widgets/customButton.dart';

class WalletMnemonic extends StatefulWidget {
  final arguments;

  WalletMnemonic({Key key ,this.arguments}) : super(key: key);

  @override
  Page createState()  => Page(arguments: this.arguments);
}

class Page extends State<WalletMnemonic> {

  Map arguments;
  Page({this.arguments});
  bool showBtn;

//  List randomMnemonic = [];
//  List randomMnemonicAgain = [];
  TextEditingController _name = TextEditingController();

  @override // override是重写父类中的函数 每次初始化的时候执行一次，类似于小程序中的onLoad
  void initState() {
    super.initState();
    String randomMnemonic = '';
    bool _showBtn = true;
    if (this.arguments == null) {
      randomMnemonic = TokenService.generateMnemonic();
    } else {
      randomMnemonic = this.arguments['mnemonic'];
      _showBtn = false;
    }
    setState(() {
      this._name.text = randomMnemonic;
      this.showBtn = _showBtn;
    });
  }


//  void setRandomMnemonic() async {
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    String randomMnemonic = prefs.getString("randomMnemonic");
//    setState(() {
////      this.randomMnemonic = randomMnemonic.split(' ');
//      this._name.text = randomMnemonic;
//    });
//  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("助记词"),
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
                controller: this._name,
                maxLines: 3,
                enabled: false,
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.black12,
                    contentPadding: new EdgeInsets.all(6.0), // 内部边距，默认不是0
                    border:InputBorder.none, // 没有任何边线
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.0),
                      borderSide: BorderSide(
                        width: 0, //边线宽度为2
                      ),
                    )
                ),
              ),
              new SizedBox(
                height: 50.0,
              ),
              new CustomButton(
                  content: '我已备份，下一步',
                  onSuccessChooseEvent:(res) async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    prefs.setString("randomMnemonic", this._name.text );
                    Navigator.of(context).pushReplacementNamed("wallet_check");
                  }
              ),

            ],
          ),
        )
    );
  }
}

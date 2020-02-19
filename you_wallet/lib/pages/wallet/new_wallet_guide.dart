
import 'package:flutter/material.dart';
import 'package:youwallet/widgets/customButton.dart';

class WalletGuide extends StatefulWidget {
  WalletGuide() : super();
  @override
  _WalletGuideState createState()  => _WalletGuideState();
}

class _WalletGuideState extends State<WalletGuide> {

  final globalKey = GlobalKey<ScaffoldState>();
  void showSnackbar(String text) {
    final snackBar = SnackBar(content: Text(text));
    globalKey.currentState.showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: globalKey,
        appBar: AppBar(
          title: Text(""),
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
              new CustomButton(
                content: '创建钱包',
                onSuccessChooseEvent:(res){
                  Navigator.pushNamed(context, "set_wallet_name");
                }
              ),
              new CustomButton(
                  content: '导入钱包',
                  onSuccessChooseEvent:(res){
                    Navigator.pushNamed(context, "load_wallet");
                  }
              )
            ],
          ),
        )
    );
  }
}

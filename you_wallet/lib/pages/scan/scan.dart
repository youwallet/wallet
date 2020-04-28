
import 'package:flutter/material.dart';
import 'package:youwallet/widgets/customButton.dart';

import 'package:provider/provider.dart';
import 'package:youwallet/model/wallet.dart';

class Scan extends StatefulWidget {

  final arguments;
  Scan({Key key,this.arguments}) : super(key: key);

  @override
  Page createState()  => Page();
}

class Page extends State<Scan> {

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
          elevation: Provider.of<Wallet>(context).items.length > 0 ? 3:0,
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

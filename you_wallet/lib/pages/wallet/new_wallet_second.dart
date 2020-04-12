

import 'package:flutter/material.dart';
import 'package:youwallet/widgets/customButton.dart';

class BackupWallet extends StatefulWidget {

  final arguments;
  // 构造函数
  BackupWallet({Key key ,this.arguments}) : super(key: key);


  @override
  BackupWalletState createState()  => BackupWalletState(arguments: this.arguments);
}

class BackupWalletState extends State<BackupWallet> {

  Map arguments;
  BackupWalletState({this.arguments});


  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: buildAppBar(context),
        body: new Container(
            color:Colors.white,
            alignment: Alignment.center,
            padding: const EdgeInsets.only(left: 60.0,right: 60.0), // 四周填充边距32像素
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Text(
                    '获取助记词等于拥有钱包资产所有权',
                    style: new TextStyle(
                        fontSize: 16.0,
                        height: 2
                    )
                ),
                new Container(
                  margin: const EdgeInsets.only(bottom: 30.0),
                  child: new Image.asset(
                      'images/backup.png'
                  ),
                ),
                new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildText(),
                ),
                new SizedBox(
                  height: 50.0,
                ),
                new CustomButton(
                    content: '下一步',
                    onSuccessChooseEvent:(res){
                      Navigator.of(context).pushReplacementNamed("wallet_mnemonic");
                    }
                ),
              ],
            ),
        )
    );
  }

  Widget buildAppBar(BuildContext context) {
    return new AppBar(
      title: const Text('备份提示')
    );
  }

  _buildText() {
    var arr = [
      {'val': '备份助记词', 'size': 18.0, 'height': 2},
      {'val': '使用纸和笔正确抄写助记词', 'size': 14.0, 'height': 2},
      {'val': '如果你饿手机丢失、被盗、损坏，助记词可帮助恢复你的资产', 'size': 14.0, 'height': 2}
    ];
    return arr.map(
            (data)=>new Text(
              data['val'],
              style: new TextStyle(
                  fontSize: data['size'],
              )
          ) ).toList();
  }
}


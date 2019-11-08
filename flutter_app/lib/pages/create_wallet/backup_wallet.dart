
import 'package:flutter/material.dart';


class BackupWallet extends StatefulWidget {
  BackupWallet() : super();
  @override
  BackupWalletState createState()  => BackupWalletState();
}

class BackupWalletState extends State<BackupWallet> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: buildAppBar(context),
        body: new Container(
          color:Colors.white,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(16.0), // 四周填充边距32像素
          child: Column(
            children: <Widget>[
              new Text(
                  '备份提示',
                  style: new TextStyle(
                      fontSize: 24.0,
                      height: 2
                  )
              ),
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
              new MaterialButton(
                color: Colors.blue,
                textColor: Colors.white,
                minWidth: 300,
                child: new Text('下一步'),
                onPressed: () {
                  // ...
                  Navigator.pushNamed(context, "load_wallet");
                },
              ),

            ],
          ),
        )
    );
  }

  Widget buildAppBar(BuildContext context) {
    return new AppBar(
      title: const Text('返回')
    );
  }

  _buildText() {
    var arr = [
      '使用纸和笔正确抄写助记词',
      '如果你的手机丢失，被盗，损坏，助记词可恢复你的资产'
    ];
    return arr.map( (data)=>new Text(data) ).toList();
  }
}

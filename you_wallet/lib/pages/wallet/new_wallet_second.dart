

import 'package:flutter/material.dart';
import 'package:youwallet/widgets/customButton.dart';

class BackupWallet extends StatefulWidget {

  final arguments;

  // 构造函数
  BackupWallet({Key key ,this.arguments}) : super(key: key);

  @override
  BackupWalletState createState()  => BackupWalletState();
}

class BackupWalletState extends State<BackupWallet> {

  List content1 = [
    {'val': '备份助记词', 'size': 20.0, 'height': 2, 'fontWeight': FontWeight.w600},
    {'val': '使用纸和笔正确抄写助记词', 'size': 14.0, 'height': 2,'fontWeight': FontWeight.w400},
    {'val': '如果你的手机丢失、被盗、损坏，助记词可帮助恢复你的资产', 'size': 14.0, 'height': 2,'fontWeight': FontWeight.w400},
  ];

  List content2 = [
    {'val': '离线保管', 'size': 20.0, 'height': 2,'fontWeight': FontWeight.w600},
    {'val': '妥善保管至隔离网络的安全地方', 'size': 14.0, 'height': 2,'fontWeight': FontWeight.w400},
    {'val': '请勿将助记词在联网环境下分享和存储，比如邮件、相册、社交应用等', 'size': 14.0, 'height': 2,'fontWeight': FontWeight.w400}
  ];


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
                  children: this.content1.map((data)=>new Text(
                      data['val'],
                      style: new TextStyle(
                        fontSize: data['size'],
                        fontWeight: data['fontWeight']
                      )
                  ) ).toList(),
                ),
                SizedBox(
                  height: 10.0,
                ),
                new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: this.content2.map((data)=>new Text(
                          data['val'],
                          style: new TextStyle(
                              fontSize: data['size'],
                              fontWeight: data['fontWeight']
                          )
                      ) ).toList(),
                ),
                new SizedBox(
                  height: 50.0,
                ),
                new CustomButton(
                    content: '下一步',
                    onSuccessChooseEvent:(res){
                      print(widget.arguments);
                      if (widget.arguments == null) {
                        Navigator.of(context).pushReplacementNamed("wallet_mnemonic");
                      } else {
                        // Navigator.of(context).pushReplacementNamed(widget.arguments.to);
                        Navigator.pushNamed(context, widget.arguments['to'], arguments: {
                          'res': widget.arguments['res'],
                          'allowCopy': false
                        });
                      }
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
//    var arr = [
//      {'val': '备份助记词', 'size': 18.0, 'height': 2},
//      {'val': '使用纸和笔正确抄写助记词', 'size': 14.0, 'height': 2},
//      {'val': '如果你饿手机丢失、被盗、损坏，助记词可帮助恢复你的资产', 'size': 14.0, 'height': 2}
//    ];
    return this.content1.map(
            (data)=>new Text(
              data['val'],
              style: new TextStyle(
                  fontSize: data['size'],
                  fontWeight: FontWeight.w800
              )
          ) ).toList();
  }
}


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TabReceive extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState

    return new Page();
  }
}

// 收款tab页
class Page extends State<TabReceive> {
  @override
  Widget build(BuildContext context) {
    return layout(context);
  }

  Widget layout(BuildContext context) {
    return new Scaffold(
      appBar: buildAppBar(context),
      body: new Center(
        child: new Container(
          width: 300.0,
          height: 200.0,

          decoration: new BoxDecoration(
            borderRadius: new BorderRadius.all(new Radius.circular(8.0)),
            color: Colors.lightBlue,
          ),
          child: new Column(
            children: <Widget>[
              new Text(
                  'ETH-Wallet',
                  style: new TextStyle(
                      fontSize: 24.0,
                      color: Colors.white
                  )
              ),
              new Text(
                  '0x0000000000000000000000',
                  style: new TextStyle(
                      fontSize: 18.0,
                      color: Colors.white
                  )
              ),
              new Container(
                padding: EdgeInsets.all(2.0),
                constraints: BoxConstraints(
                  minWidth: 100,
                ),
                decoration: new BoxDecoration(
                  borderRadius: new BorderRadius.all(new Radius.circular(4.0)),
                  color: Color.fromRGBO(0, 0, 0, .3),//设置颜色,.3代表透明度，也可以写成0.3
                ),

                child: GestureDetector(
                  child: Text(
                    '一键复制地址',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0
                    ),
                  ),
                  onTap: _copyAddress,
                ),
              ),
              new Container(
                  alignment: Alignment.center,
                  color: Color(0xFFFFFFFF),
                  child: new Image.asset(
                    'images/new_wallet.png', // 图片，已经在pubspec.yaml中定义
                    height: 100.0,
                    fit: BoxFit.cover,
                  ),

              ),
            ],
          ),
        )
      ),
    );
  }

  Widget buildAppBar(BuildContext context) {
    return new AppBar(
      title: const Text('收款'),
      actions: this.appBarActions(),
    );
  }
  // 定义bar右侧的icon按钮
  appBarActions() {
    return <Widget>[
      new Container(
        width: 50.0,
        child: new IconButton(
          icon: new Icon(Icons.share ),
          onPressed: () {
            // ...
            //Navigator.pushNamed(context, "login");
            // _getETHVersion();
            //_getETHVersionRPC();
          },
        ),
      )
    ];
  }

  void  _copyAddress() {
    ClipboardData data = new ClipboardData(text:"测试剪贴板复制功能");
    Clipboard.setData(data);
    showDialog<Null>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text('提示'),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                new Text('复制成功'),
              ],
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text('确定'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    ).then((val) {
      print(val);
    });
  }

//  Widget header(BuildContext context) {
//    return new Image.network(
//      'http://i2.yeyou.itc.cn/2014/huoying/hd_20140925/hyimage06.jpg',
//
//    );
//  }
}

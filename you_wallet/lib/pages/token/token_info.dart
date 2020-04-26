import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share/share.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:provider/provider.dart';
import 'package:youwallet/model/wallet.dart' ;
import 'package:youwallet/service/token_service.dart' ;

class TokenInfo extends StatefulWidget {

  final arguments;

  TokenInfo({Key key ,this.arguments}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState

    return new Page();
  }
}

// 收款tab页
class Page extends State<TokenInfo> {

  final globalKey = GlobalKey<ScaffoldState>();

  @override // override是重写父类中的函数
  void initState()  {
    print(widget.arguments);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return layout(context);
  }


  Widget layout(BuildContext context) {
    return new Scaffold(
      key: globalKey,
      appBar: buildAppBar(context),
      body: new Center(
          child: new Container(
                  padding: const EdgeInsets.only(top: 40.0),
                  width: 300.0,
                  decoration: new BoxDecoration(
                    borderRadius: new BorderRadius.all(new Radius.circular(8.0)),
                    color: Colors.lightBlue,
                  ),
                  constraints: BoxConstraints(
                    maxHeight: 279.0,
                  ),
                  child: new Column(
                    children: <Widget>[
                      new Text(
                          TokenService.maskAddress(widget.arguments['address']),
                          style: new TextStyle(
                              fontSize: 18.0,
                              color: Colors.white,
                            fontWeight: FontWeight.w800
                          )
                      ),
                      new Container(
                        padding: EdgeInsets.all(2.0),
                        margin: const EdgeInsets.all(10.0),
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
                          padding: const EdgeInsets.only(bottom: 20.0), // 四周填充边距32像素
                          color: Color(0xFFFFFFFF),
                          child: new Column(
                            children: <Widget>[
                              new Padding(
                                padding: new EdgeInsets.all(10.0),
                                child: new Text(
                                  widget.arguments['name']??'',
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      height: 2
                                  ),
                                ),
                              ),
                              QrImage(
//                                backgroundColor:Colors.white,
                                data: widget.arguments['address'] + ':token',
                                size: 100.0,
                              ),
                            ],
                          )
                      ),
                    ],
                  ),
                ),

          ),
      );
  }

  Widget buildAppBar(BuildContext context) {
    return new AppBar(
      title: Text('合约信息'),
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
            Share.share(widget.arguments['address']??'');
          },
        ),
      )
    ];
  }

  void  _copyAddress() {
    ClipboardData data = new ClipboardData(text:widget.arguments['address']);
    Clipboard.setData(data);
    this.showSnackbar('复制成功');
  }

  void showSnackbar(String text) {
    final snackBar = SnackBar(content: Text(text));
    globalKey.currentState.showSnackBar(snackBar);
  }

}

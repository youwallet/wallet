
import 'package:flutter/material.dart';


class LoadWallet extends StatefulWidget {
  LoadWallet() : super();
  @override
  LoadWalletState createState()  => LoadWalletState();
}

class LoadWalletState extends State<LoadWallet> {


  @override
  Widget build(BuildContext context) {
    return new DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: buildAppBar(context),
          body: new TabBarView(
            children: [
              buildPage('输入助记词,用空格分隔'),
              buildPage('输入私钥'),
            ],
          ),
        )
    );
  }

  Widget buildAppBar(BuildContext context) {
    return new AppBar(
        title: const Text('恢复身份'),
        actions: appBarActions(),
        bottom: new TabBar(
            tabs: [
              new Tab(text: '助记词'),
              new Tab(text: '私钥'),
            ]
        )

    );
  }

  // 定义bar右侧的icon按钮
  appBarActions() {
    return <Widget>[
      new Container(
        width: 50.0,
        child: new IconButton(
          icon: new Icon(Icons.camera_alt ),
          onPressed: () {

          },
        ),
      )
    ];
  }

  buildPage(placeholder){
    return new Container(
      child: new Column(
        children: <Widget>[
          new Container(
            padding: const EdgeInsets.all(32.0), // 四周填充边距32像素
            color: Colors.white,
            child: new TextField(
              maxLines: 3,
              decoration: InputDecoration(
                  filled: true,
                  hintText: placeholder,
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
              onChanged: (text) {
                print('change $text');
              },
            ),
          ),
          new Padding(
              padding: new EdgeInsets.all(30.0),
              child: new Text('免密设置')
          ),
          new Container(
            margin: const EdgeInsets.only(top: 10.0),
            child: new Image.asset(
                'images/fingerprint.png'
            ),
          ),
        ],
      ),
    );
  }
}

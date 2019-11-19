
import 'package:flutter/material.dart';
import 'package:bip39/bip39.dart' as bip39;


class LoadWallet extends StatefulWidget {
  LoadWallet() : super();
  @override
  LoadWalletState createState()  => LoadWalletState();
}

class LoadWalletState extends State<LoadWallet> {

  String randomMnemonic;
  TextEditingController _name = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _generateMnemonic();
    return new DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: buildAppBar(context),
          body: new TabBarView(
            children: [
              buildPage('输入助记词,用空格分隔'),
              buildPage('输入明文私钥'),
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
            child: new Column(
              children: <Widget>[
                buildText(placeholder),
                new TextField(
                  controller: this._name,
                  enabled: false,
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

                  onSubmitted: (text) {
                    print('change $text');
                  },
                ),
              ],
            )
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


  buildText(p) {
    if (p == '输入明文私钥') {
      return new Container(
        child: new Text('输入私钥文件内容至输入框，或通过扫描私钥内容生成的二维码录入，注意字符大小写。'),
      );
    } else {
      return new Container(
        child: null
      );
    }
  }

  _generateMnemonic() async {
    // 生成助记词字符串，12个随机单词
    String randomMnemonic = bip39.generateMnemonic();
    setState((){
      this._name.text = randomMnemonic; // 设置初始值
    });
    print('_generateMnemonic ====> $randomMnemonic');
    // 得到64字节种子
    String seed = bip39.mnemonicToSeedHex(randomMnemonic);
    // 还可以增加一个口令来生成种子，这样即使助记词丢失也还有一层保险
    // bip39.mnemonicToSeedHex(words, password);
    print('_generateMnemonic ====> $seed');

  }
}

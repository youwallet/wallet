
import 'package:flutter/material.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:bitcoin_flutter/bitcoin_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'package:web3dart/crypto.dart';
import 'package:ed25519_hd_key/ed25519_hd_key.dart';
import 'package:web3dart/credentials.dart';
import "package:hex/hex.dart";
//import 'package:stellar_hd_wallet/stellar_hd_wallet.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youwallet/service/local_authentication_service.dart';
import 'package:youwallet/service/service_locator.dart';
import 'package:youwallet/service/token_service.dart';
import 'package:youwallet/db/sql_util.dart';

import 'package:provider/provider.dart';
import 'package:youwallet/model/wallet.dart' as myWallet;



class LoadWallet extends StatefulWidget {
  LoadWallet() : super();
  @override
  LoadWalletState createState()  => LoadWalletState();
}


class LoadWalletState extends State<LoadWallet> {

  String name;
  String randomMnemonic;
  String privateKey;
  TextEditingController _name = TextEditingController();
  TextEditingController _key = TextEditingController();
  final LocalAuthenticationService _localAuth = locator<LocalAuthenticationService>();

  @override // override是重写父类中的函数 每次初始化的时候执行一次，类似于小程序中的onLoad
  void initState() {
    super.initState();
//    _getWalletName();
//    _generateMnemonic();
  }

  @override
  Widget build(BuildContext context) {
    return new DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: buildAppBar(context),
          body: new TabBarView(
            children: [
              buildPage('输入助记词,用空格分隔'),
              buildKeyPage('输入明文私钥'),
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
            print("123");
//            _localAuth.authenticate().then((result){
//              print(result);
//            });
          },
        ),
      )
    ];
  }

  // 构建助记词page
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
            child: GestureDetector(
               child: new Image.asset(
                   'images/fingerprint.png'
               ),
              onTap: () async {
                 print('click');
                 saveWallet();
//                 SharedPreferences prefs = await SharedPreferences.getInstance();
//                 prefs.setString("randomMnemonic", this._name.text);
//                 Navigator.pushNamed(context, "wallet_check");
              },
              )
          ),
        ],
      ),
    );
  }

  // 构建私钥page
  buildKeyPage(placeholder){
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
                    controller: this._key,
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
              child: GestureDetector(
                child: new Image.asset(
                    'images/fingerprint.png'
                ),
                onTap: () async {
                  saveWalletByKey();
//                 SharedPreferences prefs = await SharedPreferences.getInstance();
//                 prefs.setString("randomMnemonic", this._name.text);
//                 Navigator.pushNamed(context, "wallet_check");
                },
              )
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

  _getWalletName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String name = prefs.getString("new_wallet_name");
    print("new name => ${name}");
    setState(() {
      this.name = name;
    });
  }

  // bip39 https://pub.dev/packages/bip39

  _generateMnemonic() async {
    Map wallet = new Map();

    // 生成助记词字符串，12个随机单词
    String randomMnemonic = bip39.generateMnemonic();
    setState((){
      this._name.text = randomMnemonic; // 设置初始值
    });
    print('十二个助记词 ====> $randomMnemonic');
    // 得到128位随机数, 这是一个根私钥，master priviter key
    String hexSeed = bip39.mnemonicToSeedHex(randomMnemonic);
    //print("hexSeed ====》${hexSeed}");

    KeyData master = ED25519_HD_KEY.getMasterKeyFromSeed(hexSeed);
    final privateKey = HEX.encode(master.key);
    wallet['privateKey'] = privateKey;
    print("private: $privateKey");

    final private = EthPrivateKey.fromHex(privateKey);
    final address = await private.extractAddress();
    print("address: $address");
    wallet['address'] = address;

    wallet['name'] = this.name;

//    saveWallet(wallet);
  }

  /**
   *  通过助记词导入钱包
   */
  void saveWallet() async {

    String privateKey = TokenService.getPrivateKey(this._name.text);

    EthereumAddress ethereumAddress = await TokenService.getPublicAddress(privateKey);
    String address = ethereumAddress.toString();


    Map item = {
      'privateKey': privateKey,
      'address': address,
      'name': '',
      'mnemonic': this._name.text,
      'balance':''
    };

    this.doSave(item);
  }

  // 通过key导入钱包
  void saveWalletByKey() async {

    EthereumAddress ethereumAddress = await TokenService.getPublicAddress(this._key.text);
    String address = ethereumAddress.toString();

    Map item = {
      'privateKey': this._key.text,
      'address': address,
      'name': '',
      'mnemonic': '',
      'balance':''
    };

    this.doSave(item);
  }

  void doSave(Map item) async {
    String balance = await TokenService.getBalance(item['address']);
    item.addAll({'balance': balance});
    int id = await Provider.of<myWallet.Wallet>(context).add(item);
    print('insert into id => ${id}');



    if (id > 0) {
      Navigator.pushNamed(context, "tabs");
    } else {
      final snackBar = new SnackBar(content: new Text('钱包新建失败'));
      Scaffold.of(context).showSnackBar(snackBar);
    }
  }

}

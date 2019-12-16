
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


class LoadWallet extends StatefulWidget {
  LoadWallet() : super();
  @override
  LoadWalletState createState()  => LoadWalletState();
}


class LoadWalletState extends State<LoadWallet> {

  String name;
  String randomMnemonic;
  TextEditingController _name = TextEditingController();

  @override // override是重写父类中的函数 每次初始化的时候执行一次，类似于小程序中的onLoad
  void initState() {
    super.initState();
//    _getWalletName();
    _generateMnemonic();
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
              buildPage('输入明文私钥'),
            ],
          ),
        )
    );
  }

  Widget buildAppBar(BuildContext context) {
    return new AppBar(
        title: const Text('恢复身份'),
//        actions: appBarActions(),
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
            print("click carmer");
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
   * 利用Sqflite数据库存储数据
   */
  void saveWallet(wallet) async {
    final db = await getDataBase('wallet.db');
    db.transaction((trx) {
      trx.rawInsert(
          'INSERT INTO wallet(name, privateKey, address) VALUES("${wallet['name']}", "${wallet['privateKey']}", "${wallet['address']}")');
    });

    // 广播事件
//    eventBus.fire(EventAddToken(token));
  }

  /**
   * 初始化数据库存储路径
   */
  Future<Database> getDataBase(String dbName) async {
    //获取应用文件目录类似于Ios的NSDocumentDirectory和Android上的 AppData目录
    final fileDirectory = await getApplicationDocumentsDirectory();

    //获取存储路径
    final dbPath = fileDirectory.path;

    //构建数据库对象
    Database database = await openDatabase(dbPath + "/" + dbName, version: 1,
        onCreate: (Database db, int version) async {
          await db.execute("CREATE TABLE wallet (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, privateKey TEXT, address TEXT)");
        });

    return database;
  }
}

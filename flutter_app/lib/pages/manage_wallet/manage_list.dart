import 'package:flutter/material.dart';
import 'package:youwallet/widgets/walletList.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class ManageWallet extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState

    return new Page();
  }
}

class Page extends State<ManageWallet> {

  List wallets = [];

  @override // override是重写父类中的函数
  void initState() {
    super.initState();
    print("start state");
    this.getWallet();
  }

  @override
  Widget build(BuildContext context) {
    return layout(context);
  }

  Widget layout(BuildContext context) {
    return new Scaffold(
      appBar: buildAppBar(context),
      body: new Container(
        padding: const EdgeInsets.all(16.0),
        child: new ListView(
          children: <Widget>[
            new WalletList(arr: this.wallets),
//            new MaterialButton(
//              color: Colors.blue,
//              textColor: Colors.white,
//              minWidth: 300, // 控制按钮宽度
//              child: new Text('创建钱包'),
//              onPressed: () {
//                // ...
//                Navigator.pushNamed(context, "set_wallet_name");
//              },
//            ),
          ],
        ),
      ),
    );
  }

  Widget buildAppBar(BuildContext context) {
    return new AppBar(
      title: const Text('钱包管理'),
      actions: this.appBarActions(),
      //leading: new Icon(Icons.account_balance_wallet),
    );
  }

  // 定义bar右侧的icon按钮
  appBarActions() {
    return <Widget>[
      new Container(
        width: 50.0,
        child: new IconButton(
          icon: new Icon(Icons.add_circle_outline ),
          onPressed: () {
            Navigator.pushNamed(context, "wallet_guide");
          },
        ),
      )
    ];
  }

  /**
   * 每次页面show，触发首页token更新函数
   */
  void getWallet() async {
    final db = await getDataBase('wallet.db');
    List res = [];
    db.rawQuery('SELECT * FROM wallet').then((List<Map> lists) {
      print(lists);
      setState(() {
        this.wallets = lists;
      });
    });

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
          await db.execute("CREATE TABLE token (id INTEGER, address TEXT PRIMARY KEY, name TEXT, balance TEXT, rmb TEXT)");
        });

    return database;
  }
}

import 'package:flutter/material.dart';
import 'package:youwallet/widgets/walletList.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youwallet/bus.dart';

class ManageWallet extends StatefulWidget {
  final arguments;

  ManageWallet({Key key ,this.arguments}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState

    return new Page(arguments: this.arguments);
  }
}

class Page extends State<ManageWallet> {

  List wallets = [];
  String current_address = "";
  final arguments;

  Page({this.arguments});

  @override // override是重写父类中的函数
  void initState() {
    super.initState();
    setState(() {
      this.current_address = this.arguments['address'];
    });
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
          children: this.wallets.map((item) => walletCard(item)).toList()
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

  Widget walletCard(item) {

    return new Card(
        color: Colors.white, //背景色
        child:  GestureDetector(
          child: new Container(
              padding: const EdgeInsets.all(28.0),
              child: new Row(
                children: <Widget>[
                  new Container(
                    margin: const EdgeInsets.only(right: 16.0),
                    child: new Radio(
                      groupValue: this.current_address,
                      activeColor: Colors.blue,
                      value: item['address'],
                      onChanged: (v) {
                        // val 与 value 的类型对应
                        // 广播事件
                        eventBus.fire(WalletChangeEvent(v));
                        setState(() {
                          this.current_address = v;  // aaa
                        });
                      },
                    ),
                  ),
                  new Expanded(
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        new Text(
                          item['name'],
                          style: new TextStyle(fontSize: 32.0, color: Colors.black),
                        ),
                        new Text(item['address']),
                      ],
                    ),
                  ),
//                new Container(
//                    child: new Column(
//                      children: <Widget>[
//                        new Text(
//                          item['balance'],
//                          style: new TextStyle(fontSize: 16.0,
//                              color: Color.fromARGB(100, 6, 147, 193)),
//                        ),
//                        new Text('￥${item['rmb']}'),
//                      ],
//                    )
//
//                )
                ],
              )
          ),
          onTap: (){
            print("点击token =》 ${item}");
            setState(() {
              this.current_address = item['address'];  // aaa
            });
          },
        )
    );


  }
}

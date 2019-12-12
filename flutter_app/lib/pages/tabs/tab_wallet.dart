import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web3dart/json_rpc.dart';
import 'package:youwallet/widgets/tokenList.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dart_sql/dart_sql.dart';
//import 'package:barcode_scan/barcode_scan.dart';

class TabWallet extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new Page();
  }
}

class Page extends State<TabWallet> {

  String _scanResultStr = "";
  List<Map> tokenArr = [];


  @override // override是重写父类中的函数
  void initState() {
    super.initState();
    getTokens();
  }

  @override
  Widget build(BuildContext context) {
    return layout(context);
  }


  //扫码//  Future _scan() async {
  ////    //利用try-catch来进行异常处理
  ////    try {
  ////      //调起摄像头开始扫码
  ////      String barcode = await BarcodeScanner.scan();
  ////      setState(() {
  ////        return this._scanResultStr = barcode;
  ////      });
  ////    } on PlatformException catch (e) {
  ////      //如果没有调用摄像头的权限，则提醒
  ////      if (e.code == BarcodeScanner.CameraAccessDenied) {
  ////        setState(() {
  ////          return this._scanResultStr =
  ////          'The user did not grant the camera permission!';
  ////        });
  ////      } else {
  ////        setState(() {
  ////          return this._scanResultStr = 'Unknown error: $e';
  ////        });
  ////      }
  ////    } on FormatException {
  ////      setState(() => this._scanResultStr =
  ////      'null (User returned using the "back"-button before scanning anything. Result)');
  ////    } catch (e) {
  ////      setState(() => this._scanResultStr = 'Unknown error: $e');
  ////    }
  ////  }

  /**
   * 每次页面show，触发首页token更新函数
   */
  void getTokens() async {
    final db = await getDataBase('wallet.db');
    List res = [];
    db.rawQuery('SELECT * FROM tokens').then((List<Map> lists) {
      setState(() {
        this.tokenArr = lists;
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

  // 构建页面
  Widget layout(BuildContext context) {
    return new Scaffold(
      appBar: buildAppBar(context),
      body: new ListView(
        children: <Widget>[
          topCard(context),
          listTopBar(context),
          new Container(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0), // 四周填充边距32像素
            child: new tokenList(arr: tokenArr)
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: new Icon(Icons.add),
        onPressed: () => {
          Navigator.pushNamed(context, "set_wallet_name")
        }
      ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
                UserAccountsDrawerHeader(
                  accountName: Text(
                    'sibbay',
                    style: TextStyle( fontWeight: FontWeight.bold, ),
                  ),
                  accountEmail: Text('sibbay@example.com'),
                  currentAccountPicture: CircleAvatar( backgroundImage: NetworkImage('https://upyun-assets.ethfans.org/assets/ethereum-logo-fe43a240b78711a6d427e9638f03163f3dc88ca8c112510644ce7b5f6be07dbe.png'), ),
                  decoration: BoxDecoration(
                      color: Colors.black12,
                      image: DecorationImage(
                        image: NetworkImage( 'url'),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode( Colors.yellow.withOpacity(0.3), BlendMode.lighten, ),
                      )),
                ),

                ListTile(
                  title: Text('切换网络'),
                  leading: Icon(Icons.network_check),
                  onTap: () {
                    Navigator.pushNamed(context, "set_network");
                  },
                ),
                ListTile(
                  title: Text('检查更新'),
                  leading: Icon(Icons.update),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  title: Text('进入调试'),
                  leading: Icon(Icons.adb),
                  onTap: () {
                    Navigator.pushNamed(context, "debug_page");
                  },
                ),
            ],
          ),
        )
    );
  }

  // 构建AppBar
  Widget buildAppBar(BuildContext context) {
    return new AppBar(
        title: const Text('youwallet'),
//        leading: IconButton(
//          icon: new Icon(Icons.menu),
//          onPressed: () {
//            print('this is home menu');
//            showModalBottomSheet(
//              context: context,
//              builder: (BuildContext context) {
//                return GestureDetector(
//                  child: Container(
//                    height: 2000.0,
//                    color: Color(0xfff1f1f1),
//                    child: Center(
//                      child: Text("这里是钱包列表，选择钱包"),
//                    ),
//                  ),
//                  onTap: () => false,
//                );
//              },
//            );
//          },
//        ),
        actions: this.appBarActions(),
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
            // httpRequest();
//            _scan();
          },
        ),
      )
    ];
  }

  // 构建顶部卡片
  Widget topCard(BuildContext context) {
    return new Container(
        padding: const EdgeInsets.all(16.0), // 四周填充边距32像素
        margin: const EdgeInsets.all(16.0),
        alignment: Alignment.center,
        decoration: new BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                  "images/homebk.png",
              ),
              fit: BoxFit.fill
            ),
        ),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             new Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: <Widget>[
                 new Text(
                     '我的钱包',
                     style: new TextStyle(
                         color: Colors.white
                     )
                 ),
                 new IconButton(
                   icon: new Icon(
                       Icons.settings,
                       color: Colors.white
                   ),
                   onPressed: () {
                     // ...
                     Navigator.pushNamed(context, "manage_wallet");
                   },
                 ),
               ],
             ),
            new Text(
                'KDA',
                style: new TextStyle(
                    color: Colors.white
                )
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Text(''),
                new Text(
                    '￥30000.00',
                    style: new TextStyle(
                      fontSize: 32.0, color: Colors.white
                    )
                ),
              ],
            ),


          ]
        )

    );
  }

  // 构建列表的表头菜单
  Widget listTopBar(BuildContext context) {
    return new Container(
      padding: const EdgeInsets.only(left: 16.0, right:16.0, top: 0),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          new Text('Token'),
          new IconButton(
              icon: new Icon(Icons.add_circle_outline ),
              onPressed: () {
                  Navigator.pushNamed(context, "add_wallet");
              },
          ),
        ],
      ),
    );
  }
}



import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:web3dart/json_rpc.dart';
import 'package:youwallet/widgets/menu.dart';
import 'package:youwallet/widgets/loadingDialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youwallet/widgets/tokenList.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import 'package:youwallet/bus.dart';



class AddWallet extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    // SHT 0x3d9c6c5a7b2b2744870166eac237bd6e366fa3ef
    return new Page();
  }
}

class Page extends State<AddWallet> {

  List tokenArr = new List();
  Map token = new Map();

  @override
  Widget build(BuildContext context) {
    getTokens();
    return layout(context);
  }

  Widget layout(BuildContext context) {
    return new Scaffold(
      appBar: buildAppBar(context),
      body: new Container(
        padding: const EdgeInsets.all(16.0),
        child: new ListView(
          children: <Widget>[
            buildTokenList(this.tokenArr)
          ],
        ),
      ),
    );
  }

  // 构建顶部tabBar
  Widget buildAppBar(BuildContext context) {
    return new AppBar(
      title: new TextField(
        decoration: InputDecoration(
            hintText: "输入合约地址",
            fillColor: Colors.black12,
            contentPadding: new EdgeInsets.all(6.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6.0),
            )
        ),
        onSubmitted: (text) {//内容提交(按回车)的回调
          searchToken(text);
          showDialog<Null>(
              context: context, //BuildContext对象
              barrierDismissible: false,
              builder: (BuildContext context) {
                return new LoadingDialog( //调用对话框
                  text: '搜索中...',
                );
              });
        },
//        onChanged: (text) {//内容改变的回调
//          print('change $text');
//          LoadingDialog(
//              text: '搜索中···'
//          );
//        },
      ),
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
            // ...
            //Navigator.pushNamed(context, "login");
            // _getETHVersion();
            showDialog<Null>(
                context: context, //BuildContext对象
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return new LoadingDialog( //调用对话框
                    text: '搜索中...',
                  );
                });
            searchToken('0xC13D3E66BB3373596815070CA8f67a50cb0cF104');
          },
        ),
      )
    ];
  }

  // SHT智能合约地址,测试用
  // 0x3d9c6c5a7b2b2744870166eac237bd6e366fa3ef
  void searchToken(String address) async{
    var client = Client();
    var payload = {
      "jsonrpc": "2.0",
      "method": "eth_call",
      "params": [{
        "to": address,
        "data": "0x95d89b41"
      },"latest"],
      "id": DateTime.now().millisecondsSinceEpoch
    };
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String network = prefs.getString('network');
    print(network);
    var rsp = await client.post(
        'https://' + network + '.infura.io/',
        headers:{'Content-Type':'application/json'},
        body: json.encode(payload)
    );
    Map result = jsonDecode(rsp.body);
    if (result.containsKey('error') ) {
      print('请检查token地址');
    } else {
      String res = result['result'];
      print("name => ${res}");
      String name = res.replaceFirst('0x', '');
      String nameString = '';
      for(var i = 0; i < name.length; i = i + 2) {
        if (name.substring(i, i+2) != "00") {
          nameString = nameString + String.fromCharCode(int.parse(name.substring(i, i+2), radix: 16));
        }
      }

      token['address'] = address;
      token['name'] = nameString;
    }

    Navigator.pop(context);
    getBanance(address);
  }

  // 获取合约代币余额
  void getBanance(String address) async {
    var client = Client();
    var payload = {
      "jsonrpc": "2.0",
      "method": "eth_getBalance",
      "params": [address,"latest"],
      "id": DateTime.now().millisecondsSinceEpoch
    };
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String network = prefs.getString('network');
    var rsp = await client.post(
        'https://' + network + '.infura.io/',
        headers:{'Content-Type':'application/json'},
        body: json.encode(payload)
    );

    print(rsp.statusCode);
    print(rsp.body);
    Map result = jsonDecode(rsp.body);
    print("banance => ${result['result']}");
//    int balance = int.parse(result['result'].replaceFirst('0x', '').substring(0), radix: 16);
    token['balance'] = result['result'];
    tokenArr.add(token);

    setState((){
      this.tokenArr = tokenArr; // 设置初始值
    });
    saveToken(token);
  }


  // 将搜索到的token填充到页面中
  buildTokenList(arr) {
    return new tokenList(arr: arr);
  }

  /**
   * 初始化数据库存储路径
   */
  Future<Database> getDataBase(String dbName) async {
    //获取应用文件目录类似于Ios的NSDocumentDirectory和Android上的 AppData目录
    final fileDirectory = await getApplicationDocumentsDirectory();
    print(fileDirectory);


    //获取存储路径
    final dbPath = fileDirectory.path;
    print(dbPath);

    //构建数据库对象
    Database database = await openDatabase(dbPath + "/" + dbName, version: 1,
        onCreate: (Database db, int version) async {
          await db.execute("CREATE TABLE tokens (id INTEGER PRIMARY KEY, address TEXT, name TEXT, balance TEXT, rmb TEXT)");
        });

    return database;
  }

  /**
   * 利用Sqflite数据库存储数据
   */
  saveToken(token) async {
    getTokens();
    final db = await getDataBase('wallet.db');
    //写入字符串
    db.transaction((trx) {
      trx.rawInsert(
          'INSERT INTO tokens(address, name, balance, rmb) VALUES("${token['address']}", "${token['name']}", "${token['balance']}","${token['rmb']}")');
    });

    // 广播事件
    eventBus.fire(EventAddToken(token));
  }

  void getTokens() async {
    print("读取数据库");
    final db = await getDataBase('wallet.db');
    List res = [];
    db.rawQuery('SELECT * FROM tokens').then((List<Map> lists) {
      print(lists);
      res = lists;
    });
    print(res);
  }


}




//var path = "https://www.wanandroid.com/user/register";
//var params = {
//  "username": "aa112233",
//  "password": "123456",
//  "repassword": "123456"
//};
//Response response =
//    await Dio().post(path, queryParameters: params);
//this.setState(() {
//result= response.toString();
//});

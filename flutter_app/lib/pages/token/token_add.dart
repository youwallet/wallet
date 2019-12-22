import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:web3dart/json_rpc.dart';
import 'package:youwallet/service/token_service.dart';
import 'package:youwallet/widgets/menu.dart';
import 'package:youwallet/widgets/loadingDialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youwallet/widgets/tokenList.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import 'package:youwallet/bus.dart';

import 'package:provider/provider.dart';
import 'package:youwallet/model/token.dart';

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
        onSubmitted: (text) async {//内容提交(按回车)的回调
//          showDialog<Null>(
//              context: context, //BuildContext对象
//              barrierDismissible: false,
//              builder: (BuildContext context) {
//                return new LoadingDialog( //调用对话框
//                  text: '搜索中...',
//                );
//              });
          Map token = await TokenService.searchToken(text);
//          Navigator.pop(context);
          if (token.containsKey('name')) {
            setState(() {
              this.tokenArr.add(token);
            });
            saveToken(token);
          } else {

          }

        },
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
//            showDialog<Null>(
//                context: context, //BuildContext对象
//                barrierDismissible: false,
//                builder: (BuildContext context) {
//                  return new LoadingDialog( //调用对话框
//                    text: '搜索中...',
//                  );
//                });
//            searchToken('0xC13D3E66BB3373596815070CA8f67a50cb0cF104');
          },
        ),
      )
    ];
  }

  // SHT智能合约地址,测试用
  // 0x3d9c6c5a7b2b2744870166eac237bd6e366fa3ef


  // 将搜索到的token填充到页面中
  buildTokenList(arr) {
    return new tokenList(arr: arr);
  }

  void saveToken(Map token) async {
    int id = await Provider.of<Token>(context).add(token);
    print(id);
//    final snackBar = new SnackBar(content: new Text('添加成功token'));
//    Scaffold.of(context).showSnackBar(snackBar);
  }

}


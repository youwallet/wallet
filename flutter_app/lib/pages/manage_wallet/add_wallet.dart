import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:web3dart/json_rpc.dart';
import 'package:youwallet/widgets/menu.dart';
import 'package:youwallet/widgets/loadingDialog.dart';

class AddWallet extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState

    return new Page();
  }
}

class Page extends State<AddWallet> {

  @override
  Widget build(BuildContext context) {
    return layout(context);
  }

  Widget layout(BuildContext context) {
    getSignFuncName();
    return new Scaffold(
      appBar: buildAppBar(context),
      body: new Container(
        padding: const EdgeInsets.all(16.0),
        child: new ListView(
          children: <Widget>[

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
          print('submit $text');
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
          },
        ),
      )
    ];
  }

  // 请求以太坊主网信息

  // SHT智能合约地址
  // https://etherscan.io/address/0x3d9c6c5a7b2b2744870166eac237bd6e366fa3ef
  void searchToken(String address) async{
//    var httpClient = new Client();
//    var web3Client = new Web3Client('https://mainnet.infura.io/',httpClient);
    var client = Client();
    var payload = {
      "jsonrpc": "2.0",
      "method": "eth_call",
      "params": ['name'],
      "id": DateTime.now().millisecondsSinceEpoch
    };
    var rsp = await client.post(
        'https://mainnet.infura.io/',
        headers:{'Content-Type':'application/json'},
        body: json.encode(payload)
    );
    print('rsp code => ${rsp.statusCode}');
    print('rsp body => ${rsp.body}');
    Navigator.pop(context);
  }

  // 获取方法的签名
  void  getSignFuncName() async{
//    var httpClient = new Client();
//    var web3Client = new Web3Client('https://mainnet.infura.io/',httpClient);
    var client = Client();
    var payload = {
      "jsonrpc": "2.0",
      "method": "web3_sha3",
      "params": ['name()'],
      "id": DateTime.now().millisecondsSinceEpoch
    };
    var rsp = await client.post(
        'https://mainnet.infura.io/',
        headers:{'Content-Type':'application/json'},
        body: json.encode(payload)
    );
    print('rsp code => ${rsp.statusCode}');
    print('rsp body => ${rsp.body}');
    Navigator.pop(context);
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

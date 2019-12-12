import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:youwallet/widgets/priceNum.dart';
import 'package:youwallet/widgets/transferList.dart';

import 'package:http/http.dart';
import 'dart:convert';
import 'package:steel_crypt/steel_crypt.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/crypto.dart';
import 'dart:convert';
import 'package:dart_sql/dart_sql.dart';

import 'package:sqflite/sqflite.dart' as sqllite;
import 'package:path_provider/path_provider.dart';

import 'package:event_bus/event_bus.dart';
import 'package:youwallet/bus.dart';

class TabExchange extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new Page();
  }
}

class Page extends State {

  BuildContext mContext;


  //数据初始化
  @override
  void initState() {
    super.initState();

    // 初始化的时候，就加载tokens列表
    _setTokens();

    // 监听token添加事件
    eventBus.on<EventAddToken>().listen((event) {
      _setTokens();
    });
  }

  @override
  Widget build(BuildContext context) {
    print('进入 tab exchange build');
    return layout(context);
  }

  var value;
  String _btnText="买入";
  List tokens = [];

  // 每次进入交易页面，加载当前用户私钥, 我在metamask上注册的测试用钱包私钥
  final privateKey = "279EFAC43AAE9405DCD9A470B9228C1A3C0F2DEFC930AD1D9B764E78D28DB1DF";

  // 我在metaMask上注册的钱包地址，这个地址可以经由私钥进行椭圆曲线算法推倒而来
  final myAddress = "AB890808775D51e9bF9fa76f40EE5fff124deCE5";

  // youwalllet的合约地址
  final contractAddress= "0x7E999360d3327fDA8B0E339c8FC083d8AFe6A364";

  // 收取交易费的地址
  final relayerAddress = "0000000000000000000000003d9c6c5a7b2b2744870166eac237bd6e366fa3ef"; // 收取交易费的账户，暂时用SHT的合约账户

  // 以太坊水龙头合约地址
  final faucet = "0x81b7E08F65Bdf5648606c89998A9CC8164397647";

  // 以太坊url
  final String rpcUrl = "https://ropsten.infura.io/";
  // 构建页面
  Widget layout(BuildContext context) {
    return new Scaffold(
      appBar: buildAppBar(context),
      body: new Container(
        padding: const EdgeInsets.all(16.0), // 四周填充边距32像素
        child: new Column(
          children: <Widget>[
            buildPageTop(context),
            new Container(
              height: 1.0,
              color: Colors.black12,
              margin: const EdgeInsets.only(top: 16.0, bottom: 16.0),
              child: null,
            ),
            transferList()
          ],
        )
      ),
    );
  }

  // 构建顶部标题栏
  Widget buildAppBar(BuildContext context) {
    return new AppBar(title: const Text('兑换'));
  }

  // 构建页面上半部分区域
  Widget buildPageTop(BuildContext context) {
    return Container(
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          //左边一列
          new  Expanded(
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Text('Token'),
                new Container(
                  padding: const EdgeInsets.only(left: 10.0),
                  margin: const EdgeInsets.only(bottom: 10.0),
                  decoration: new BoxDecoration(
                    borderRadius: new BorderRadius.all(new Radius.circular(6.0)),
                    border: new Border.all(width: 1.0, color: Colors.black12),
                    color: Colors.black12,
                  ),
                  child: new DropdownButton(
                    items: getListData(),
                    hint:new Text('选择币种'),//当没有默认值的时候可以设置的提示
                    value: value,//下拉菜单选择完之后显示给用户的值
                    onChanged: (T){//下拉菜单item点击之后的回调
                      setState(() {
                        value=T;
                      });
                    },
                    isDense: true,
                    elevation: 24,//设置阴影的高度
                    style: new TextStyle(//设置文本框里面文字的样式
                        color: Colors.black
                    ),
                  ),
                ),
                new Container(
                  child: new Row(
                    children: <Widget>[
                      new Expanded(
                          child: OutlineButton(
                            onPressed: () {
                              changeOrderModel('买入');
                            },
                            child: Text('买入'),
                            borderSide: BorderSide(
                                color: Colors.green,
                                width: 1.0,
                                style: BorderStyle.solid
                            ),
                          ),
                          flex: 1
                      ),
                      new Expanded(
                          child: OutlineButton(
                            onPressed: () {
                              changeOrderModel('卖出');
                            },
                            child: Text('卖出'),
                            borderSide: BorderSide(
                                color: Colors.green,
                                width: 0.0,
                                style: BorderStyle.solid
                            ),
                          ),
                          flex: 1
                      )
                    ],
                  )
                ),
                new Text('限价模式'),
                new ConstrainedBox(
                    constraints: BoxConstraints(
                        maxHeight: 25,
                        maxWidth: 200
                    ),
                    child: new TextField(
                      decoration: InputDecoration(// 输入框内部右侧增加一个icon
                          suffixText: 'EOS',//位于尾部的填充文字
                          suffixStyle: new TextStyle(
                              fontSize: 14.0,
                              color: Colors.black38
                          ),
                          hintText:"输入买入数量",
                          filled: true, // 填充背景颜色
                          fillColor: Colors.black12,
                          contentPadding: new EdgeInsets.all(6.0), // 内部边距，默认不是0
                          border:InputBorder.none, // 没有任何边线
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            borderSide: BorderSide(
                              color: Colors.black12, //边线颜色为黄色
                              width: 1, //边线宽度为2
                            ),
                          )
                      ),
                      onSubmitted: (text) {//内容提交(按回车)的回调
                        print('submit $text');
                      },
                    ),

                ),
                new Text('约=￥0.001元'),
                new Container(
                  height: 10.0,
                  child: null,
                ),
                new ConstrainedBox(
                  constraints: BoxConstraints(
                      maxHeight: 25,
                      maxWidth: 200
                  ),
                  child: new TextField(
                    decoration: InputDecoration(// 输入框内部右侧增加一个icon
                        suffixText: 'EOS',//位于尾部的填充文字
                        suffixStyle: new TextStyle(
                            fontSize: 14.0,
                            color: Colors.black38
                        ),
                        hintText:"输入买入价格",
                        filled: true, // 填充背景颜色
                        fillColor: Colors.black12,
                        contentPadding: new EdgeInsets.all(6.0), // 内部边距，默认不是0
                        border:InputBorder.none, // 没有任何边线
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6.0),
                          borderSide: BorderSide(
                            color: Colors.black12, //边线颜色为黄色
                            width: 1, //边线宽度为2
                          ),
                        )
                    ),
                    onSubmitted: (text) {//内容提交(按回车)的回调
                      print('submit $text');
                    },
                  ),

                ),
                new Text('当前账户余额0.1234EOS'),
                new Container(

                  padding: new EdgeInsets.only(top: 30.0),
                  child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                      new Text('交易额0.123EOS'),
                      new SizedBox(
                        width: double.infinity,
                        height: 30,
                        child: RaisedButton(
                            elevation: 0,
                            onPressed: () {
                              // =============================
                              //makeOrder();
//                              getConfigData();
                                //getBQODHash();
                              _setTokens();
                              // =============================
                            },
                            child: Text(
                                this._btnText,
                                style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.white
                                )
                            ),
                            color: Colors.green,
                            textColor: Colors.white,
                          ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          new Container(
            width: 50.0,
            child: null,
          ),
          // 右边一列
          new  Expanded(
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Text('Base Token'),
                new Container(
                  padding: const EdgeInsets.only(left: 10.0),
                  margin: const EdgeInsets.only(bottom: 10.0),
                  decoration: new BoxDecoration(
                    borderRadius: new BorderRadius.all(new Radius.circular(6.0)),
                    border: new Border.all(width: 1.0, color: Colors.black12),
                    color: Colors.black12,
                  ),
                  child: new DropdownButton(
                    items: getListData(),
                    hint:new Text('选择币种'),//当没有默认值的时候可以设置的提示
                    value: value,//下拉菜单选择完之后显示给用户的值
                    onChanged: (T){//下拉菜单item点击之后的回调
                      setState(() {
                        value=T;
                      });
                    },
                    isDense: true,
                    elevation: 24,//设置阴影的高度
                    style: new TextStyle(//设置文本框里面文字的样式
                        color: Colors.black
                    ),
                  ),
                ),
                buildRightWidget()
              ],
            ),

          ),
        ],
      ),
    );
  }

  // 构建页面左侧token区域
  Widget buildPageToken(BuildContext context) {
    return new Column(
      children: <Widget>[


      ],
    );
  }

  // 更改下单模式
  void changeOrderModel(String text) {
    setState(() {
      this._btnText = text;
    });
  }


  // 交易参数的设置, 包含hydro版本号、交易买卖标志等
  // getConfigData(bool) 经过sha3加密后取前四位feee047e
  // 卖单true : 0000000000000000000000000000000000000000000000000000000000000001
  // 买单false : 0000000000000000000000000000000000000000000000000000000000000000
  void getConfigData() async{
    var client = Client();
    var payload = {
      "jsonrpc": "2.0",
      "method": "eth_call",
      "params": [
        {
          "from":"0x7E999360d3327fDA8B0E339c8FC083d8AFe6A364",
          "to": contractAddress,
          "data": "0xfeee047e0000000000000000000000000000000000000000000000000000000000000001"
        },
        "latest"
      ],
      "id": DateTime.now().millisecondsSinceEpoch
    };

    var rsp = await client.post(
        'https://ropsten.infura.io/',
        headers:{'Content-Type':'application/json'},
        body: json.encode(payload)
    );
    print('rsp code => ${rsp}');
    print('rsp code => ${rsp.statusCode}');
    print('rsp body => ${rsp.body}');
    // 参数为true，执行结果为0x020100005def248f025802580000000000000000000000000000000000000000
  }

  /*
  * 获取订单相关hash值
  */
  void  getBQODHash() async {

    String functionName = '0xefe331cf';
    String address = "AB890808775D51e9bF9fa76f40EE5fff124deCE5";
    // 参数一
    String trader = '000000000000000000000000' + address; // 钱包的address
    print(trader);
    String baseTokenAmount = '0000000000000000000000000000000000000000000000000000000000000100';
    String quoteTokenAmount= '0000000000000000000000000000000000000000000000000000000000000100';
    String gasTokenAmount =  '0000000000000000000000000000000000000000000000000000000000000000';
    String data = '020100005def248f025802580000000000000000000000000000000000000000';
    String signature = data + data + data;  // 此时还没有signature字段，所以随便填充三个32byte的字段

    // 参数二
    String baseToken = "0000000000000000000000008F48de31810deaA8bF547587438970EBD2e4be16";
    String quoteToken= "000000000000000000000000414b26708362B024A28C7Bc309D5C1a8Ac14647E";
    String relayer =   relayerAddress;

    String post_data = functionName + trader + baseTokenAmount + quoteTokenAmount + gasTokenAmount + data + signature + baseToken + quoteToken + relayer;

    var client = Client();
    var payload = {
      "jsonrpc": "2.0",
      "method": "eth_call",
      "params": [
        {
          "from":"0x7E999360d3327fDA8B0E339c8FC083d8AFe6A364",
          "to": contractAddress, // 合约地址
          "data": post_data
        },
        "latest"
      ],
      "id": DateTime.now().millisecondsSinceEpoch
    };

    var rsp = await client.post(
        'https://ropsten.infura.io/',
        headers:{'Content-Type':'application/json'},
        body: json.encode(payload)
    );

    Map result = jsonDecode(rsp.body);
    print('bq_hash => ${rsp.body}');
    String  res = result['result'].replaceFirst("0x", ""); // 得到一个64字节的数据
    print('getBQODHash => ${res}');
    String bq_hash = res.substring(0,64);
    String od_hash = res.substring(64);
    print('od_hash => ${od_hash}');
    print('bq_hash => ${bq_hash}');
    print('进入签名');
    ethSign(od_hash);
  }

  // 调用web3dart，对od_hash使用私钥进行签名，这一步必须在客户端做
  void ethSign(String od_hash) async {
    final key = EthPrivateKey(hexToBytes(privateKey));
    final signature = await key.sign(hexToBytes(od_hash), chainId: 3);
    final sign = bytesToHex(signature);
    final r = sign.substring(0,64);
    final s = sign.substring(64,128);
    final v = sign.substring(128);
    print('r => ${r}');
    print('s => ${s}');
    print('v => ${v}');
    getConfigSignature(v,r,s,'1');
  }

  /* 获取交易签名数据
 * v: 签名v值
 * r: 签名r值
 * s: 签名s值
 * signMethod: 签名方法, 0为eth.sign, 1为EIP712
 *
 * 返回值：
 * OrderSignature 结构体
 * function getConfigSignature(bytes1 v,  bytes32 r, bytes32 s, uint8 signMethod);
 * */
  void getConfigSignature(String v,  String r, String s, String signMethod) async {

    String functionHex = "0x0b973ca2";
    String _v = v + "00000000000000000000000000000000000000000000000000000000000000";
    String _signMethod = "000000000000000000000000000000000000000000000000000000000000000" +  signMethod; // signMethod: 签名方法, 0为eth.sign, 1为EIP712
    String post_data = functionHex + _v + r + s + _signMethod;

    var client = Client();
    var payload = {
      "jsonrpc": "2.0",
      "method": "eth_call",
      "params": [
        {
          "from":"0x7E999360d3327fDA8B0E339c8FC083d8AFe6A364",
          "to": contractAddress, // 合约地址
          "data": post_data
        },
        "latest"
      ],
      "id": DateTime.now().millisecondsSinceEpoch
    };

    var rsp = await client.post(
        'https://ropsten.infura.io/',
        headers:{'Content-Type':'application/json'},
        body: json.encode(payload)
    );

    print('rsp code => ${rsp.statusCode}');
    print('rsp body => ${rsp.body}');
    Map result = jsonDecode(rsp.body);
    String  res = result['result'].replaceFirst("0x", "");

    takeOrder(res);
  }

  // 下单
  void takeOrder(String sign) async{
    print('开始下单');


    String functionName = '0xefe29415';

    // 参数一
    String trader = '000000000000000000000000AB890808775D51e9bF9fa76f40EE5fff124deCE5'; // 我的钱包的address
    print(trader);
    String baseTokenAmount = '0000000000000000000000000000000000000000000000000000000000000100';
    String quoteTokenAmount= '0000000000000000000000000000000000000000000000000000000000000100';
    String gasTokenAmount =  '0000000000000000000000000000000000000000000000000000000000000000';
    String data = '020100005def248f025802580000000000000000000000000000000000000000';  // 卖单
    String signature = sign;  // 此时还没有signature字段，所以随便填充三个32byte的字段

    // 参数二
    String baseToken = "0000000000000000000000008F48de31810deaA8bF547587438970EBD2e4be16";
    String quoteToken= "000000000000000000000000414b26708362B024A28C7Bc309D5C1a8Ac14647E";
    String relayer =   relayerAddress; // SHT合约地址

    String post_data = functionName + trader + baseTokenAmount + quoteTokenAmount + gasTokenAmount + data + signature + baseToken + quoteToken + relayer;


    final client = Web3Client(rpcUrl, Client());

    // 加载私钥，准备加密
    var credentials = await client.credentialsFromPrivateKey(privateKey);

    var rsp = await client.sendTransaction(
      credentials,
      Transaction(
        to: EthereumAddress.fromHex(faucet),
        gasPrice: EtherAmount.inWei(BigInt.one),
        maxGas: 100000,
        value: EtherAmount.fromUnitAndValue(EtherUnit.ether, 0),
        data: hexToBytes(post_data)
      ),
        chainId: 3
    );

    await client.dispose();
    print('rsp code => ${rsp}'); // 返回值0x76a2fc80d8b14f9fa70e3f079509f92aa855acfc1351d444a17c14e4b87e3eaf，这是一个Transaction Hash

  }



  // 构建页面下拉列表
  List<DropdownMenuItem> getListData(){

    print("进入getListData => ${tokens}");
    List<DropdownMenuItem> items=new List();

    for (var value in tokens) {
      print(value);  // 循环打印 true 100 a 华为
      items.add(new DropdownMenuItem(
        child:new Text(value['name']),
        value: value['address'],
      ));
    }

//    List<DropdownMenuItem> items=new List();
//    items.add(new DropdownMenuItem(
//      child:new Text('1'),
//      value: '1',
//    ));
//    items.add(
//        new DropdownMenuItem(
//          child:new Text('2'),
//          value: '2',
//        ),
//    );
    return items;
  }

  // 构建左侧区域
  Widget buildLeftWidget() {
    return Container(
      child: new Column(
        children: <Widget>[
          new Container(
            child: new TextField(
              onChanged: (text) {//内容改变的回调
                print('change $text');
              },
              onSubmitted: (text) {//内容提交(按回车)的回调
                print('submit $text');
              },
            ),
          ),
          new Row(
            children: <Widget>[
              new MaterialButton(
                color: Colors.blue,
                textColor: Colors.white,
                child: new Text('买入SHT'),
                onPressed: () {
                  // ...
                  Navigator.pushNamed(context, "token_history");
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  // 构建右侧区域
  Widget buildRightWidget() {
    return Container(
      child: new Column(
        children: <Widget>[
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Text('价格EOS'),
              new Text('价格SHT'),
            ],
          ),
          priceNum()
        ],
      ),
    );
  }


  /**
   * 每次页面show，触发首页token更新函数
   */
  void _setTokens() async {
    final db = await getDataBase('wallet.db');
    List res = [];
    db.rawQuery('SELECT * FROM tokens').then((List<Map> lists) {
      setState(() {
        this.tokens = lists;
      });
    });

  }

  /**
   * 初始化数据库存储路径
   */
  Future<sqllite.Database> getDataBase(String dbName) async {
    //获取应用文件目录类似于Ios的NSDocumentDirectory和Android上的 AppData目录
    final fileDirectory = await getApplicationDocumentsDirectory();

    //获取存储路径
    final dbPath = fileDirectory.path;
    print(dbPath);
    // /Users/zhaobinglong/Library/Developer/CoreSimulator/Devices/037DA882-FA4E-4328-80BE-4BCB84E2C47A/data/Containers/Data/Application/682A61BA-A7CF-406A-BBC7-B388F92E0A55/Documents
    // /Users/zhaobinglong/Library/Developer/CoreSimulator/Devices/037DA882-FA4E-4328-80BE-4BCB84E2C47A/data/Containers/Data/Application/682A61BA-A7CF-406A-BBC7-B388F92E0A55/Documents
    //构建数据库对象
    sqllite.Database database = await sqllite.openDatabase(dbPath + "/" + dbName, version: 1);
    print(database);
    return database;
  }

}

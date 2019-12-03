import 'package:flutter/material.dart';
import 'package:youwallet/widgets/priceNum.dart';
import 'package:youwallet/widgets/transferList.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:steel_crypt/steel_crypt.dart';
import 'package:web3dart/web3dart.dart';



class TabExchange extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState

    return new Page();
  }
}

class Page extends State<TabExchange> {
  @override
  Widget build(BuildContext context) {
    return layout(context);
  }

  var value;
  String _btnText="买入";

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
                              //makeOrder();
                              getConfigData();
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

  // 构建页面上半部分区域
  Widget buildPageTop1(BuildContext context) {
    return Container(
        child: new Column(
          children: <Widget>[
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                new Text('Token'),
                new Text('Base Token')
              ],
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new Container(
                  padding: const EdgeInsets.only(left: 10.0),
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
                new Text('/'),
                new Container(
                  padding: const EdgeInsets.only(left: 10.0),
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
              ],
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
//                buildLeftWidget(),
                buildRightWidget(),
//                new Expanded(
//                    child: buildRightWidget(),
//                    flex: 1
//                )

              ],
            )
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

  // 下单
  void makeOrder() async{
    print('start async');
    var client = Client();

    var payload = {
      "jsonrpc": "2.0",
      "method": "eth_blockNumber",
      "params": [],
      "id": DateTime.now().millisecondsSinceEpoch
    };

    var OrderAddressSet = {
      "baseToken": "0x8F48de31810deaA8bF547587438970EBD2e4be16",
      "quoteToken": "0x414b26708362B024A28C7Bc309D5C1a8Ac14647E",
      "relayer":"0x3d9c6c5a7b2b2744870166eac237bd6e366fa3ef" // 手续费的收款账户，先设置为SHT钱包地址
    };

    var OrderParam = {
      "trader": "0xAB890808775D51e9bF9fa76f40EE5fff124deCE5", // 这是我的在metaMask上新建的一个钱包地址
      "baseTokenAmount": 100, //交易token的数量
      "quoteTokenAmount": 100, //报价token的数量
      "gasTokenAmount": 0,
      "data": '0x020100005def248f025802580000000000000000000000000000000000000000',
      "signature" : ""
    };

    var rsp = await client.post(
        'https://ropsten.infura.io/',
        headers:{'Content-Type':'application/json'},
        body: json.encode(payload)
    );
    print('rsp code => ${rsp}');
    print('rsp code => ${rsp.statusCode}');
    print('rsp body => ${rsp.body}');

  }

  // 交易参数的设置, 包含hydro版本号、交易买卖标志等
  // getConfigData(bool) 经过sha3加密后取前四位feee047e
  // 参数为true 则为0000000000000000000000000000000000000000000000000000000000000001
  void getConfigData() async{
    var client = Client();
    var payload = {
      "jsonrpc": "2.0",
      "method": "eth_call",
      "params": [
        {
          "from":"0x7E999360d3327fDA8B0E339c8FC083d8AFe6A364",
          "to":"0x7E999360d3327fDA8B0E339c8FC083d8AFe6A364",
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

  // 获取交易签名数据
  // getConfigSignature(bytes1 v,  bytes32 r, bytes32 s, uint8 signMethod) 的签名：
  void getConfigSignature() async {
    var client = Client();
    var payload = {
      "jsonrpc": "2.0",
      "method": "eth_call",
      "params": [
        {
          "from":"0x7E999360d3327fDA8B0E339c8FC083d8AFe6A364",
          "to":"0x7E999360d3327fDA8B0E339c8FC083d8AFe6A364", // 合约地址
          "data": ""
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
  }


  List<DropdownMenuItem> getListData(){
    List<DropdownMenuItem> items=new List();
    DropdownMenuItem dropdownMenuItem1=new DropdownMenuItem(
      child:new Text('1'),
      value: '1',
    );
    items.add(dropdownMenuItem1);
    DropdownMenuItem dropdownMenuItem2=new DropdownMenuItem(
      child:new Text('2'),
      value: '2',
    );
    items.add(dropdownMenuItem2);
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

}

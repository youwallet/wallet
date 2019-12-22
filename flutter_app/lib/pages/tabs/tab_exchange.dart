import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:youwallet/service/token_service.dart';
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
import 'package:provider/provider.dart';
import 'package:youwallet/model/token.dart';
import 'package:youwallet/service/trade.dart';

class TabExchange extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => new Page();
}

class Page extends State {

  BuildContext mContext;
  List baseToken = [{
    'name': 'tokenD',
    'address': '0x42ABeB85Edf30e470601Ef47B55B9FF1bF3dcABa'
  }];
  final controllerAmount = TextEditingController();
  final controllerPrice = TextEditingController();


  // 输入框右侧显示的token提示
  String suffixText = "";


  //数据初始化
  @override
  void initState() {
    super.initState();
//    this._getBaseToken();
  }

  @override
  Widget build(BuildContext context) {
    return layout(context);
  }

  // 左侧被选中的token
  var value;

  var _rightToken = '0x42ABeB85Edf30e470601Ef47B55B9FF1bF3dcABa';
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
                    items: getListData(Provider.of<Token>(context).items),
                    hint:new Text('选择币种'),//当没有默认值的时候可以设置的提示
                    value: value,//下拉菜单选择完之后显示给用户的值
                    onChanged: (T){//下拉菜单item点击之后的回调
                      print(T);
                      setState(() {
                        suffixText = T['name'];
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
                          child: getButton('买入', this._btnText),
                          flex: 1
                      ),
                      new Expanded(
                          child: getButton('卖出', this._btnText),
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
                      controller: controllerAmount,
                      keyboardType: TextInputType.number,//键盘类型，数字键盘
                      decoration: InputDecoration(// 输入框内部右侧增加一个icon
                          suffixText: this.suffixText,//位于尾部的填充文字
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
                      onSubmitted: (text) {},
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
                    controller: controllerPrice,
                    decoration: InputDecoration(// 输入框内部右侧增加一个icon
                        suffixText: this.suffixText,//位于尾部的填充文字
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
                  ),

                ),
                new Text('当前账户余额~'),
                new Container(

                  padding: new EdgeInsets.only(top: 30.0),
                  child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                      new Text('交易额~'),
                      new SizedBox(
                        width: double.infinity,
                        height: 30,
                        child: RaisedButton(
                            elevation: 0,
                            onPressed: () async {
                               this.makeOrder();
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
                  child: Text('TokenD')
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

  // 获取按钮
  Widget getButton(String btnText, String currentBtn) {
    if (btnText == currentBtn) {
      return RaisedButton(
        onPressed: () {
          changeOrderModel(btnText);
        },
        shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(0))
        ), // 设置圆角，默认有圆角
        child: Text(btnText),
          textColor: Colors.white,
        color: Colors.green
      );
    } else {
      return OutlineButton(
        onPressed: () {
          changeOrderModel(btnText);
        },
        child: Text(btnText),
        color: Colors.deepOrange,
        borderSide: BorderSide(
            color: Colors.green,
            width: 1.0,
            style: BorderStyle.solid
        ),
      );
    }

  }

  // 更改下单模式
  void changeOrderModel(String text) {
    print("当前下单模式=》${text}");
    setState(() {
      this._btnText = text;
    });
  }

  // 构建页面下拉列表
  List<DropdownMenuItem> getListData(List tokens){
    List<DropdownMenuItem> items=new List();

    for (var value in tokens) {
      items.add(new DropdownMenuItem(
        child:new Text(value['name']),
        value: value,
      ));
    }
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

  /// 下单
  void makeOrder() async {
    print(this.controllerAmount.text);
    print(this.controllerPrice.text);
    bool isBuy = true;
    if (this._btnText == '买入') {
      isBuy = true;
    } else {
      isBuy = false;
    }
    String tokenA = this.value['address'];
    String tokenD = "0x42ABeB85Edf30e470601Ef47B55B9FF1bF3dcABa";

    int price = int.parse(this.controllerAmount.text) * int.parse(this.controllerPrice.text);

    Trade trade = new Trade(tokenA, tokenD, this.controllerAmount.text, price.toString(), isBuy);

    String hash = await trade.takeOrder();
    print(hash);
  }

  void _getBaseToken() async {
    await TokenService.getBaseToken();
  }

}

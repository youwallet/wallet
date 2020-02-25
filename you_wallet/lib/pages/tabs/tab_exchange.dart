
import 'package:flutter/material.dart';
import 'package:youwallet/service/token_service.dart';
import 'package:youwallet/widgets/priceNum.dart';
import 'package:youwallet/widgets/transferList.dart';
import 'package:youwallet/widgets/bottomSheetDialog.dart';
import 'package:youwallet/bus.dart';
import 'package:provider/provider.dart';
import 'package:youwallet/model/token.dart';
import 'package:youwallet/model/network.dart';
import 'package:youwallet/model/wallet.dart' as walletModel;
import 'package:youwallet/model/deal.dart';
import 'package:youwallet/service/trade.dart';
import 'package:youwallet/widgets/modalDialog.dart';
import '../../model/token.dart';
import 'package:youwallet/global.dart';

class TabExchange extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => new Page();
}

class Page extends State {

  BuildContext mContext;

  // 右侧显示的token
  List baseToken = [{
    'name': 'BTD',
    'address': '0x2e01154391f7dcbf215c77dbd7ff3026ea7514ce'
  }];

  // 数量编辑框
  final controllerAmount = TextEditingController();

  // 价格编辑框
  final controllerPrice = TextEditingController();

  // 底部交易列表
  List trades = [];

  // 匹配的数量数组
  Map filledAmount = {};

  // 兑换深度列表
  List tradesDeep = [];

  // 输入框右侧显示的token提示
  String suffixText = "";
  double tradePrice = 0;

  // 左侧被选中的token
  var value;

  String _btnText="买入";
  List tokens = [];
  String tokenBalance = "";

  //数据初始化
  @override
  void initState() {
    super.initState();

    // 监听页面切换，刷新交易的状态
    eventBus.on<TabChangeEvent>().listen((event) {
      // print("event listen =》${event.index}");
      if (event.index == 1) {
         this._getTradeInfo();
      } else {
        print('do nothing');
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // this.getTraderList();
  }

  @override
  Widget build(BuildContext context) {
    return layout(context);
  }

  // 构建页面
  Widget layout(BuildContext context) {
    return new Scaffold(
      backgroundColor: _btnText == '买入' ? Colors.green[50] : Colors.red[50],
      appBar: buildAppBar(context),
      body: RefreshIndicator(
      onRefresh: _refresh,
        child: new ListView(
          children: <Widget>[
            new Container(
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
                    transferList(arr: this.trades, filledAmount: this.filledAmount)
                  ],
                )
            ),
          ],
        )
      )
    );
  }

  // 构建顶部标题栏
  Widget buildAppBar(BuildContext context) {
    return new AppBar(
        title: const Text('兑换'),
        automaticallyImplyLeading: false, //设置没有返回按钮
    );
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
//                new Text('Token'),
                new Container(
                  padding: const EdgeInsets.all(4.0),
                  margin: const EdgeInsets.only(bottom: 10.0),
                  decoration: new BoxDecoration(
                    borderRadius: new BorderRadius.all(new Radius.circular(6.0)),
                    border: new Border.all(width: 1.0, color: Colors.black12),
                    color: Colors.black12,
                  ),
                  height: 36.0,
                  child: GestureDetector(
                    onTap: this.selectToken,//写入方法名称就可以了，但是是无参的
                    child: Text(
                      this.value==null?'选择币种':this.value['name'],
                      style: TextStyle(
                          fontSize: 24.0
                      ),
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
                    onChanged: (text) {//内容改变的回调
                      this.computeTrade();
                    },
                  ),

                ),
                new Text('≈'),
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
                    onChanged: (text) {//内容改变的回调
                      this.computeTrade();
                    },
                  ),

                ),

                new Text('当前账户余额${this.value!=null?this.value["balance"]:"~"}'),
                new Container(

                  padding: new EdgeInsets.only(top: 30.0),
                  child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                      new Text('交易额${tradePrice}BTD'),
                      new SizedBox(
                        width: double.infinity,
                        height: 30,
                        child: RaisedButton(
                            color: _btnText == '买入'? Colors.green : Colors.red,
                            elevation: 0,
                            onPressed: () async {
                               this.makeOrder();
                            },
                            child: Text(
                                this._btnText + this.suffixText,
                                style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.white
                                )
                            ),
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
            width: 30.0,
            child: null,
          ),
          // 右边一列
          new  Expanded(
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                //new Text('Base Token'),
                new Container(
                  padding: const EdgeInsets.only(left: 10.0),
                  margin: const EdgeInsets.only(bottom: 10.0),
                  decoration: new BoxDecoration(
                    borderRadius: new BorderRadius.all(new Radius.circular(6.0)),
                    border: new Border.all(width: 1.0, color: Colors.black12),
                    color: Colors.black12,
                  ),
                  height: 40.0,
                  child: Text(
                      'BTD',
                    style: TextStyle(
                      fontSize: 24.0
                    )
                  )
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

  // 构建一组颜色会动态变更的按钮
  Widget getButton(String btnText, String currentBtn) {
    if (btnText != currentBtn) {
      return RaisedButton(
        onPressed: () {
          changeOrderModel(btnText);
        },
        shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(0))
        ), // 设置圆角，默认有圆角
        elevation: 0, // 按钮阴影高度
        color: Colors.white,
        child: Text(btnText + this.suffixText)
      );
    } else {
      return OutlineButton(
        onPressed: () {
          changeOrderModel(btnText);
        },
        child: Text(btnText + this.suffixText),
        borderSide:  BorderSide(
            color: currentBtn == '买入'? Colors.green : Colors.red,
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

  // 构建右侧区域
  Widget buildRightWidget() {
    return Container(
      child: new Column(
        children: <Widget>[
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Text('价格'),
              new Text('数量'),
            ],
          ),
          priceNum(arr: this.tradesDeep)
        ],
      ),
    );
  }

  /// 下单
  void makeOrder() async {
    // 关闭键盘
    FocusScope.of(context).requestFocus(FocusNode());
    TokenService.allowance(context, this.value['address']);
    return;

    if (Provider.of<Network>(context).network != 'ropsten') {
      final snackBar = new SnackBar(content: new Text('请切换到ropsten网络'));
      Scaffold.of(context).showSnackBar(snackBar);
      return ;
    }
    // print(this.value);
    if (this.value == null) {
      final snackBar = new SnackBar(content: new Text('请选择token'));
      Scaffold.of(context).showSnackBar(snackBar);
      return ;
    }


    if (this.controllerAmount.text.length == 0) {
      final snackBar = new SnackBar(content: new Text('请输入数量'));
      Scaffold.of(context).showSnackBar(snackBar);
      return ;
    }

    if (this.controllerPrice.text.length == 0) {
      final snackBar = new SnackBar(content: new Text('请输入价格'));
      Scaffold.of(context).showSnackBar(snackBar);
      return ;
    }

    this.showAuthTips();
  }

  /// 提示授权需要密码
  void showAuthTips() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return GenderChooseDialog(
              title: '授权交易',
              content: '为了便于后续兑换，需要您授权youwallet代理。youwallet只会在你授权的情况下才会执行交易，请放心授权！',
              onCancelChooseEvent: () {
                 Navigator.pop(context);
                 this.showSnackBar('取消交易');
              },
              onSuccessChooseEvent: () async {
                 Navigator.pop(context);
                 this.getPwd();
              });
        });
  }

  // 获取用户密码
  void getPwd() {
    Navigator.pushNamed(context, "getPassword").then((data){
      this.tradeApprove(data);
    });
  }

  // 交易授权
  void tradeApprove(String pwd) async{
    // 进行交易授权, 每一种token，只需要授权一次，目前没有接口确定token是否授权
    // 买入时对右边的token授权，
    // 卖出时对左边的token授权
    // 一句话说明：哪个token要被转出去给其他人，就给哪个token授权
    String need_approve_token = "";
    if (this._btnText == '买入') {
      need_approve_token = this.baseToken[0]['address'];
    } else {
      need_approve_token = this.value['address'];
    }

     // 等待授权，这里如果已经授权，则不需要再次授权
     //await Trade.approve(need_approve_token, pwd);

     // 开始交易
     this.startTrade(pwd);
  }

  // 获取钱包密码，然后用密码解析私钥
  void startTrade(String pwd) async {
    bool isBuy = true;
    if (this._btnText == '买入') {
      isBuy = true;
    } else {
      isBuy = false;
    }

    final snackBar = new SnackBar(content: new Text('下单中···'));

    Scaffold.of(context).showSnackBar(snackBar);

    Trade trade = new Trade(this.value['address'], this.value['name'], this.baseToken[0]['address'], this.baseToken[0]['name'], this.controllerAmount.text, this.controllerPrice.text, isBuy, pwd);
    String hash = await trade.takeOrder();

    if (hash.contains('RPCError')) {
      String barText = '';
      if (hash.contains('insufficient funds for gas * price + value')){
        barText = 'eth手续费不足，请先获取测试所需以太币';
      } else {
        barText = hash;
      }
      final snackBar = new SnackBar(content: new Text(barText));
      Scaffold.of(context).showSnackBar(snackBar);
    } else {
       // 下单成功后，刷新用户本地的历史兑换列表
       this.getTraderList();

       // 刷新交易深度
       this.getBuyList();
    }
  }

  void showSnackBar(String text) {
    final snackBar = new SnackBar(content: new Text(text));
    Scaffold.of(context).showSnackBar(snackBar);
  }


   // 获取订单列表
   void getTraderList() async {
     List list = await Trade.getTraderList();

     setState(() {
       this.trades = list;
     });

     this._getTradeInfo();
   }

   // 获取当前的买单队列
   Future<void> getBuyList() async {
      this.tradesDeep = []; // 清空当前的深度数组
      String tokenAddress = this.value['address']; // 左边的token
      String baseTokenAddress = this.baseToken[0]['address']; // 右边的token
      bool isSell =  false;
      // 拿到队列中第一个订单的 bq_hash + od_hash
      String hash = await Trade.getOrderQueueInfo(tokenAddress, baseTokenAddress, isSell);
      // 把hash中的bq hash单独拿出来，同一个队列中的bq hash都是相同的 拿到QueueElem的订单结构体
      print('getBuyList hash => ${hash}');
      String bqHash = hash.replaceFirst('0x', '').substring(0,64);
      String odHash = hash.replaceFirst('0x', '').substring(64);

      String queueElem = await Trade.getOrderInfo(hash, isSell);
      this.deepCallBackOrderInfo(queueElem, bqHash, isSell);
   }

   // 递归获取订单信息
   // queueElem后64位，是下一个订单的odHash,
   // 以前的bqHash + 下一个订单的odHash，拼接成新的hash，继续获取下一个订单
   Future<void> deepCallBackOrderInfo(String queueElem, String bqHash, bool isSell) async {
      this.buildQueueElem(queueElem.replaceFirst('0x', ''), isSell);
      String odHash = queueElem.substring(queueElem.length - 64);
      String nextHash = bqHash + odHash;
      String nextQueueElem = await Trade.getOrderInfo(nextHash, isSell);
      if (nextQueueElem != '0x' && odHash != '0000000000000000000000000000000000000000000000000000000000000000') {
        this.deepCallBackOrderInfo(nextQueueElem, bqHash, isSell);
      } else {
        //print('订单队列结束, 最后一个订单的odHash => ${odHash}');
        if (!isSell) {
          this.getSellList();
        }
      }
   }

   // 获取卖单队列
   Future<void> getSellList() async {

     String tokenAddress = this.value['address'];
     String baseTokenAddress = this.baseToken[0]['address'];
     bool isSell = true;
     String hash = await Trade.getOrderQueueInfo(tokenAddress, baseTokenAddress, isSell);
     print('getSellList hash => ${hash}');
     String bqHash = hash.replaceFirst('0x', '').substring(0,64);
     // 拿到QueueElem的订单结构体
     String queueElem = await Trade.getOrderInfo(hash, isSell);
     this.deepCallBackOrderInfo(queueElem, bqHash, isSell);
   }

   // 解析queueElem 深度列表的数据需要合并处理，规则如下
   // https://github.com/youwallet/wallet/issues/44#issuecomment-575859132
   void buildQueueElem(String queueElem, bool isSell) {
     print('1 =>${queueElem.substring(queueElem.length - 128, queueElem.length - 64)}');
     BigInt filled = BigInt.parse(queueElem.substring(queueElem.length - 128, queueElem.length - 64), radix: 16);
     print(filled);
     print(queueElem.replaceFirst('0x', '').substring(64, 128));
     BigInt baseTokenAmount  = BigInt.parse(queueElem.replaceFirst('0x', '').substring(64, 128), radix: 16);
     print(baseTokenAmount);
     // BigInt quoteTokenAmount = BigInt.parse(queueElem.replaceFirst('0x', '').substring(128, 192));
     BigInt quoteTokenAmount = BigInt.parse(queueElem.replaceFirst('0x', '').substring(128, 192), radix: 16);

     print("baseTokenAmount   => ${baseTokenAmount}");
     print("quoteTokenAmount  => ${quoteTokenAmount}");
     print("左边显示价格        => ${baseTokenAmount/quoteTokenAmount}");
     print("解析filled         => ${filled}");
     print("右边显示数量        => ${baseTokenAmount - filled}");
     print("isSell显示         => ${isSell}");
     if (baseTokenAmount != BigInt.from(0)) {

       String left = (quoteTokenAmount/baseTokenAmount).toStringAsFixed(5);

       // 这里的baseTokenAmount是包含18小数位数的10进制数据，先砍掉小数位
       // 标准做法是根据token对应的小数位
       BigInt right = baseTokenAmount - filled;

       print(this.tradesDeep);
       int index = this.tradesDeep.indexWhere((element) => element['left']==left && element['isSell']== isSell);
       // print("start compare => ${index}--${left}");
       if (index == -1) {
         setState(() {
           this.tradesDeep.add({
             'left': left,
             'right': right/BigInt.from(1000000000000000000),
             'isSell': isSell
           });
         });
       } else {
         setState(() {
           this.tradesDeep[index]['right'] = this.tradesDeep[index]['right'] + right ;
         });
       }
     }
   }


   /// 遍历每个订单的状态
   /// 将查询到的匹配数量保存在数据库中
   /// 如果订单中的数量已经匹配完毕，则代表这个订单转账成功，刷新的时候不再遍历
   Future<void> _getTradeInfo() async {
     Map filled = {};
     for(var i = 0; i<this.trades.length; i++) {
       if(this.trades[i]['status'] != '成功') {
         double amount = await Trade.getFilled(this.trades[i]['odHash']) /
             1000000000000000000;
         print('查询订单   =》${this.trades[i]['txnHash']}');
         print('匹配情况   =》${amount}');
         // 保存匹配的数量进入数据库
         int sqlRes = await Provider.of<Deal>(context).updateFilled(
             this.trades[i], amount.toString());
         filled[this.trades[i]['txnHash']] = (amount).toString();
       }
     }
     setState(() {
       this.filledAmount = filled;
     });
     print(this.filledAmount);
   }

   // 计算交易额度
   void computeTrade() {
     if (this.controllerAmount.text.length == 0) {
       return ;
     }

     if (this.controllerPrice.text.length == 0) {
       return ;
     }

     setState(() {
       this.tradePrice = double.parse(this.controllerAmount.text) * double.parse(this.controllerPrice.text);
     });
   }

  // 下拉刷新底部交易列表
  Future<void> _refresh() async {
    this._getTradeInfo();
    this.getTraderList();
    final snackBar = new SnackBar(content: new Text('刷新结束'));
    Scaffold.of(context).showSnackBar(snackBar);
  }


  // 选左边的token
  void selectToken() async {
    if (Provider.of<Token>(context).items.length == 0) {
      this.showSnackBar('请先添加token');
      return;
    }
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return BottomSheetDialog(
              content: Provider.of<Token>(context).items,
              onSuccessChooseEvent: (res) {
                print(res);
                setState(() {
                  this.value = res;
                  this.suffixText = res['name'];
                });
                this.getBuyList();
              });
        }
    );
  }

}

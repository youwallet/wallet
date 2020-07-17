import 'package:flutter/material.dart';
import 'package:youwallet/service/token_service.dart';
import 'package:youwallet/widgets/transferList.dart';
import 'package:youwallet/widgets/tokenSelectSheet.dart';
import 'package:youwallet/widgets/input.dart';
import 'package:youwallet/bus.dart';
import 'package:youwallet/global.dart';
import 'package:provider/provider.dart';
import 'package:youwallet/model/wallet.dart' as walletModel;

import 'package:youwallet/service/trade.dart';
import 'package:youwallet/model/deal.dart';
import 'package:youwallet/model/token.dart';
import 'package:youwallet/widgets/modalDialog.dart';
import 'package:youwallet/widgets/loadingDialog.dart';
import 'package:youwallet/widgets/customTab.dart';
import 'package:youwallet/widgets/tradesDeep.dart';
import 'package:decimal/decimal.dart';
import 'package:youwallet/util/translations.dart';
import 'package:youwallet/model/network.dart';
import 'dart:async';

class TabExchange extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new Page();
}

class Page extends State {
  BuildContext mContext;

  // 数量编辑框
  final controllerAmount = TextEditingController();

  // 价格编辑框
  final controllerPrice = TextEditingController();

  // 定义一个全局的key，通过key，在当前页面就可以调用组件内部的函数
  final GlobalKey<TransferListState> transferListKey = GlobalKey();

  String inputPrice = "";

  // 底部交易列表
  List trades = [];

  // 匹配的数量数组
  Map filledAmount = {};

  // 输入框右侧显示的token提示
  String suffixText = "";

  // 输入价格和数量后计算的交易额度
  var tradePrice;

  // 需要授权的token
  String needApproveToken = '';

  // 左侧被选中的token
  var value;

  // 右边的token对象
  var rightToken;

  String _btnText = "买入";
  List tokens = [];
  String tokenBalance = "";

  // 下单过程中，当前订单的进度
  String currentStatus = "挂单中";

  // 当前页面显示的token余额
  String balance = "";

  //申明一个定时器
  var _timer;

  // 当前token兑换列表被选中的列表索引
  String currentTab = '当前兑换';

  //数据初始化
  @override
  void initState() {
    super.initState();

    // 监听页面切换，刷新交易的状态
    eventBus.on<TabChangeEvent>().listen((event) {
      // print("event listen =》${event.index}");
      if (event.index == 1) {
        print('监听TabChangeEvent =》${event.index}');
        // eventBus.fire(CustomTabChangeEvent('当前兑换'));
      } else {
        print('do nothing');
      }
    });

    //监听订单操作结果
    eventBus.on<CustomTabChangeEvent>().listen((event) async {
      this.currentTab = event.res;
    });

    //监听订单操作结果
    eventBus.on<TransferDoneEvent>().listen((event) async {
      // this.showSnackBar(event.res);
      // Navigator.pop(context);
    });

    // 事件钩子，通知页面订单列表就要开始刷新了
    eventBus.on<TransferUpdateStartEvent>().listen((event) {
      showDialog<Null>(
          context: context, //BuildContext对象
          barrierDismissible: false,
          builder: (BuildContext context) {
            return new LoadingDialog(
              //调用对话框
              text: '刷新中...',
            );
          });

      // 更新兑换页面上当前正在交易的这个token的余额
      this.updateTokenBalance();

      eventBus.fire(UpdateTeadeDeepEvent());
    });

    print('tab exchange init');
    //eventBus.fire(CustomTabChangeEvent('当前兑换'));

    this._startTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // eventBus.fire(CustomTabChangeEvent('当前兑换'));
    print('tab exchange didChangeDependencies');
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
                          color: Color(0xFF919D97),
                          margin: const EdgeInsets.only(top: 16.0, bottom: 0),
                          child: null,
                        ),
                      ],
                    )),
                new Container(
                    margin: const EdgeInsets.only(left: 16.0, right: 16.0),
                    child: new CustomTab(
                        buttons: ['当前兑换', '历史兑换'],
                        activeIndex: this.currentTab)),
                new Container(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                  child: new transferList(key: transferListKey),
                )
//            new Container(
//              padding: const EdgeInsets.only(left:16.0,right:16.0),
//              child: transferList(arr: this.trades, filledAmount: this.filledAmount),
//            )
              ],
            )));
  }

  // 构建顶部标题栏
  Widget buildAppBar(BuildContext context) {
    return new AppBar(
        title: Text(Translations.of(context).text("title_tab_exchange")),
        // title: Text('买入/卖出'),
        // title: buildTopBar(context),
        elevation: 0.0,
        // actions: this.appBarActions(),
        automaticallyImplyLeading: false, //设置没有返回按钮
        backgroundColor: _btnText == '买入' ? Colors.green[50] : Colors.red[50]);
  }

  // Widget buildTopBar(BuildContext context) {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceAround,
  //     children: [Text('买入'), Text('卖出')],
  //   );
  // }

  List appBarActions() {
    return <Widget>[
      new Container(
        width: 50.0,
        child: new IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            if (this.value == null || this.rightToken == null) {
              this.showSnackBar('请选择token和base token，再查看交易深度');
            } else {}
          },
        ),
      )
    ];
  }

  // 构建页面上半部分区域
  Widget buildPageTop(BuildContext context) {
    return Container(
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          //左边一列
          new Expanded(
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new TokenSelectSheet(onCallBackEvent: (res) {
                  setState(() {
                    this.value = res;
                    this.suffixText = res['name'];
                  });
                  Future.delayed(Duration(seconds: 1), () {
                    eventBus.fire(UpdateTeadeDeepEvent());
                    print('延时1s执行，因为立即执行收不到setState设置的值');
                  });
                }),
                new Container(
                    child: new Row(
                  children: <Widget>[
                    new Expanded(
                        child: getButton('买入', this._btnText), flex: 1),
                    new Expanded(child: getButton('卖出', this._btnText), flex: 1)
                  ],
                )),
                new Text('限价模式'),
                new Input(
                  suffixText:
                      this.rightToken == null ? '' : this.rightToken['name'],
                  hintText: '输入买入价格',
                  controllerEdit: controllerPrice,
                  onSuccessChooseEvent: (res) {
                    print('onSuccessChooseEvent =》 ${res}');
                    this.inputPrice = res;
                    this.computeTrade();
                  },
                ),
                new Text(''),
                new Container(height: 10.0, child: null),
                new Input(
                  hintText: '输入买入数量',
                  controllerEdit: controllerAmount,
                  suffixText: this.value == null ? '' : this.value['name'],
                  onSuccessChooseEvent: (res) {
                    this.computeTrade();
                  },
                ),
                new Text("当前账户余额：$balance"),
                new Container(
                  padding: new EdgeInsets.only(top: 30.0),
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Text(
                        '交易额: ${tradePrice ?? ""}',
                        style: new TextStyle(
                            color:
                                _btnText == '买入' ? Colors.green : Colors.red),
                      ),
                      new SizedBox(
                        width: double.infinity,
                        height: 30,
                        child: RaisedButton(
                          color: _btnText == '买入' ? Colors.green : Colors.red,
                          elevation: 0,
                          onPressed: () async {
                            this.makeOrder();
                          },
                          child: Text(this._btnText + this.suffixText,
                              style: TextStyle(
                                  fontSize: 14.0, color: Colors.white)),
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
            width: 20.0,
            alignment: Alignment.topCenter,
            child: Text(
              '/',
              style: TextStyle(
                fontSize: 28.0,
                color: Colors.black38,
              ),
            ),
          ),
          // 右边一列
          new Expanded(
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new TokenSelectSheet(onCallBackEvent: (res) {
                  print('页面右侧token选择 = > ${res}');
                  setState(() {
                    rightToken = res;
                    balance = res['balance'] + res['name'];
                  });
                  Future.delayed(Duration(seconds: 1), () {
                    eventBus.fire(UpdateTeadeDeepEvent());
                    print('延时1s执行，因为立即执行收不到setState设置的值');
                  });
                }),
                buildRightWidget()
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 构建一组颜色会动态变更的按钮
  Widget getButton(String btnText, String currentBtn) {
    if (btnText != currentBtn) {
      return RaisedButton(
          padding: const EdgeInsets.all(0.0),
          onPressed: () {
            changeOrderModel(btnText);
          },
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(0))), // 设置圆角，默认有圆角
          elevation: 0, // 按钮阴影高度
          color: Colors.white,
          child: Text(btnText + this.suffixText,
              softWrap: false, overflow: TextOverflow.fade));
    } else {
      return OutlineButton(
        padding: const EdgeInsets.all(0.0),
        onPressed: () {
          changeOrderModel(btnText);
        },
        child: Text(btnText + this.suffixText,
            style: TextStyle(
              color: currentBtn == '买入' ? Colors.green : Colors.red,
            ),
            softWrap: false),
        borderSide: BorderSide(
            color: currentBtn == '买入' ? Colors.green : Colors.red,
            width: 1.0,
            style: BorderStyle.solid),
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
//          priceNum(arr: this.tradesDeep)
          new TradesDeep(
            leftToken: this.value != null ? this.value['address'] : '',
            rightToken:
                this.rightToken != null ? this.rightToken['address'] : '',
          )
        ],
      ),
    );
  }

  /// 校验数据格式
  /// 价格数量必须是大于0的数字
  /// 并且小数位数有限制
  void makeOrder() async {
    if (this.value == null) {
      this.showSnackBar('请选择左侧token');
      return;
    }

    if (this.rightToken == null) {
      this.showSnackBar('请选择右侧token');
      return;
    }

    if (this.controllerPrice.text.length == 0) {
      this.showSnackBar('请输入价格');
      return;
    }

    try {
      if (Decimal.parse(this.controllerPrice.text) <= Decimal.parse('0')) {
        this.showSnackBar('价格必须大于0');
        return;
      }
      List strs = this.controllerPrice.text.split('.');
      if (strs.length == 2) {
        if (strs[1].length > Global.priceDecimal) {
          this.showSnackBar('价格小数位数最多${Global.priceDecimal}位');
          return;
        }
      }
    } catch (e) {
      print(e);
      this.showSnackBar('你输入的价格无法识别');
      return;
    }

    if (this.controllerAmount.text.length == 0) {
      this.showSnackBar('请输入数量');
      return;
    }

    try {
      if (Decimal.parse(this.controllerAmount.text) <= Decimal.parse('0')) {
        this.showSnackBar('数量必须大于0');
        return;
      }
      List strs = this.controllerAmount.text.split('.');
      if (strs.length == 2) {
        if (strs[1].length > Global.numDecimal) {
          this.showSnackBar('数量小数位数最多${Global.numDecimal}位');
          return;
        }
      }
    } catch (e) {
      print(e);
      this.showSnackBar('你输入的数量无法识别');
      return;
    }

    showDialog<Null>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new LoadingDialog(
            text: this.currentStatus,
          );
        });
    // 关闭键盘
    FocusScope.of(context).requestFocus(FocusNode());

    // 判断一下有没有还在打包中的订单
    // 如果有订单在打包中，发起交易会失败
    List list = await Provider.of<Deal>(context).getTraderList();
    bool packing = list.any((element) => (element['status'] == "打包中"));
    if (packing) {
      this.showSnackBar('当前有订单在打包中，请先下拉刷新');
      Navigator.of(context).pop();
      return;
    }

    // 先检查授权
    this.checkApprove();
  }

  // 交易授权
  // 进行交易授权, 每一种token，只需要授权一次，目前没有接口确定token是否授权
  // 买入时对右边的token授权，
  // 卖出时对左边的token授权
  // 一句话说明：哪个token要被转出去给��他人，就给哪个token授权
  void checkApprove() async {
    if (this._btnText == '买入') {
      needApproveToken = this.rightToken['address'];
    } else {
      needApproveToken = this.value['address'];
    }

    String res = await TokenService.allowance(context, needApproveToken);
    print('授权检测的额度 res=> ${res}');
//    Navigator.of(context).pop();
//    return;

    // 授权额度为0，发起提示
    if (res == '0') {
      Navigator.of(context).pop();
      Map currentWallet =
          Provider.of<walletModel.Wallet>(context).currentWalletObject;
      if (currentWallet['balance'] == '0.00') {
        this.showSnackBar('您的钱包ETH余额为0，无法授权，不可以交易');
      } else {
        this.showAuthTips();
      }
    } else {
      // 已经授权
      this.getPwd(true);
    }
  }

  /// 获取用户密码
  /// approve 是否授权
  /// 发起授权之前，要先确认用户的钱包ETH有余额，否则无法授权
  void getPwd(bool approve) {
    Navigator.pushNamed(context, "getPassword").then((data) async {
      print('密码输入页面拿到的对象');
      print(data);
      if (data == null) {
        this.showSnackBar('交易终止');
        Navigator.of(context).pop();
        return;
      }

//      Navigator.of(context).pop();
//      return;

      // 已经授权过
      if (approve) {
        this.startTrade(data);
      } else {
        try {
          // 授权接口可以立刻拿到Hash，但是授权不一定成功，
          // 需要利用hash查询接口，查询这个订单有没有上链
          // 如果没有上链，就一直给用户loading
          String hash = await Trade.approve(needApproveToken, data);
          print('授权Hash=> ${hash}');
          // 这里不能用await，否则会黑屏
          this.checkAuthResponse(hash, 0);
        } catch (e) {
          Navigator.of(context).pop();
        }
      }
    });
  }

  /// 发起授权后，轮询授权结果
  Future<bool> checkAuthResponse(String hash, int index) async {
    Map response = await Trade.getTransactionByHash(hash);
    print("第${index}次查询");
    print(response);
    if (response['blockHash'] != null) {
      print('授权成功，以太坊返回了交易的blockHash');
      Navigator.of(context).pop();
      this.showSnackBar('授权成功，请重新挂单');
      return true;
    } else {
      if (index > 30) {
        print('已经轮询了10次，授权失败');
        Navigator.of(context).pop();
        this.showSnackBar('授权响应超时，请重新授权');
        return false;
      } else {
        Future.delayed(Duration(seconds: 2), () {
          this.checkAuthResponse(hash, index + 1);
        });
      }
    }
  }

  /// 提示授权需要密码
  void showAuthTips() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return GenderChooseDialog(
              title: '授权交易',
              content:
                  '为了便于后续兑换，需要您授权youwallet代理。youwallet只会在你授权的情况下才会执行交易，请放心授权！',
              onCancelChooseEvent: () {
                Navigator.pop(context);
                this.showSnackBar('取消交易');
              },
              onSuccessChooseEvent: () async {
                Navigator.pop(context);
                showDialog<Null>(
                    context: context, //BuildContext对象
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return new LoadingDialog(
                        //调用对话框
                        text: '授权中...',
                      );
                    });
                this.getPwd(false);
              });
        });
  }

  // 获取钱包密码，然后用密码解析私钥
  // obj里面包括了密码，私钥，gasLimit，gasPrice
  void startTrade(Map obj) async {
    bool isBuy = true;
    if (this._btnText == '买入') {
      isBuy = true;
    } else {
      isBuy = false;
    }

    Trade trade = new Trade(
        this.value['address'],
        this.value['name'],
        this.rightToken['address'],
        this.rightToken['name'],
        this.controllerAmount.text,
        this.controllerPrice.text,
        isBuy,
        obj);
    try {
      // 下单成功后，主动更新当前交易的这个的余额
      // this.value就是需要更新的token，只需要更新value中的balance
      // 但是拿到订单hash，交易其实还是pading状态，余额已经减少了吗
      // takeOrder要返回hash
      String txnHash = await trade.takeOrder();
      print('@@@@@下单成功，拿到了hash，以太坊还在写链@@@@@@');
      print(txnHash);
      Navigator.pop(context);
      // transferListKey.currentState.tabChange('当前兑换');
      Navigator.pushNamed(context, "success",
          arguments: {'msg': '下单成功', 'txnHash': txnHash});
      // 拿到订单Hash，通知历史列表组件更新
      // eventBus.fire(OrderSuccessEvent());
    } catch (e) {
      print('+++++++++++++++');
      print(e);
      if (e.toString() ==
          'RPCError: got code -32000 with msg "insufficient funds for gas * price + value".') {
        this.showSnackBar('钱包ETH余额不足');
      } else if (e.toString() ==
          'RPCError: got code -32000 with msg "replacement transaction underpriced".') {
        this.showSnackBar('有交易在打包中，请先等待打包结束');
      } else {
        this.showSnackBar(e.toString());
      }
      Navigator.pop(context);
    }

//    // 关闭挂单中的全局提示
//    Navigator.of(context).pop();
  }

  void showSnackBar(String text) {
    final snackBar = new SnackBar(content: new Text(text));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  // 计算交易额度
  void computeTrade() {
    if (this.controllerAmount.text.length == 0) {
      return;
    }

    if (this.controllerPrice.text.length == 0) {
      return;
    }

    var tradePrice = Decimal.parse(this.controllerAmount.text) *
        Decimal.parse(this.controllerPrice.text);
    setState(() {
      this.tradePrice = tradePrice.toString() + this.rightToken['name'];
    });
  }

  // 下拉刷新底部交易列表
  Future<void> _refresh() async {
    if ('mainnet' == Provider.of<Network>(context).network) {
      this.showSnackBar('当前网络不支持刷新，请切换测试网');
      return;
    }

    // eventBus.fire(UpdateTeadeDeepEvent());
    // eventBus.fire(CustomTabChangeEvent('当前兑换'));
    // eventBus.fire(UpdateOrderListEvent());
    this.showSnackBar('后台刷新中...');
    // showDialog<Null>(
    //     context: context, //BuildContext对象
    //     barrierDismissible: false,
    //     builder: (BuildContext context) {
    //       return new LoadingDialog(
    //         //调用对话框
    //         text: '刷新中...',
    //       );
    //     });
  }

  // 更新token的余额，在交易结束后
  // 计算当前账户余额，这里计算的是右边token的余额
  Future updateTokenBalance() async {
    String balance = await TokenService.getTokenBalance(this.rightToken);
    await Provider.of<Token>(context)
        .updateTokenBalance(this.rightToken, balance);
    setState(() {
      this.balance = balance + this.rightToken['name'];
    });
  }

  // 创建循环
  // 这里要不断的更新兑换列表的交易状态
  _startTimer() {
    _timer = new Timer.periodic(new Duration(seconds: 5), (timer) {
      transferListKey.currentState.updateOrderFilled();
      eventBus.fire(UpdateTeadeDeepEvent());
    });
  }

  _cancelTimer() {
    _timer?.cancel();
  }
}

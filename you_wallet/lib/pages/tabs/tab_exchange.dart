
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
import 'package:youwallet/widgets/modalDialog.dart';
import 'package:youwallet/widgets/loadingDialog.dart';
import 'package:youwallet/widgets/customTab.dart';
import 'package:youwallet/widgets/tradesDeep.dart';
import 'package:decimal/decimal.dart';

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

  String inputPrice = "";

  // 底部交易列表
  List trades = [];

  // 匹配的数量数组
  Map filledAmount = {};

  // 输入框右侧显示的token提示
  String suffixText = "";

  // 输入价格和数量后计算的交易额度
  Decimal tradePrice;

  // 需要授权的token
  String needApproveToken = '';

  // 左侧被选中的token
  var value;
  // 右边的token对象
  var rightToken;

  String _btnText="买入";
  List tokens = [];
  String tokenBalance = "";

  // 下单过程中，当前订单的进度
  String currentStatus = "挂单中";

  //数据初始化
  @override
  void initState() {
    super.initState();

    // 监听页面切换，刷新交易的状态
    eventBus.on<TabChangeEvent>().listen((event) {
      // print("event listen =》${event.index}");
      if (event.index == 1) {
         //this._getTradeInfo();
      } else {
        print('do nothing');
      }
    });

    /// 监听订单操作结果
    eventBus.on<TransferDoneEvent>().listen((event) {
      Navigator.pop(context);
      this.showSnackBar(event.res);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
                )
            ),
            new Container(
              margin: const EdgeInsets.only(left:16.0,right:16.0),
              child: new CustomTab(
                buttons:['当前兑换','历史兑换'],
                activeIndex: '当前兑换'
              )
            ),
            new Container(
              padding: const EdgeInsets.only(left:16.0,right:16.0),
              child: new transferList(),
            )
//            new Container(
//              padding: const EdgeInsets.only(left:16.0,right:16.0),
//              child: transferList(arr: this.trades, filledAmount: this.filledAmount),
//            )
          ],
        )
      )
    );
  }

  // 构建顶部标题栏
  Widget buildAppBar(BuildContext context) {
    return new AppBar(
        title: const Text('兑换'),
        elevation: 0.0,
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
                new TokenSelectSheet(
                    onCallBackEvent: (res){
                       setState(() {
                         this.value = res;
                         this.suffixText = res['name'];
                       });
                       Future.delayed(Duration(seconds: 1), (){
                         eventBus.fire(UpdateTeadeDeepEvent());
                         print('延时1s执行，因为立即执行收不到setState设置的值');
                       });
                    }
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
                new Input(
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
                  onSuccessChooseEvent: (res) {
                    this.computeTrade();
                  },
                ),
                new Text('当前账户余额：${this.value!=null?this.value["balance"]:"~"}'),
                new Container(
                  padding: new EdgeInsets.only(top: 30.0),
                  child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                      new Text(
                          '交易额${tradePrice??""}',
                          style: new TextStyle(
                            color: _btnText == '买入'? Colors.green : Colors.red
                          ),
                      ),
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
          new  Expanded(
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new TokenSelectSheet(
                    onCallBackEvent: (res){
                      print('页面右侧token选择 = > ${res}');
                      setState(() {
                        rightToken = res;
                      });
                      Future.delayed(Duration(seconds: 1), (){
                        eventBus.fire(UpdateTeadeDeepEvent());
                        print('延时1s执行，因为立即执行收不到setState设置的值');
                      });
                    }
                ),
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
        child: Text(
            btnText + this.suffixText,
            style: TextStyle(
              color: currentBtn == '买入'? Colors.green : Colors.red
            )
        ),
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
//          priceNum(arr: this.tradesDeep)
          new TradesDeep(
              leftToken: this.value != null?this.value['address']:'',
              rightToken: this.rightToken != null?this.rightToken['address']:''
          )
        ],
      ),
    );
  }

  /// 下单
  void makeOrder() async {

    showDialog<Null>(
        context: context, //BuildContext对象
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new LoadingDialog( //调用对话框
            text: this.currentStatus,
          );
        }
    );
    // 关闭键盘
     FocusScope.of(context).requestFocus(FocusNode());

    List list = await Provider.of<Deal>(context).getTraderList();
    bool packing = list.any((element)=>(element['status']=="打包中"));

    if (packing) {
      this.showSnackBar('当前有订单在打包中，请先等待打包完毕');
      Navigator.of(context).pop();
      return ;
    }

    if (this.value == null) {
      this.showSnackBar('请选择左侧token');
      Navigator.of(context).pop();
      return ;
    }


    if (this.controllerAmount.text.length == 0) {
      this.showSnackBar('请输入数量');
      Navigator.of(context).pop();
      return ;
    }

    if (this.controllerPrice.text.length == 0) {
      this.showSnackBar('请输入价格');
      Navigator.of(context).pop();
      return ;
    }

    // 先检查授权
    this.checkApprove();
  }

  // 交易授权
  // 进行交易授权, 每一种token，只需要授权一次，目前没有接口确定token是否授权
  // 买入时对右边的token授权，
  // 卖出时对左边的token授权
  // 一句话说明：哪个token要被转出去给其他人，就给哪个token授权
  void checkApprove() async{
    if (this._btnText == '买入') {
      needApproveToken = this.rightToken['address'];
    } else {
      needApproveToken = this.value['address'];
    }

    String res = await TokenService.allowance(context, needApproveToken);
    print('checkApprove res=> ${res}');

//    this.getPwd(false);
    if (res == '0') {
      Navigator.of(context).pop();
      // 授权额度为0，发起提示
      Map currentWallet = Provider.of<walletModel.Wallet>(context).currentWalletObject;
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
    Navigator.pushNamed(context, "getPassword").then((data) async{
      if(data == null) {
        this.showSnackBar('交易终止');
        Navigator.of(context).pop();
        return;
      }

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
        } catch(e) {
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
    if(response['blockHash'] != null) {
      print('授权成功，以太坊返回了交易的blockHash');
      Navigator.of(context).pop();
      this.showSnackBar('授权成功，请重新挂单');
      return true;
    } else {
      if (index > 10) {
        print('已经轮询了10次，授权失败');
        Navigator.of(context).pop();
        this.showSnackBar('授权响应超时，请重新授权');
        return false;
      } else {
        Future.delayed(Duration(seconds: 2), (){
          this.checkAuthResponse(hash, index+1);
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
              content: '为了便于后续兑换，需要您授权youwallet代理。youwallet只会在你授权的情况下才会执行交易，请放心授权！',
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
                      return new LoadingDialog( //调用对话框
                        text: '授权中...',
                      );
                    }
                );
                this.getPwd(false);
              });
        });
  }

  // 获取钱包密码，然后用密码解析私钥
  void startTrade(String pwd) async {
    bool isBuy = true;
    if (this._btnText == '买入') {
      isBuy = true;
    } else {
      isBuy = false;
    }
    if (this.controllerAmount.text is String) {
      print("this.controllerAmount.text is string");
    }
    Trade trade = new Trade(this.value['address'], this.value['name'], this.rightToken['address'], this.rightToken['name'], this.controllerAmount.text, this.controllerPrice.text, isBuy, pwd);
    try {
      await trade.takeOrder();

      // 下单成功后，刷新交易深度和交易记录
      eventBus.fire(OrderSuccessEvent());

      // 下单成功的时候，没必要通知深度列表刷新，以太坊可能还在打包中，刷新也没用
      // eventBus.fire(UpdateTeadeDeepEvent());

      this.setState((){
        currentStatus = "打包中";
      });

      // 通知钱包更新余额，这里延迟2s通知，实际测试发现立即更新余额的话额度不会变
//      Future.delayed(Duration(seconds: 2), (){
//        Provider.of<walletModel.Wallet>(context).updateWallet(Global.getPrefs('currentWallet'));
//      });
    } catch(e) {
      print('+++++++++++++++');
      print(e);
      if(e.toString() == 'RPCError: got code -32000 with msg "insufficient funds for gas * price + value".') {

        this.showSnackBar('钱包ETH余额不足');
      } else {
        this.showSnackBar(e.toString());
      }
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
       return ;
     }

     if (this.controllerPrice.text.length == 0) {
       return ;
     }

     setState(() {
       this.tradePrice = Decimal.parse(this.controllerAmount.text) * Decimal.parse(this.controllerPrice.text);
     });
   }

  // 下拉刷新底部交易列表
  Future<void> _refresh() async {
    eventBus.fire(UpdateTeadeDeepEvent());
    eventBus.fire(CustomTabChangeEvent('当前兑换'));
    eventBus.fire(UpdateOrderListEvent());
    showDialog<Null>(
        context: context, //BuildContext对象
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new LoadingDialog( //调用对话框
            text: '刷新中...',
          );
        });

  }

}

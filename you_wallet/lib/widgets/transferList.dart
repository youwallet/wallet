import 'package:flutter/material.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:youwallet/widgets/modalDialog.dart';
import 'package:youwallet/widgets/loadingDialog.dart';
import 'package:provider/provider.dart';
import 'package:youwallet/model/deal.dart';
import 'package:youwallet/bus.dart';
import 'package:youwallet/service/trade.dart';
import 'package:flutter/services.dart';
import 'package:youwallet/util/number_format.dart';
import 'package:youwallet/global.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:youwallet/widgets/listEmpty.dart';

class transferList extends StatefulWidget {
  transferList({Key key}) : super(key: key);

  TransferListState createState() => new TransferListState();
}

class TransferListState extends State<transferList> {
  final SlidableController slidableController = SlidableController();
  List arr = []; // 控制当前页面中显示的兑换数组
  Map filledAmount = {};
  String currentTab = '当前兑换';

  //数据初始化
  @override
  void initState() {
    super.initState();

    /// tab切换
    eventBus.on<CustomTabChangeEvent>().listen((event) {
      this.currentTab = event.res;
      this.tabChange(event.res);
    });

    /// 用户挂单成功，拿到刚刚挂的订单Hash，查询订单是否成功
    eventBus.on<OrderSuccessEvent>().listen((event) {
      // this.tabChange('当前兑换');
      // this.updateOrderStatus();
    });

    /// 监听兑换页面用户手动触发下拉刷新
    eventBus.on<UpdateOrderListEvent>().listen((event) {
      this.updateOrderFilled();
    });
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
//    List list = await Provider.of<Deal>(context).getTraderList();
//    setState(() {
//      this.arr = List.from(list);
//    });
//      this.tabChange('当前兑换');
  }

  @override
  Widget build(BuildContext context) {
    if (this.arr.length > 0) {
      return new Container(
          padding: const EdgeInsets.only(bottom: 12.0), // 四周填充边距32像素
          child: new Column(
              children: this
                  .arr
                  .reversed
                  .map((item) => buildsilde(item, context))
                  .toList()));
    } else {
      return ListEmpty(text: '还没有交易');
    }
  }

  // 给数据列表中的每一个项包裹一层滑动组件
  Widget buildsilde(item, context) {
    return Slidable(
      controller: slidableController,
      actionPane: SlidableScrollActionPane(), //滑出选项的面板 动画
      actionExtentRatio: 0.25,
      child: this.buildItem(item, context),
      secondaryActions: <Widget>[
        //右侧按钮列表
        IconSlideAction(
          caption: '订单详情',
          color: Colors.blue,
          icon: Icons.assignment,
          onTap: () {
            //print(item);
            //this.copyHash(item);
            Navigator.pushNamed(context, "order_detail", arguments: item);
          },
        ),
        this.buildRightAction(context, item)
      ],
    );
  }

  // 构建滑动后右侧出现的小部件
  Widget buildRightAction(context, item) {
    if (item['status'] == '挂单中' || item['status'] == '打包中') {
      return IconSlideAction(
        caption: '撤销',
        color: Colors.red,
        icon: Icons.undo,
        closeOnTap: true,
        onTap: () {
          this.cancelTrade(context, item);
        },
      );
    } else {
      return IconSlideAction(
        caption: '删除',
        color: Colors.red,
        icon: Icons.delete,
        closeOnTap: true,
        onTap: () {
          this.delTrade(context, item);
        },
      );
    }
  }

  Widget buildItem(item, context) {
    String date = DateUtil.formatDateMs(int.parse(item['createTime']),
        format: "yyyy-MM-dd HH:mm:ss");
    String filled = '';
    if (item['status'] == '成功') {
      filled = item['filled'];
    } else {
      filled = this.filledAmount.containsKey(item['txnHash'])
          ? this.filledAmount[item['txnHash'].toString()]
          : item['filled'];
    }
    return new Container(
        padding: const EdgeInsets.only(top: 10.0, bottom: 10.0), // 四周填充边距32像素
        decoration: new BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.black26, width: 1.0)),
        ),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Row(
                  children: <Widget>[
                    new Text('${item['orderType']}',
                        style: new TextStyle(
                            color: item['orderType'] == '买入'
                                ? Colors.green
                                : Colors.deepOrange)),
                    new Text('   ${date}'),
                  ],
                ),
                new Row(
                  children: <Widget>[
                    item['status'] == '失败'
                        ? Icon(Icons.error, size: 16.0, color: Colors.red)
                        : Text(''),
                    item['status'] == '交易失败'
                        ? Icon(Icons.error, size: 16.0, color: Colors.red)
                        : Text(''),
                    item['status'] == '打包中'
                        ? new SpinKitFadingCircle(
                            color: Colors.deepOrange, size: 12.0)
                        : Text(''),
                    item['status'] == '撤销中'
                        ? new SpinKitFadingCircle(
                            color: Colors.deepOrange, size: 12.0)
                        : Text(''),
                    new Text(item['status'] ?? '进行中',
                        style: new TextStyle(color: Colors.deepOrange)),
                    // new SpinKitFadingCircle(color: Colors.blueAccent, size: 12.0)
                  ],
                )
              ],
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Text(
                  '${item['price']} (${item['baseTokenName']})',
                ),
                new Text(
                    '${item['filled']}/${item['amount']}(${item['tokenName']})',
                    style: new TextStyle(color: Colors.lightBlue))
              ],
            ),
          ],
        ));
  }

  /// 撤销一笔交易
  /// 撤销是一个休要时间的过程，增加【撤销中】的loading状态
  void cancelTrade(BuildContext context, Map item) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return GenderChooseDialog(
              title: '确定撤销交易?',
              content: '',
              onSuccessChooseEvent: () async {
                Navigator.pop(context);
                Navigator.pushNamed(context, "getPassword").then((data) async {
                  if (data == null) {
                    print('取消密码输入');
                  } else {
                    this.cancelProcess(item, data);
                  }
                });
              },
              onCancelChooseEvent: () {
                Navigator.pop(context);
              });
        });
  }

  /// 撤销订单的进程，不会立刻拿到结果
  /// 注意这里的obj,里面有四个字段
  void cancelProcess(Map item, Map obj) async {
    try {
      // 订单撤销后立即返回的是交易的hash，
      // 至于到底有没有撤销成功，还需要等待以太坊写链
      String res = await Trade.cancelOrder(item, obj);
      print('订单撤销返回 => ${res}');
      eventBus.fire(TransferDoneEvent('撤销中'));
      await Provider.of<Deal>(context)
          .updateOrderStatus(item['txnHash'], '撤销中');
      this.tabChange(this.currentTab);
    } catch (e) {
      print(e);
      eventBus.fire(TransferDoneEvent(e.toString()));
    }
  }

  // 删除历史记录
  // 删除本地客户端保存的交易记录
  void delTrade(BuildContext context, Map item) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return GenderChooseDialog(
              title: '确定删除记录?',
              content: '',
              onCancelChooseEvent: () {
                print('onCancelChooseEvent');
                Navigator.pop(context);
                // eventBus.fire(TransferDoneEvent('l'));
              },
              onSuccessChooseEvent: () async {
                int i =
                    await Provider.of<Deal>(context).deleteTrader(item['id']);
                // 用bus向兑换页面发出删除成功的通知，兑换页面显示toast
                if (i == 1) {
                  this
                      .arr
                      .removeWhere((element) => element['id'] == item['id']);
                  setState(() {
                    this.arr;
                  });
                  eventBus.fire(TransferDoneEvent('删除成功'));
                }
                Navigator.pop(context);
              });
        });
  }

  // tab切换, 切换显示的数据，这里不刷新
  // 这里list需要用List.from转化一次，否则会提示read only
  // 注意：这里只是切换数据的显示，并不负责刷新
  void tabChange(String tab) async {
    print('start tabChange ${tab}');
    List res = await Provider.of<Deal>(context).getTraderList();
    List list = List.from(res);
    if (tab == '当前兑换') {
      list.retainWhere((element) => (element['status'] == '挂单中' ||
          element['status'] == '打包中' ||
          element['status'] == '撤销中'));
    } else {
      list.retainWhere((element) => (element['status'] != '挂单中' &&
          element['status'] != '打包中' &&
          element['status'] != '撤销中'));
    }
    setState(() {
      this.arr = list;
    });
  }

  /// 从本地数据库中拿出所有进行中和打包中的订单
  /// 遍历每个订单的状态，获取匹配额度
  /// 将查询到的匹配数量保存在数据库中
  /// 如果订单中的数量已经匹配完毕，则代表这个订单转账成功，刷新的时候不再遍历
  /// 如果订单匹配还在进行中，判断一下这个订单是否还有效（因为它可能被取消了）
  /// 最后通知顶层页面，刷新结束
  Future<void> updateOrderFilled() async {
    List list = List.from(await Provider.of<Deal>(context).getTraderList());
    for (var i = list.length - 1; i >= 0; i--) {
      // print(list[i]);
      if (list[i]['status'] == '进行中' ||
          list[i]['status'] == '挂单中' ||
          list[i]['status'] == '打包中' ||
          list[i]['status'] == '撤销中') {
        // 检查订单状态，订单可能因为余额被合约移除，
        // 这里要对进行中和打包中的订单再次确认一遍状态
        print("查询第${i}个订单，状态是${list[i]['status']}");
        await this.updateOrder(list[i]);
      } else {
        // if (double.parse(list[i]['amount']) !=
        //     double.parse(list[i]['filled'])) {
        //   await this.updateOrder(list[i]);
        // } else {}
        // print("查询第${i}个订单，状态是${list[i]['status']}, 不发起请求");
        //print('该订单状态为${this.arr[i]['status']},已匹配完毕');
      }
    }
    // setState(() {
    //   this.filledAmount = filled;
    // });
    // this.updateList();
    this.tabChange(this.currentTab);
  }

  // 更新订单，更新的值包括订单匹配的数量和订单的状态
  // 如果一个订单已经是撤销中的状态
  Future<void> updateOrder(Map order) async {
    print('【updateOrder】');
    double amount = await Trade.getFilled(order['odHash']);
    // transactionReceipt有可能是null
    var transactionReceipt = await Trade.getTransactionReceipt(order);
    print('transactionReceipt => ${transactionReceipt}');
    if (transactionReceipt != null && transactionReceipt['status'] == '0x0') {
      await Provider.of<Deal>(context)
          .updateOrderStatus(order['txnHash'], '交易失败');
    } else {
      await Provider.of<Deal>(context)
          .updateFilled(order, amount.toStringAsFixed(4));
      print(order);
      var res = await Trade.orderFlags(order['odHash']);
      if (order['status'] == '撤销中' && res == '打包中') {
        res = '撤销中';
      }
      await Provider.of<Deal>(context).updateOrderStatus(order['txnHash'], res);
    }
  }

  /// 订单匹配状态查询完毕，整体更新一次列表
  // void updateList() async {
  //   List list = List.from(await Provider.of<Deal>(context).getTraderList());
  //   list.retainWhere((element) => (element['status'] == '进行中' ||
  //       element['status'] == '挂单中' ||
  //       element['status'] == '打包中'));
  //   setState(() {
  //     this.arr = list;
  //   });
  // }

  /// 点击订单复制订单的hash
  void copyHash(Map item) {
    ClipboardData data = new ClipboardData(text: item['txnHash']);
    Clipboard.setData(data);
    eventBus.fire(TransferDoneEvent('订单复制成功'));
  }

  /// 拿到订单列表中最新的一个订单状态为打包中的订单，查询订单状态
  void updateOrderStatus() async {
    print('start updateOrderStatus');
    List list = await Provider.of<Deal>(context).getTraderList();
    Map order =
        list.lastWhere((e) => e['status'] == '打包中', orElse: () => (null));
    if (order == null) {
      print('no order');
      return;
    } else {
      this.checkOrderStatus(order['txnHash'], 0);
    }
  }

  // 根据Hash值检查一个交易在ETH的状态
  // 这一步发生在用户刚刚下单后，以太坊立刻返回了Hash，但是我们并不知道这个订单是否成功写到链上
  // 所以需要轮询，2s中一次，最长轮询50次，30次还是有点少
  // 当以太坊返回blockHash后，我们就知道这个订单已经被以太坊写到链上
  // 但是写链成功并不代表挂单成功，还要通过getTransactionReceipt来判断是成功了还是失败
  // 判断完成后，立刻刷新历史交易列表
  void checkOrderStatus(String hash, int index) async {
    int countRequest = 0;
    Map response;
    Future.doWhile(() {
      print('start dowhile again');
      if (countRequest > 30) {
        print('订单打包超时，请重新下单');
        eventBus.fire(TransferDoneEvent('订单打包超时，请下拉刷新'));
        return false;
      }

      if (response != null && response['blockHash'] != null) {
        return false;
      }
      countRequest += 1;
      return new Future.delayed(new Duration(seconds: 2), () async {
        print('第$countRequest次查询');
        response = await Trade.getTransactionByHash(hash);
        return true;
      });
    }).then((res) async {
      if (response['blockHash'] != null) {
        // 以太坊返回了交易的blockHash, 以太坊写链操作结束
        // 现在判断写链操作的状态
        Map res = await Trade.getTransactionReceipt({'txnHash': hash});
        if (res['status'] == '0x1') {
          print('轮询结束，下单成功，更改状态为进行中,广播 TransferDoneEvent事件');
          await Provider.of<Deal>(context).updateOrderStatus(hash, '进行中');
          eventBus.fire(TransferDoneEvent('打包成功，订单状态变更为进行中'));
        } else {
          await Provider.of<Deal>(context).updateOrderStatus(hash, '失败');
          eventBus.fire(TransferDoneEvent('挂单失败'));
        }
        eventBus.fire(TransferUpdateStartEvent());
        this.updateOrderFilled();
      }
    }).catchError(print);
  }
}

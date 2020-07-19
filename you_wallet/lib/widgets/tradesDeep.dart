import 'package:flutter/material.dart';
//import 'package:common_utils/common_utils.dart';
//import 'package:flutter_slidable/flutter_slidable.dart';
//import 'package:youwallet/widgets/modalDialog.dart';
//import 'package:provider/provider.dart';
//import 'package:youwallet/model/deal.dart';
import 'package:youwallet/bus.dart';
//import 'package:provider/provider.dart';
//import 'package:youwallet/model/deal.dart';
import 'package:youwallet/service/trade.dart';
import 'package:youwallet/global.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import 'package:youwallet/model/network.dart';

// 交易深度列表组件
// 接受两个参数，左边的token和右边的token
class TradesDeep extends StatefulWidget {
  String leftToken;
  String rightToken;

  TradesDeep({
    Key key,
    this.leftToken,
    this.rightToken,
  }) : super(key: key);

  Page createState() => new Page();
}

class Page extends State<TradesDeep> {
  List arr = [];
  bool showMore = false;
  //数据初始化
  @override
  void initState() {
    super.initState();

    eventBus.on<UpdateTeadeDeepEvent>().listen((event) {
      this.getOrderDeep();
    });

    this.getOrderDeep();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return new Column(children: <Widget>[
      new Column(
          children: this.arr.map((item) => buildItem(item, context)).toList()),
      buildMore()
    ]);
  }

  Widget buildMore() {
    if (this.showMore) {
      return Container(
          margin: const EdgeInsets.only(top: 10.0),
          child: GestureDetector(
            child:
                new Text('点击查看全部交易', style: TextStyle(color: Colors.lightBlue)),
            onTap: () {
              //            eventBus.fire(TransferUpdateStartEvent());
              Map leftToken = {'address': widget.leftToken};
              Map rightToken = {'address': widget.rightToken};
              Navigator.pushNamed(context, "order_deep", arguments: {
                'leftToken': leftToken,
                'rightToken': rightToken
              });
            },
          ));
    } else {
      return Text('');
    }
  }

  // 构建深度列表每个项
  Widget buildItem(item, context) {
    return new Container(
      color: Colors.black12, //16进制颜色
      padding: const EdgeInsets.all(4.0),
      margin: const EdgeInsets.only(top: 10.0),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          new Text(item['price'],
              style: TextStyle(
                  color: item['is_sell'] ? Colors.deepOrange : Colors.green),
              overflow: TextOverflow.fade),
//          new Icon(
//              Icons.close,
//              size: 20.0,
//              color: item['is_sell'] ? Colors.deepOrange : Colors.green
//          ),
          new Text(item['amount'].toString(), overflow: TextOverflow.fade),
        ],
      ),
    );
  }

  /// 先获取卖单队列，再获取买单队列
  /// 如果有一边的token还没有选择，则不更新
  /// 兑换页面的深度交易列表，最多只能显示6个订单
  Future<void> getOrderDeep() async {
    if ('mainnet' == Provider.of<Network>(context).network) {
      Global.showSnackBar(context, '当前网络不支持，请切换测试网');
      return;
    }

    try {
      List list =
          await Trade.getOrderDepth(widget.leftToken, widget.rightToken);

      // 如果订单超过6个，兑换页面只给显示6个
      // 永远只显示三个卖，三个买
      // 如果数量不足三个，则留空位
      List sell = list.where((element) => (element['is_sell'])).toList();
      List buy = list.where((element) => (!element['is_sell'])).toList();

      // 任意一个买单或者卖单超过3个，就显示更新按钮
      if (sell.length > 3 || buy.length > 3) {
        this.setState(() {
          showMore = true;
        });
      } else {
        this.setState(() {
          showMore = false;
        });
      }

      // 卖单超过三个，要倒着取三个出来
      if (sell.length > 3) {
        sell = sell.skip(sell.length - 3).toList();
      }
      buy = buy.take(3).toList();
      if (sell.length < 3) {
        int i = 0;
        int len = 3 - sell.length;
        while (i < len) {
          sell.insert(0, {'price': '-', 'amount': '-', 'is_sell': true});
          i = i + 1;
        }
      }
      if (buy.length < 3) {
        // sell这里需要特别注意
        // sell数组中价格是从高到低排列的，
        // 但是兑换页面只需要显示价格最低的三个
        // sell = sell.skip(buy.length).toList();
        int i = 0;
        int len = 3 - buy.length;
        while (i < len) {
          buy.add({'price': '-', 'amount': '-', 'is_sell': false});
          i = i + 1;
        }
      }

      sell.addAll(buy);
      this.setState(() {
        arr = sell;
      });
    } catch (e) {
      print('深度列表数据出现异常');
      print(e.toString());
    }

//    print('getSellList start');
//    print(widget.leftToken);
//    print(widget.rightToken);
//    if (widget.leftToken.length == 0) {
//      print('left not sellect');
//      return;
//    }
//
//    if (widget.rightToken.length == 0) {
//      print('right not sellect');
//      return;
//    }
//
//    setState(() {
//      this.arr = [];// 清空当前的深度数组
//    });
//
////    String tokenAddress = this.value['address'];
////    String baseTokenAddress = this.rightToken['address'];
//    bool isSell = true;
//    String hash = await Trade.getOrderQueueInfo(widget.leftToken, widget.rightToken, isSell);
//    String bqHash = hash.replaceFirst('0x', '').substring(0,64);
//    String queueElem = await Trade.getOrderInfo(hash, isSell);
//    this.deepCallBackOrderInfo(queueElem, bqHash, isSell);
  }

  // 获取当前的买单队列
  Future<void> getBuyList() async {
//    String tokenAddress = this.value['address']; // 左边的token
//    String baseTokenAddress = this.rightToken['address']; // 右边的token
    bool isSell = false;
    // 拿到队列中第一个订单的 bq_hash + od_hash
    String hash = await Trade.getOrderQueueInfo(
        widget.leftToken, widget.rightToken, isSell);
    // 把hash中的bq hash单独拿出来，同一个队列中的bq hash都是相同的 拿到QueueElem的订单结构体
//    print('getBuyList hash => ${hash}');
    String bqHash = hash.replaceFirst('0x', '').substring(0, 64);
    String odHash = hash.replaceFirst('0x', '').substring(64);

    String queueElem = await Trade.getOrderInfo(hash, isSell);
    this.deepCallBackOrderInfo(queueElem, bqHash, isSell);
  }

  // 递归获取订单信息
  // queueElem后64位，是下一个订单的odHash,
  // 以前的bqHash + 下一个订单的odHash，拼接成新的hash，继续获取下一个订单
  Future<void> deepCallBackOrderInfo(
      String queueElem, String bqHash, bool isSell) async {
    this.buildQueueElem(queueElem.replaceFirst('0x', ''), isSell);
    String odHash = queueElem.substring(queueElem.length - 64);
    String nextHash = bqHash + odHash;
    String nextQueueElem = await Trade.getOrderInfo(nextHash, isSell);
    if (nextQueueElem != '0x' &&
        odHash !=
            '0000000000000000000000000000000000000000000000000000000000000000') {
      // 同一种类型的订单，达到三个就不再继续获取
      this.deepCallBackOrderInfo(nextQueueElem, bqHash, isSell);
    } else {
      //print('订单队列结束, 最后一个订单的odHash => ${odHash}');
      if (isSell) {
        // 卖单队列获取完毕，开始获取买单队列
        this.getBuyList();
      } else {
        print('deepCallBackOrderInfo =》 done');
      }
    }
  }

  // 解析queueElem 深度列表的数据需要合并处理，规则如下
  // https://github.com/youwallet/wallet/issues/44#issuecomment-575859132
  void buildQueueElem(String queueElem, bool isSell) {
    BigInt filled = BigInt.parse(
        queueElem.substring(queueElem.length - 128, queueElem.length - 64),
        radix: 16);
    // print(filled);
    // print(queueElem.replaceFirst('0x', '').substring(64, 128));
    BigInt baseTokenAmount = BigInt.parse(
        queueElem.replaceFirst('0x', '').substring(64, 128),
        radix: 16);
    // print(baseTokenAmount);
    // BigInt quoteTokenAmount = BigInt.parse(queueElem.replaceFirst('0x', '').substring(128, 192));
    BigInt quoteTokenAmount = BigInt.parse(
        queueElem.replaceFirst('0x', '').substring(128, 192),
        radix: 16);
//    print("=======================================");
//    print("baseTokenAmount   => ${baseTokenAmount}");
//    print("quoteTokenAmount  => ${quoteTokenAmount}");
//    print("左边显示价格        => ${baseTokenAmount/quoteTokenAmount}");
//    print("filled            => ${filled}");
//    print("右边显示数量        => ${baseTokenAmount - filled}");
//    print("isSell            => ${isSell}");
    if (baseTokenAmount != BigInt.from(0)) {
      String left = (quoteTokenAmount / baseTokenAmount)
          .toStringAsFixed(Global.priceDecimal);

      // 这里的baseTokenAmount是包含18小数位数的10进制数据，先砍掉小数位
      // 标准做法是根据token对应的小数位
      double right = (baseTokenAmount - filled) / BigInt.from(pow(10, 18));
      int index = this.arr.indexWhere(
          (element) => element['left'] == left && element['isSell'] == isSell);

      if (index == -1) {
        Map obj = {
          'left': left,
          'right': right.toStringAsFixed(Global.numDecimal),
          'isSell': isSell
        };
        if (isSell) {
          // 如果队列中买单数量已经达到三个，就不要再向队列中增加
          int lenSellOrder = this.arr.where((e) => (e['isSell'])).length;
          if (lenSellOrder < 3) {
            setState(() {
              this.arr.insert(0, obj);
            });
          } else {
            print('卖单队列已经到达三个，第四个开始不显示 => ${obj}');
          }
        } else {
          // 如果队列中买单数量已经达到三个，就不要再向队列中增加
          int lenBuyOrder = this.arr.where((e) => (!e['isSell'])).length;
          if (lenBuyOrder < 3) {
            setState(() {
              this.arr.add(obj);
            });
          } else {
            print('买单队列已经到达三个，第四个开始不显示 => ${obj}');
          }
        }
      } else {
        // 价格相同的订单合并，数量相加即可
        setState(() {
          this.arr[index]['right'] =
              (double.parse(this.arr[index]['right']) + right)
                  .toStringAsFixed(Global.numDecimal);
        });
        print(this.arr);
      }
    }
  }
}

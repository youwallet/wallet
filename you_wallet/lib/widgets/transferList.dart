import 'package:flutter/material.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:youwallet/widgets/modalDialog.dart';
import 'package:provider/provider.dart';
import 'package:youwallet/model/deal.dart';
import 'package:youwallet/bus.dart';
import 'package:provider/provider.dart';
import 'package:youwallet/model/deal.dart';
import 'package:youwallet/service/trade.dart';

class transferList extends StatefulWidget {

//  List arr = [];
//  Map filledAmount = {};

  transferList({Key key}) : super(key: key);

  Page createState() => new Page();
}

class Page extends State<transferList> {

  final SlidableController slidableController = SlidableController();
  List arr = []; // 控制当前页面中显示的兑换数组
  Map filledAmount = {};

  //数据初始化
  @override
  void initState() {
    super.initState();

    /// tab切换
    eventBus.on<CustomTabChangeEvent>().listen((event) {
      print('change in component');
      this.tabChange(event.res);
    });

    /// 用户挂单成功
    eventBus.on<OrderSuccessEvent>().listen((event) {
      this.tabChange('当前兑换');
    });
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
//    List list = await Provider.of<Deal>(context).getTraderList();
//    setState(() {
//      this.arr = List.from(list);
//    });
      this.tabChange('当前兑换');
  }


  @override
  Widget build(BuildContext context) {
    return new Container(
        padding: const EdgeInsets.only(bottom: 12.0), // 四周填充边距32像素
        child: new Column(
          children: this.arr.reversed.map((item) => buildsilde(item, context)).toList()
        )
    );
  }

  // 给数据列表中的每一个项包裹一层滑动组件
  Widget buildsilde(item, context) {
    return Slidable(
      controller: slidableController,
      actionPane: SlidableScrollActionPane(),//滑出选项的面板 动画
      actionExtentRatio: 0.25,
      child: this.buildItem(item, context),
      secondaryActions: <Widget>[//右侧按钮列表
        this.buildRightAction(context, item)
      ],
    );
  }

  // 构建滑动后右侧出现的小部件
  Widget buildRightAction(context, item){
    if (item['status'] == '转账中' || item['status'] == '进行中' || item['status'] == '') {
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
//    print(item);
    String date = DateUtil.formatDateMs( int.parse( item['createTime']), format: DataFormats.full);
    String filled = '';
    if (item['status'] == '成功'){
      filled = item['filled'];
    } else {
      filled = this.filledAmount.containsKey(item['txnHash'])?this.filledAmount[item['txnHash'].toString()]:item['filled'];
    }
    return new Container(
        padding: const EdgeInsets.only(top:10.0, bottom: 10.0), // 四周填充边距32像素
        decoration: new BoxDecoration(
           border: Border(bottom: BorderSide(color: Colors.black26,width: 1.0)),
//           color: Colors.lightBlue,
        ),
        child: new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Row(
                children: <Widget>[
                  new Text(
                      '${item['orderType']}',
                      style: new TextStyle(
                          color: item['orderType']== '买入' ? Colors.green : Colors.deepOrange
                      )
                  ),
                  new Text('   ${date}'),
                ],
              ),
              new Text(
                  item['status']??'进行中',
                  style: new TextStyle(
                      color: Colors.deepOrange
                  )
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
                  '${filled.toString()}/${item['amount']}(${item['tokenName']})',
                  style: new TextStyle(
                      color: Colors.lightBlue
                  )
              )
            ],
          ),
        ],
      )
    );

  }

  // 取消交易
  void cancelTrade(BuildContext context, Map item){
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return GenderChooseDialog(
              title: '确定撤销交易?',
              content: '',
              onSuccessChooseEvent: () async {
                eventBus.fire(TransferDoneEvent('撤销交易失败，接口暂不可用'));
                Navigator.pop(context);
              },
              onCancelChooseEvent: () {
                Navigator.pop(context);
              });

        });
  }

  // 删除历史记录
  void delTrade(BuildContext context, Map item){
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return GenderChooseDialog(
              title: '确定删除记录?',
              content: '',
              onSuccessChooseEvent: () async {
                Navigator.pop(context);
                int i = await Provider.of<Deal>(context).deleteTrader(item['id']);
                // 用bus向兑换页面发出删除成功的通知，兑换页面显示toast
                if (i == 1) {
                  this.arr.removeWhere((element) => element['id']==item['id']);
                  setState(() {
                    this.arr;
                  });
                  eventBus.fire(TransferDoneEvent('删除成功'));
                }
              });
        });
  }

  // tab切换
  // 这里list需要用List.from转化一次，否则会提示read only
  void tabChange(String tab) async {
    print("tabChange start");
    List list = List.from(await Provider.of<Deal>(context).getTraderList());
    print(list);
    //    int now = DateTime.now().millisecondsSinceEpoch;
//    int hour = DateTime.now().hour;
//    int minute = DateTime.now().minute;
//    int second = DateTime.now().second;
//    int today = now - (hour*60*60 + minute*60 + second)*1000;

    if (tab == '当前兑换') {
      list.retainWhere((element)=>(element['status']=='进行中' ));
      print(list);
    } else {
      list.retainWhere((element)=>(element['status']!='进行中'));
    }
    setState(() {
      this.arr = list;
    });
    this._getTradeInfo();
  }

  /// 遍历每个订单的状态
  /// 将查询到的匹配数量保存在数据库中
  /// 如果订单中的数量已经匹配完毕，则代表这个订单转账成功，刷新的时候不再遍历
  Future<void> _getTradeInfo() async {
    Map filled = {};
    for(var i = 0; i<this.arr.length; i++) {
      //print('查询订单   =》${this.arr[i]['txnHash']}');
      if(this.arr[i]['status'] != '成功') {
        double amount = await Trade.getFilled(this.arr[i]['odHash']);
        print('匹配情况   =》${amount}');
        int sqlRes = await Provider.of<Deal>(context).updateFilled(
            this.arr[i], amount.toStringAsFixed(2));
        filled[this.arr[i]['txnHash']] = amount.toStringAsFixed(2);
      } else {
        //print('该订单状态为${this.arr[i]['status']},已匹配完毕');
      }
    }
    setState(() {
      this.filledAmount = filled;
    });
    print(this.filledAmount);
  }


}
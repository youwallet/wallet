import 'package:flutter/material.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:youwallet/widgets/modalDialog.dart';
import 'package:provider/provider.dart';
import 'package:youwallet/model/deal.dart';
import 'package:youwallet/bus.dart';

class transferList extends StatefulWidget {

  List arr = [];
  Map filledAmount = {};

  transferList({Key key, this.arr, this.filledAmount }) : super(key: key);

  Page createState() => new Page();
}

class Page extends State<transferList> {

  final SlidableController slidableController = SlidableController();

  @override
  Widget build(BuildContext context) {
    return new Container(
        padding: const EdgeInsets.only(bottom: 12.0), // 四周填充边距32像素
        child: new Column(
          children: widget.arr.reversed.map((item) => buildsilde(item, context)).toList()
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
      filled = widget.filledAmount.containsKey(item['txnHash'])?widget.filledAmount[item['txnHash'].toString()]:'0.0';
    }
    return new Container(
        padding: const EdgeInsets.all(10.0), // 四周填充边距32像素
        decoration: new BoxDecoration(
           border: Border(bottom: BorderSide(color: Colors.black26,width: 1.0)),
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
              title: '确定取消交易?',
              content: '',
              onSuccessChooseEvent: () async {
                print('cancel ok');
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
                  widget.arr.removeWhere((element) => element['id']==item['id']);
                  setState(() {
                    widget.arr;
                  });
                  eventBus.fire(TransferDoneEvent('删除成功'));
                }
              });
        });
  }

}
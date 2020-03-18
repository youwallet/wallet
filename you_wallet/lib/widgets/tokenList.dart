import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youwallet/model/token.dart';
import 'package:youwallet/widgets/listEmpty.dart';
import 'package:youwallet/global.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

// 类的名字需要大写字母开头
class tokenList extends StatelessWidget {

  List arr = [];
  String network = "ropsten";
  Map currentWalletObject = {};
  tokenList({Key key, this.arr, this.network="ropsten", this.currentWalletObject}) : super(key: key);

  final SlidableController slidableController = SlidableController();

  @override
  Widget build(BuildContext context) {
    List filterArr = [];
    this.arr.forEach((element){
      // 必须当前你选择的网络和当前你的钱包地址
      if (element['network'] == this.network && element['wallet'] == this.currentWalletObject['address']) {
        filterArr.add(element);
      }
    });
    if (filterArr!= null && filterArr.length == 0) {
      return new ListEmpty(
        text: '还没有token，请先添加'
      );
    } else {
      return Column(
        children: filterArr.reversed.map((item) => buildSilde(item, context))
            .toList(),
      );
    }
  }

  // 给数据列表中的每一个项包裹一层滑动组件
  Widget buildSilde(item, context) {
    return Slidable(
      controller: slidableController,
      actionPane: SlidableScrollActionPane(),//滑出选项的面板 动画
      actionExtentRatio: 0.25,
      child: walletCard(item, context),
      secondaryActions: <Widget>[//右侧按钮列表
        IconSlideAction(
          caption: '删除',
          color: Colors.blue,
          icon: Icons.delete,
          onTap: () async {
            await Provider.of<Token>(context).remove(item);
            
          },
        )
      ],
    );
  }
}




Widget walletCard(item, context) {
  return new Card(
        color: Colors.white, //背景色
        child: new Container(
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.all(28.0),
              child: new Row(
                children: <Widget>[
                  new Container(
                    margin: const EdgeInsets.only(right: 16.0),
//                    decoration: new BoxDecoration(
//                      border: new Border.all(width: 2.0, color: Colors.black26),
//                      borderRadius: new BorderRadius.all(new Radius.circular(20.0)),
//                    ),
                    child: Icon(IconData(0xe648, fontFamily: 'iconfont'),size: 50.0, color: Colors.black26)
                  ),
                  new Expanded(
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        new Row(
                          children: <Widget>[
                            new Text(
                              item['name']?? '--',
                              style: new TextStyle(fontSize: 32.0, color: Colors.black),
                            ),
                            new IconButton(
                              icon: Icon(IconData(0xe600, fontFamily: 'iconfont')),
                              onPressed: () {
                                print(item);
                                Navigator.pushNamed(context, "token_info",arguments:{
                                   'address': item['address'],
                                 });
                              },
                            ),
                          ],
                        ),
                        GestureDetector(
                          child: new Text(
                              Global.maskAddress(item['address']),
                              style: TextStyle(
                                  fontWeight: FontWeight.w700
                              )
                          ),
                          onTap: () async {
                            print(item['address']);
                          },
                        )

                      ],
                    ),
                  ),
                  new Text(
                    item['balance'],
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: new TextStyle(
                        fontSize: 16.0,
                        color: Color.fromARGB(100, 6, 147, 193),
                        fontWeight: FontWeight.w700
                    ),
                  ),
//                  new Container(
//                      alignment: Alignment.topRight,
//                      color: Colors.red,
//                      width: 80.0,
//                      child: new Column(
//                        children: <Widget>[
//                          new Text(
//                            item['balance'],
//                            overflow: TextOverflow.ellipsis,
//                            maxLines: 1,
//                            style: new TextStyle(fontSize: 16.0,
//                                color: Color.fromARGB(100, 6, 147, 193)),
//                          ),
////                          new Text('￥${item['rmb']??'-'}'),
//                        ],
//                      )
//
//                  )
                ],
              )
          ),
  );
}


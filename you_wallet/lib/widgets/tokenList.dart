import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youwallet/model/token.dart';
import 'package:youwallet/model/viewModel.dart';
import 'package:youwallet/widgets/listEmpty.dart';
import 'package:youwallet/widgets/tokenLogo.dart';
import 'package:youwallet/widgets/tokenCard.dart';
import 'package:youwallet/global.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:youwallet/widgets/customButton.dart';

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
      if (element['wallet'] == this.currentWalletObject['address']) {
        filterArr.add(element);
      }
    });
    if (filterArr!= null && filterArr.length == 0) {
      return Column(
        children: <Widget>[
          ListEmpty(
            text: '还没有token，请先添加'
          ),
          new CustomButton(
              content: '添加token',
              onSuccessChooseEvent:(res) async{
                 Navigator.pushNamed(context, "add_token",arguments: {});
              }
          )
        ],
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
    TokenCardViewModel cardData = TokenCardViewModel(
      bankName: item['name'],
      bankLogoUrl: 'assets/images/icon.png',
      cardType: '以太坊',
      cardNumber: item['address'],
      cardColors: [Color(0xFFF17B68), Color(0xFFE95F66)],
      balance: item['balance'],
    );
    return Slidable(
      controller: slidableController,
      actionPane: SlidableScrollActionPane(),//滑出选项的面板 动画
      actionExtentRatio: 0.25,
      child: TokenCard(
        data: cardData
      ),
      secondaryActions: <Widget>[//右侧按钮列表
        IconSlideAction(
          caption: '删除',
          // color: Color(0xfff56c6c),
          icon: Icons.delete,
          onTap: () async {
            await Provider.of<Token>(context).remove(item);
          },
        )
      ],
    );
  }
}

//Widget buildTokenIcon(String address) {
//  Map token = Global.hotToken.firstWhere((element)=>(element['address'] == address),orElse: ()=>({}));
//  print(token);
//  if (token.isEmpty) {
//    return Icon(IconData(0xe648, fontFamily: 'iconfont'),size: 50.0, color: Colors.black26);
//  } else {
//    return Icon(IconData(token['icon'], fontFamily: 'iconfont'),size: 50.0, color: token['color']);
//  }
//}


//Widget walletCard(item, context) {
//  return new Card(
//        color: Colors.white, //背景色
//        child: new Container(
//              alignment: Alignment.topCenter,
//              padding: const EdgeInsets.all(28.0),
//              child: new Row(
//                children: <Widget>[
//                  new Container(
//                    margin: const EdgeInsets.only(right: 16.0),
//                    child: TokenLogo(address: item['address'])
//                  ),
//                  new Expanded(
//
//                    child: new Column(
//                      crossAxisAlignment: CrossAxisAlignment.start,
//                      children: <Widget>[
//                        new Row(
//                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                          children: <Widget>[
//                            new Column(
//                              children: [
//                                new Row(
//                                  children: <Widget>[
//                                    new Text(
//                                      item['name']?? '--',
//                                      style: new TextStyle(fontSize: 32.0, color: Colors.black),
//                                    ),
//                                    new IconButton(
//                                      icon: Icon(IconData(0xe600, fontFamily: 'iconfont')),
//                                      onPressed: () {
//                                        print(item);
//                                        Navigator.pushNamed(context, "token_info",arguments: item);
//                                      },
//                                    ),
//                                  ],
//                                ),
//                              ],
//                            ),
//                            new Text(
//                              item['balance'],
//                              overflow: TextOverflow.ellipsis,
//                              maxLines: 1,
//                              style: new TextStyle(
//                                  fontSize: 16.0,
//                                  color: Color.fromARGB(100, 6, 147, 193),
//                                  fontWeight: FontWeight.w700
//                              ),
//                            )
//                          ],
//                        ),
//                        new Container(
//                          child: GestureDetector(
//                              child: new Text(
//                                  Global.maskAddress(item['address']),
//                                  style: TextStyle(
//                                      fontWeight: FontWeight.w700
//                                  )
//                              ),
//                              onTap: () {
//                                print(item['address']);
//                              },
//                            ),
//                        )
//                      ],
//                    )
//                  ),
//                ],
//              )
//          ),
//  );
//}


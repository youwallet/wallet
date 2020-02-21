import 'package:flutter/material.dart';
import 'package:youwallet/service/token_service.dart' ;
import 'package:provider/provider.dart';
import 'package:youwallet/model/token.dart';
import 'package:youwallet/widgets/listEmpty.dart';

// 类的名字需要大写字母开头
class tokenList extends StatelessWidget {

  List arr = [];
  String network = "ropsten";
  String currentWallet = "";
  tokenList({Key key, this.arr, this.network="ropsten", this.currentWallet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List filterArr = [];
    return new ListEmpty(
        text: '还没有token，请先添加'
    );
    this.arr.forEach((element){
      // 必须当前你选择的网络和当前你的钱包地址
      if (element['network'] == this.network && element['wallet'] == this.currentWallet) {
        filterArr.add(element);
      }
    });
    if (filterArr!= null && filterArr.length == 0) {
      return new ListEmpty(
        text: '还没有token，请先添加'
      );
    } else {
      return Column(
        children: filterArr.reversed.map((item) => walletCard(item, context))
            .toList(),
      );
    }
  }
}


Widget walletCard(item, context) {
  return new Dismissible(
      background: Container(
          color: Colors.red,
          child: Center(
            child: Text("删除",
              style: TextStyle(
                  color: Colors.white
              ),
            ),
          )
      ),
      key: new Key(item['id'].toString()),
      onDismissed: (direction) {
        // 更新token model中的token数组
        Provider.of<Token>(context).remove(item);
        final snackBar =  SnackBar(content: new Text("移除成功"));
        Scaffold.of(context).showSnackBar(snackBar);
      },
      child: new Card(
        color: Colors.white, //背景色
        child: new Container(
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
                          child: new Text(TokenService.maskAddress(item['address'])),
                          onTap: () async {
                            print(item['address']);
                          },
                        )

                      ],
                    ),
                  ),
                  new Container(
                      width: 70.0,
                      child: new Column(
                        children: <Widget>[
                          new Text(
                            item['balance'],
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: new TextStyle(fontSize: 16.0,
                                color: Color.fromARGB(100, 6, 147, 193)),
                          ),
                          new Text('￥${item['rmb']??'-'}'),
                        ],
                      )

                  )
                ],
              )
          ),
  )
  );
}


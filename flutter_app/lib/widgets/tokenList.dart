import 'package:flutter/material.dart';
import 'package:youwallet/service/token_service.dart' ;
import 'package:provider/provider.dart';
import 'package:youwallet/model/token.dart';

// 类的名字需要大写字母开头
class tokenList extends StatelessWidget {

  List arr = [];
  tokenList({Key key, this.arr}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Column(
        children: arr.map((item) => walletCard(item, context)).toList()
    );
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
                    decoration: new BoxDecoration(
                      border: new Border.all(width: 2.0, color: Colors.black26),
                      borderRadius: new BorderRadius.all(new Radius.circular(20.0)),
                    ),
                    child: new Image.asset(
                      'images/icon.png',
                      height: 40.0,
                      width: 40.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                  new Expanded(
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        new Text(
                          item['name']?? '--',
                          style: new TextStyle(fontSize: 32.0, color: Colors.black),
                        ),
                        GestureDetector(
                          child: new Text(TokenService.maskAddress(item['address'])),
                          onTap: () async {
                            print(item['address']);
//                            balance = await TokenService.getBalance(item['address']);
//                            print(balance);
                          },
                        )

                      ],
                    ),
                  ),
                  new Container(
                      child: new Column(
                        children: <Widget>[
                          new Text(
                            item['balance'] + 'ETH',
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


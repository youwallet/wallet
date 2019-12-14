import 'package:flutter/material.dart';

// 类的名字需要大写字母开头
class WalletList extends StatelessWidget {

  List arr = [];
  WalletList({Key key, this.arr}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
        children: arr.map((item) => walletCard(item)).toList()
    );
  }
}

//item['address_filter'] = item['address'].substring(0,5) + '*****' + item['address'].substring(30);
//token['address_filter'] =

Widget walletCard(item) {
  return new Card(
      color: Colors.white, //背景色
      child:  GestureDetector(
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
                        item['name'],
                        style: new TextStyle(fontSize: 32.0, color: Colors.black),
                      ),
                      new Text(item['address']),
                    ],
                  ),
                ),
//                new Container(
//                    child: new Column(
//                      children: <Widget>[
//                        new Text(
//                          item['balance'],
//                          style: new TextStyle(fontSize: 16.0,
//                              color: Color.fromARGB(100, 6, 147, 193)),
//                        ),
//                        new Text('￥${item['rmb']}'),
//                      ],
//                    )
//
//                )
              ],
            )
        ),
        onTap: (){
          print("点击token =》 ${item}");
        },
      )
  );
}


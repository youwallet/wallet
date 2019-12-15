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

void setNetWork(name) async{
//  setState(() {
////    _newValue = name;
////  });
////  SharedPreferences prefs = await SharedPreferences.getInstance();
////  prefs.setString("network", name);
////  print(prefs.getString('network'));
}

//item['address_filter'] = item['address'].substring(0,5) + '*****' + item['address'].substring(30);
//token['address_filter'] =

Widget walletCard(item) {
  String current_address = item['address'];
  return new Card(
      color: Colors.white, //背景色
      child:  GestureDetector(
        child: new Container(
            padding: const EdgeInsets.all(28.0),
            child: new Row(
              children: <Widget>[
                new Container(
                  margin: const EdgeInsets.only(right: 16.0),
                  child: new Radio(
                    groupValue: current_address,
                    activeColor: Colors.blue,
                    value: item['address'],
                    onChanged: (v) {
                      // val 与 value 的类型对应
                      print(v);
//                      setState(() {
//                        current_address = v;  // aaa
//                      });
                    },
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


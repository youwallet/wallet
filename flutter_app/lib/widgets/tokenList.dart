import 'package:flutter/material.dart';
import 'dart:math';

class tokenList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
        children: getListWidgets()
    );
  }
}

//生成listview children Widgets
List<Widget> getListWidgets() {
  List<ItemData> list = List();
  Random random = Random();
  for (int i = 0; i < 10; i++) {
    int r = random.nextInt(255);
    int g = random.nextInt(255);
    int b = random.nextInt(255);
    list.add(ItemData(Color.fromARGB(255, r, g, b), i.toString()));
  }
  return list.map((item) => walletCard(item)).toList();
}

class ItemData {
  final Color color;
  final String text;

  ItemData(this.color, this.text);
}

Widget walletCard(item) {
  return new Card(
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
                      'TFT',
                      style: new TextStyle(fontSize: 32.0, color: Colors.black),
                    ),
                    new Text('0xxxxxxxxxxxxxxxxxxxxx'),
                  ],
                ),
              ),
              new Container(
                  child: new Column(
                    children: <Widget>[
                      new Text(
                        '14000.00',
                        style: new TextStyle(fontSize: 16.0,
                            color: Color.fromARGB(100, 6, 147, 193)),
                      ),
                      new Text('14000.00'),
                    ],
                  )

              )
            ],
          )
      )
  );
}
import 'package:flutter/material.dart';

class Menu extends StatelessWidget {
  List Menus ;
  final double size;
  final double fontSize;
  final color = Color.fromARGB(255, 255, 170, 71);

  Menu(this.Menus, {Key key, this.size = 18.0, this.fontSize = 13.0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> MenuList = [];
    print(Menus);
    for(var i = 0; i < Menus.length; i++) {
      MenuList.add(new Container(
        padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
        decoration: new BoxDecoration(
          // 设置容器边框粗细和颜色
          border: Border(bottom: BorderSide(color: Colors.black26, width: 0.5)),
        ),

        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            new Text(Menus[i]),
            new Icon(
              Icons.arrow_forward_ios,
              size: 20.0,
            ),
          ],
        ),
      ));
    }
    return Container(
      padding: const EdgeInsets.only(left:10.0,right: 10.0),
      child: Column(
        children: MenuList,
      ),
    );
  }
}
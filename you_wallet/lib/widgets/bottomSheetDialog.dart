import 'package:flutter/material.dart';

class BottomSheetDialog extends StatelessWidget {

  List content = []; // modal中的内容
  Function onSuccessChooseEvent;

  // 构造函数
  BottomSheetDialog({
    Key key,
    @required this.content,
    @required this.onSuccessChooseEvent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: this.content.map((item) => this.buildItem(item, context)).toList()
      ),
    );
  }

  Widget buildItem(item, context) {
    return ListTile(
      title: Text(item['name'],textAlign: TextAlign.center),
      onTap: () {
        this.onSuccessChooseEvent(item);
        Navigator.of(context).pop();
      },
    );
  }

}
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
            decoration: new BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18)
              ),
              color: Colors.white
            ),
            padding: const EdgeInsets.only(top: 18.0), // 四周填充边距32像素,
            height: 57.0*this.content.length + 18,
            child: Column(
              children: this.content.map((item) => this.buildItem(item, context)).toList()
            ),
        );
  }

  Widget buildItem(item, context) {
    return Container(

      decoration: new BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey,width: 0.5))
      ),
      child: ListTile(
          title: Text(
              item['name'],
              textAlign: TextAlign.center,
              style: new TextStyle(fontWeight: FontWeight.w700),
          ),
          onTap: () {
            this.onSuccessChooseEvent(item);
            Navigator.of(context).pop();
          },
      )
    );
  }

}
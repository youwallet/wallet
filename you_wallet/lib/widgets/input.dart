import 'package:flutter/material.dart';

class Input extends StatelessWidget {
  // 输入框中的提示字符
  String hintText = "";
  String suffixText = "";
  Function onSuccessChooseEvent;
  final controllerEdit ;

  // 构造函数
  Input({
    Key key,
    this.hintText = "",
    this.suffixText = "",
    @required this.controllerEdit,
    @required this.onSuccessChooseEvent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new ConstrainedBox(
      constraints: BoxConstraints(
          maxWidth: 200,
          maxHeight: 40.0
      ),
      child: new TextField(
        controller: this.controllerEdit,
        keyboardType: TextInputType.number,//键盘类型，数字键盘
        decoration: InputDecoration(// 输入框内部右侧增加一个icon
            suffixText: this.suffixText,//位于尾部的填充文字
            suffixStyle: new TextStyle(
                fontSize: 14.0,
                color: Colors.black38
            ),
            hintText: this.hintText,
            filled: true, // 填充背景颜色
            fillColor: Colors.black12,
            contentPadding: new EdgeInsets.only(left: 6.0), // 内部边距，默认不是0
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6.0),
              borderSide: BorderSide.none
            ),
        ),
        onChanged: (text) {
          //内容输入完成的回调
          this.onSuccessChooseEvent(text);
        },
      ),

    );
  }
}
import 'package:flutter/material.dart';



class CustomButton extends StatelessWidget {

  String content = ""; // 按钮上的文本
  String type = ""; // 按钮类型
  Map customData ; // 用户传过来的自定义数据，点击按钮后需要回传
  Function onSuccessChooseEvent;
  Map buttonMap = {
    'default': Color(0xff409eff),
    'danger': Color(0xfff56c6c)
  };

  // 构造函数
  CustomButton({
    Key key,
    this.type = "default",
    this.content = "确定",
    this.customData = null,
    @required this.onSuccessChooseEvent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        FlatButton(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          shape: StadiumBorder(),
          child: Text(
              this.content,
              style: new TextStyle(
                  fontSize: 18.0
              )),
          padding: EdgeInsets.fromLTRB(60,8,60,8),
          //elevation: 0, // 按钮阴影高度
          color: this.buttonMap[this.type],
          textColor: Colors.white,
          onPressed: () {
            this.onSuccessChooseEvent(this.customData);
          },
        )
      ],
    );


  }

}
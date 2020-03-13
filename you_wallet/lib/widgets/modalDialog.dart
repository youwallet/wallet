import 'package:flutter/material.dart';

class GenderChooseDialog extends Dialog {

  var title; //modal的标题
  String content = ""; // modal中的内容
  Function onCancelChooseEvent;
  Function onSuccessChooseEvent;

  // 构造函数
  GenderChooseDialog({
    Key key,
    this.title = "提示",
    this.content,
    this.onCancelChooseEvent,
    @required this.onSuccessChooseEvent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Padding(
        padding: const EdgeInsets.all(24.0),
        child: new Material(
            type: MaterialType.transparency,
            child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Container(
                      padding: const EdgeInsets.fromLTRB(
                          10.0, 40.0, 10.0, 10.0),
                      decoration: ShapeDecoration(
                          color: Color(0xFFFFFFFF),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ))),
                      margin: const EdgeInsets.all(12.0),
                      child: new Column(children: <Widget>[
                        // 标题区域
                        new Padding(
                            padding: const EdgeInsets.fromLTRB(
                                10.0, 0.0, 10.0, 28.0),
                            child: Center(
                                child: new Text(title,
                                    style: new TextStyle(
                                      fontSize: 20.0,
                                    )))),
                        // 内容区域
                        new Container(
                          padding: new EdgeInsets.all(10.0),
                          child: new Text(content),
                        ),
                        // 选择按钮区域
                        new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              _buttonChooseItemWid(1),
                              _buttonChooseItemWid(2)
                            ])
                      ]))
                ])));
  }

  Widget _buttonChooseItemWid(var gender) {
    return GestureDetector(
        onTap: gender == 1 ? this.onCancelChooseEvent : this.onSuccessChooseEvent,
        child: Container(
            decoration: new BoxDecoration(
              borderRadius: new BorderRadius.all(new Radius.circular(40.0)),
              color: gender == 1 ? Colors.black12: Colors.lightBlue,
            ),
            alignment: Alignment.center,
            width: 100,
            height: 40,
            child: Text(gender == 1 ? '取消' : '确定',
                  style: TextStyle(
                      color: gender == 1 ? Colors.grey : Colors.white,
                      fontSize: 15.0)),
          )
        );
  }

}
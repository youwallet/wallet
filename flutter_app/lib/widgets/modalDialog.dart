import 'package:flutter/material.dart';

class GenderChooseDialog extends Dialog {

  var title; //modal的标题
  var content; // modal中的内容
  Function onBoyChooseEvent;
  Function onGirlChooseEvent;

  // 构造函数
  GenderChooseDialog({
    Key key,
    @required this.title,
    @required this.content,
    @required this.onBoyChooseEvent,
    @required this.onGirlChooseEvent,
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
                              _genderChooseItemWid(1),
                              _genderChooseItemWid(2)
                            ])
                      ]))
                ])));
  }

  Widget _genderChooseItemWid(var gender) {
    return GestureDetector(
        onTap: gender == 1 ? this.onBoyChooseEvent : this.onGirlChooseEvent,
        child: Container(
          alignment: Alignment.center,
          width: 100,
            height: 40,
            color: gender == 1 ? Colors.black12: Colors.lightBlue,
            child: Text(gender == 1 ? '取消' : '确定',
                  style: TextStyle(
                      color: Color(gender == 1 ? 0xff4285f4 : 0xffff4444),
                      fontSize: 15.0)),
          )
        );
  }

}
import 'package:flutter/material.dart';

class InputDialog extends Dialog {

  var title; //modal的标题
  String hintText = ""; // modal中的内容
  var controller;
  Function onCancelChooseEvent;
  Function onSuccessChooseEvent;
//  TextEditingController _input = TextEditingController();

  // 构造函数
  InputDialog({
    Key key,
    this.title = "提示",
    this.hintText = "",
    @required this.controller,
    @required this.onCancelChooseEvent,
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
                          0.0, 40.0, 0.0, 0.0),
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
                                10.0, 0.0, 10.0, 10.0),
                            child: Center(
                                child: new Text(title,
                                    style: new TextStyle(
                                      fontSize: 20.0,
                                    )))),
                        // 内容区域
                        new Container(
                          decoration: new BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: Colors.black26,
                                      width: 1.0
                                  ) // 只设置顶部边框
                              )
                          ),
                          padding: new EdgeInsets.all(10.0),
                          child: new TextField(
                            controller: this.controller,
//                            controller: this._input,
                            decoration: InputDecoration(
                              hintText: this.hintText,

                              border: OutlineInputBorder(
                                // borderSide: BorderSide(color: Colors.grey),
                                  borderSide: BorderSide.none
                              ),
//                              focusedBorder: OutlineInputBorder(
//                                borderSide: BorderSide(color: Colors.grey),
//                              ),
                            ),
                          ),
                        ),
                        // 选择按钮区域
                        new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              _buttonChooseItemWid(context,1),
                              Text('|',style: TextStyle(
                                  color: Colors.black26,
                                  fontSize: 30.0)),
                              _buttonChooseItemWid(context,2)
                            ])
                      ])
                  )
                ]
            )
        )
    );
  }

  Widget _buttonChooseItemWid(BuildContext context, var gender) {
    return GestureDetector(
        onTap: gender == 1 ? this.onCancelChooseEvent : this.onSuccessChooseEvent,
        child: Container(
          alignment: Alignment.center,
          // width: MediaQuery.of(context).size.width*0.5,
          height: 60,
//          color: gender == 1 ? Colors.black12: Colors.lightBlue,
          child: Text(gender == 1 ? '取消' : '确定',
              style: TextStyle(
                  color: gender == 1 ? Colors.black54 : Colors.lightBlue,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w700
              )
          ),
        )
    );
  }

}
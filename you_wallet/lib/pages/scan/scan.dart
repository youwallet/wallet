
import 'package:flutter/material.dart';
import 'package:youwallet/widgets/customButton.dart';
import 'package:flutter/services.dart';

class Scan extends StatefulWidget {

  final arguments;
  Scan({Key key,this.arguments}) : super(key: key);

  @override
  Page createState()  => Page();
}

class Page extends State<Scan> {

  final globalKey = GlobalKey<ScaffoldState>();
  void showSnackbar(String text) {
    final snackBar = SnackBar(content: Text(text));
    globalKey.currentState.showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: globalKey,
        appBar: AppBar(
          elevation: 3,
          title: Text("操作结果"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new Container(
                color: Colors.black12,
                padding: const EdgeInsets.all(12.0),
                margin: const EdgeInsets.only(bottom: 20.0),
                width: MediaQuery.of(context).size.width * 0.8,
                height: 150.0,
                child: new Text(
                    widget.arguments['res']??'',
                    style: new TextStyle(
                        fontSize: 24.0,
                        color: Colors.lightBlue
                    )
                ),
              ),
              showButton()
//              new CustomButton(
//                content: '添加token',
//                onSuccessChooseEvent:(res){
//                  Navigator.pushNamed(context, "set_wallet_name");
//                }
//              ),
//              new CustomButton(
//                  content: '转账',
//                  onSuccessChooseEvent:(res){
//                    Navigator.pushNamed(context, "load_wallet");
//                  }
//              )
            ],
          ),
        )
    );
  }

  // 通过arguments中的参数来判是否显示复制按钮
  Widget showButton() {
    if (widget.arguments['allowCopy']) {
      return CustomButton(
          content: '复制',
          onSuccessChooseEvent: (res) {
            ClipboardData data = new ClipboardData(
                text: widget.arguments['res'] ?? '');
            Clipboard.setData(data);
            this.showSnackbar('复制成功');
          }
      );
    }else {
      return CustomButton(
          content: '确定',
          onSuccessChooseEvent: (res) {
            Navigator.of(context).pop();
          }
      );
    }
  }
}

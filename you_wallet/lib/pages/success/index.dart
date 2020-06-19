
import 'package:flutter/material.dart';
import 'package:youwallet/widgets/customButton.dart';

class Success extends StatefulWidget {
  final arguments;
  Success({Key key,this.arguments}) : super(key: key);

  @override
  _SuccessState createState()  => _SuccessState();
}

class _SuccessState extends State<Success> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
//        appBar: AppBar(
//          title: Text(""),
//        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new Container(
                margin: const EdgeInsets.only(top: 50.0, bottom: 60.0),
                child: Icon(IconData(0xe617, fontFamily: 'iconfont'),size: 150.0, color: Colors.lightBlue),
              ),
              new CustomButton(
                  content: widget.arguments['msg'],
                  onSuccessChooseEvent:(res){
                    Navigator.pop(context);
                    // Navigator.popAndPushNamed(context, '/');
                    //Navigator.of(context).pushNamedAndRemoveUntil('/', ModalRoute.withName('wallet_success'));
//                    Navigator.popUntil(context, ModalRoute.withName('/'));
                  }
              )
            ],
          ),
        )
    );
  }
}

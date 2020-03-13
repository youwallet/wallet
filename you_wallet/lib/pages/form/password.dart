
import 'package:flutter/material.dart';
import 'package:groovin_material_icons/groovin_material_icons.dart';
import 'package:youwallet/widgets/customButton.dart';

class PasswordPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<PasswordPage> {
  final _formKey = GlobalKey<FormState>();
  String _email, _password;
  bool _isObscure = true;
  Color _eyeColor;
  List _loginMethod = [
    {
      "title": "facebook",
      "icon": GroovinMaterialIcons.facebook,
    },
    {
      "title": "google",
      "icon": GroovinMaterialIcons.google,
    },
    {
      "title": "twitter",
      "icon": GroovinMaterialIcons.twitter,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: new Builder(builder: (BuildContext context) {
            return Form(
                key: _formKey,
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 22.0),
                  children: <Widget>[
                    SizedBox(height: kToolbarHeight,),
                    buildTitle(),
                    buildTitleLine(),
                    SizedBox(height: 70.0),
                    buildEmailTextField(),
                    SizedBox(height: 30.0),
                    buildPasswordTextField(context),
                    SizedBox(height: 60.0),
//                    buildLoginButton(context),
                    buildButton(context)
                  ],

                )
            );
          })
    );
  }

  // 获取用户两次输入的密码，两次密码必须相同
  Align buildLoginButton(BuildContext context) {
    return Align(
      child: SizedBox(
        height: 45.0,
        width: 270.0,
        child: new MaterialButton(
          color: Colors.blue,
          textColor: Colors.white,
          minWidth: 300, // 控制按钮宽度
          child: new Text('确定'),
          onPressed: () {
            _formKey.currentState.save();
            if (_email == _password && !_email.isEmpty) {
              Navigator.of(context).pop(_email);
            } else {
              if (_email.isEmpty || _password.isEmpty) {
                final snackBar = new SnackBar(content: new Text('不能为空'));
                Scaffold.of(context).showSnackBar(snackBar);
              } else {
                final snackBar = new SnackBar(content: new Text('两次输入密码不同'));
                Scaffold.of(context).showSnackBar(snackBar);
              }
            }
          },
        ),
      ),
    );
  }

  Widget buildButton(BuildContext context) {
    return new CustomButton(
        onSuccessChooseEvent:(res){
          _formKey.currentState.save();
          if (_email == _password && !_email.isEmpty) {
            Navigator.of(context).pop(_email);
          } else {
            if (_email.isEmpty || _password.isEmpty) {
              final snackBar = new SnackBar(content: new Text('不能为空'));
              Scaffold.of(context).showSnackBar(snackBar);
            } else {
              final snackBar = new SnackBar(content: new Text('两次输入密码不同'));
              Scaffold.of(context).showSnackBar(snackBar);
            }
          }
        }
    );
  }


  TextFormField buildPasswordTextField(BuildContext context) {
    return TextFormField(
      onSaved: (String value) => _password = value,
      decoration: InputDecoration(
        hintText: '请再次输入密码',
        filled: true,
        fillColor: Colors.black12,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.0),
            borderSide: BorderSide.none
        ),
      ),
    );
  }

  TextFormField buildEmailTextField() {
    return TextFormField(
      decoration: InputDecoration(
        hintText: '请输入密码',
        filled: true,
        fillColor: Colors.black12,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.0),
            borderSide: BorderSide.none
        ),
      ),
      onSaved: (String value) => _email = value,
    );
  }

  Padding buildTitleLine() {
    return Padding(
      padding: EdgeInsets.only(left: 12.0, top: 4.0),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Container(
          color: Colors.white,
          width: 40.0,
          height: 2.0,
        ),
      ),
    );
  }

  Padding buildTitle() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(
        '',
        style: TextStyle(fontSize: 42.0),
      ),
    );
  }
}

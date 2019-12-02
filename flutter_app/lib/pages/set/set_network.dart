import 'package:http/http.dart';
import 'package:flutter/material.dart'; // 官方组件库
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';



class NetworkPage extends StatefulWidget {
  NetworkPage() : super();
  @override
  _NetworkPageState createState()  => _NetworkPageState();
}

class _NetworkPageState extends State<NetworkPage> {

  String _newValue = 'Mainnet';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text("网络配置"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RadioListTile<String>(
                value: 'Mainnet',
                title: Text('Mainnet'),
                groupValue: _newValue,
                onChanged: (value) {
                  setNetWork(value);
                },
              ),
              RadioListTile<String>(
                value: 'Ropsten',
                title: Text('Ropsten'),
                groupValue: _newValue,
                onChanged: (value) {
                  setNetWork(value);
                },
              ),
            ],
          ),
        )
    );
  }

  void setNetWork(name) async{
    setState(() {
      _newValue = name;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("network", name);
    print(prefs.getString('network'));
  }

  getNetWork() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('network');
  }
}

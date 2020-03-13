import 'package:http/http.dart';
import 'package:flutter/material.dart'; // 官方组件库
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:youwallet/model/network.dart';



class NetworkPage extends StatefulWidget {
  NetworkPage() : super();
  @override
  _NetworkPageState createState()  => _NetworkPageState();
}

class _NetworkPageState extends State<NetworkPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("网络配置"),
        ),
        body: Center(
          child:  Consumer<Network>(
            builder: (context, network, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RadioListTile<String>(
                    value: 'mainnet',
                    title: Text('Mainnet'),
                    groupValue: network.network,
                    onChanged: (value) {
                      setNetWork(value);
                    },
                  ),
                  RadioListTile<String>(
                    value: 'ropsten',
                    title: Text('Ropsten'),
                    groupValue: network.network,
                    onChanged: (value) {
                      setNetWork(value);
                    },
                  ),
                ],
              );
            },
          ),
        )
    );
  }

  void setNetWork(name) async{
    Provider.of<Network>(context).changeNetwork(name);
  }

}

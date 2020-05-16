import 'package:flutter/material.dart';
import 'package:youwallet/global.dart';

class AddressFormat extends StatelessWidget {
  final address;
  AddressFormat(this.address, {Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      Global.maskAddress(this.address) ,
      style: TextStyle(
        fontSize: 22,
        letterSpacing: 0,
        color: Colors.white,
        fontWeight: FontWeight.w800
      ),
    );
  }
}
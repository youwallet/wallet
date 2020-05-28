import 'package:flutter/material.dart';
import 'package:youwallet/model/viewModel.dart';
import 'package:youwallet/widgets/tokenLogo.dart';
import 'package:youwallet/global.dart';
import 'package:youwallet/widgets/addressFormat.dart';

class TokenCard extends StatelessWidget {

  final TokenCardViewModel data;
  const TokenCard({Key key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      margin: EdgeInsets.fromLTRB(0, 16.0, 0, 0),
      padding: EdgeInsets.only(left: 20, top: 20),
      decoration: BoxDecoration(
        color: Colors.lightBlue,
        borderRadius: BorderRadius.circular(8),
//        gradient: LinearGradient(
//          begin: Alignment.topLeft,
//          end: Alignment.bottomRight,
//          colors: this.data.cardColors,
//        ),
//
        boxShadow: [
          BoxShadow(
            blurRadius: 6,
            spreadRadius: 4,
            color: Color.fromARGB(20, 0, 0, 0),
          ),
        ],
      ),
      child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TokenLogo(address: this.data.cardNumber),
                    Padding(padding: EdgeInsets.only(left: 15)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Row(
                          children: <Widget>[
                            Text(
                              this.data.bankName,
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Padding(padding: EdgeInsets.only(left: 15)),
                            GestureDetector(
                              child: Icon(
                                  IconData(0xe600, fontFamily: 'iconfont'),
                                  color: Colors.white,
                              ),
                              onTap: () {
                                Map token = {
                                  'name': this.data.bankName,
                                  'address': this.data.cardNumber,
                                };
                                Navigator.pushNamed(context, "token_info", arguments: token);
                              },
                            ),
                          ],
                        ),
                        Text(
                          this.data.balance,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color.fromARGB(200, 255, 255, 255),
                          ),
                        ),
                      ],
                    ),
                    Padding(padding: EdgeInsets.only(left: 10)),

                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(left: 65, top: 20),
                  child: new AddressFormat(this.data.cardNumber)
                ),
              ],
            ),
    );
  }
}

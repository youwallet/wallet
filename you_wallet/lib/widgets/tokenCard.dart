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
      margin: EdgeInsets.fromLTRB(0, 16, 0, 0),
      padding: EdgeInsets.only(left: 20, top: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: this.data.cardColors,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            blurRadius: 6,
            spreadRadius: 4,
            color: Color.fromARGB(20, 0, 0, 0),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            right: -100,
            bottom: -100,
            child: TokenLogo(address: this.data.cardNumber),
          ),
          Positioned(
            left: 0,
            top: 0,
            right: 0,
            bottom: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.transparent,
                      child: TokenLogo(address: this.data.cardNumber),
                    ),
                    Padding(padding: EdgeInsets.only(left: 15)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          this.data.bankName,
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          this.data.cardType,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color.fromARGB(200, 255, 255, 255),
                          ),
                        ),
                      ],
                    ),
                    Padding(padding: EdgeInsets.only(left: 10)),
                    GestureDetector(
                        child: Icon(IconData(0xe600, fontFamily: 'iconfont')),
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
                Padding(
                  padding: EdgeInsets.only(left: 65, top: 20),
                  child: new AddressFormat(this.data.cardNumber)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

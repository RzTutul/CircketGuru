import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class AdmobNativeAdItem extends StatelessWidget {
  String adUnitID;

  AdmobNativeAdItem({this.adUnitID});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 10,
      padding: EdgeInsets.all(5),
      margin: EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(
              color: Colors.black54.withOpacity(0.2),
              offset: Offset(0,0),
              blurRadius: 5
          )]
      ),
      child: Text(""),
    );
  }


}

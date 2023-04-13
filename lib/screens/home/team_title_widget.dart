import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:app/config/colors.dart';

class TeamTitleWidget extends StatelessWidget {


  String  appname ="";
  String appsubname ="";
  String applogo="";


  TeamTitleWidget({this.appname, this.appsubname, this.applogo});

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.only(left: 10,right: 10,top: 50,bottom: 30),
      child: Stack(
        children: <Widget>[
          CachedNetworkImage(imageUrl: applogo,height: 60,width: 60),
          Positioned(
            left: 75,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  appname,
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyText1.color,
                      fontWeight: FontWeight.w900,
                      fontSize: 24
                  ),
                ),
                Text(
                    appsubname,
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyText2.color,
                        fontSize: 18
                    )
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

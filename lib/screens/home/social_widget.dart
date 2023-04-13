import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:app/config/colors.dart';
import 'package:app/model/social.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialWidget extends StatelessWidget {
  Social  social ;


  _launchURL(String url) async {

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  SocialWidget({this.social});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        _launchURL(social.value);
      },
      child: Container(
        height: 45,
        child: Padding(
          padding: const EdgeInsets.only(left:10),
          child: Row(
            children: <Widget>[
              Container(
                height: 45,
                width: 45,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image(
                      image: NetworkImage(social.icon),
                      color: Colors.white
                  ),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(10),bottomLeft: Radius.circular(10)),
                  color: Color(social.getColor()),
                    boxShadow: [BoxShadow(
                        color: Colors.black45,
                        offset: Offset(0,0),
                        blurRadius: 1
                    )]
                ),
              ),
              Container(
                padding: EdgeInsets.only(right: 10,top: 5,bottom: 5,left: 10),
                height: 45,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        social.social,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10
                        ),
                      ),
                      Text(
                        social.username,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 8
                        ),
                      ),
                    ],
                  ),
                ),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(topRight: Radius.circular(10),bottomRight: Radius.circular(10)),
                    color: Color(social.getColor()),
                    boxShadow: [BoxShadow(
                        color: Colors.black54.withOpacity(0.2),
                        offset: Offset(0,0),
                        blurRadius: 5
                    )]
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:http/http.dart';
import 'package:line_icons/line_icons.dart';
import 'package:app/api/api_config.dart';
import 'package:app/api/api_rest.dart';
import 'package:app/config/colors.dart';
import 'package:app/model/post.dart';
import 'package:app/model/post.dart';
import 'package:app/model/post.dart';
import 'package:app/model/post.dart';
import 'package:app/screens/articles/image_viewer.dart';
import 'package:app/screens/comments/comments_list.dart';
import 'package:app/screens/post/youtube_detail.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:need_resume/need_resume.dart';
import 'package:http/http.dart' as http;
import 'package:app/screens/loading.dart';
import 'dart:convert' as convert;

class PrivacyPolicy extends StatefulWidget {


  PrivacyPolicy();

  @override
  _PrivacyPolicyState createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
  String _data ="Loading ...";


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();

  }
  getData()async{
    String     d  = await http.read(Uri.parse(apiConfig.api_url.replaceAll("/api/", "/privacy_policy.html")).replace(queryParameters: null));
    setState(() {
      _data =d;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor:  Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor:  Theme.of(context).scaffoldBackgroundColor,
          centerTitle: false,
          title: Text("Terms and Conditions and Privacy policy"),
          elevation: 0,
          iconTheme: IconThemeData(color: Theme.of(context).textTheme.bodyText1.color),
          leading: new IconButton(
            icon: new Icon(LineIcons.angleLeft),
            onPressed: () => Navigator.of(context).pop(),
          )
        ),
        body:SingleChildScrollView(
            child:
            Column(
              children: [
            /*    Container(
                  margin: EdgeInsets.all(5),
                  child: Html(
                    data:_data,
                    style: {
                      "*": Style(
                        color: Theme.of(context).textTheme.bodyText1.color,
                      ),
                    },
                    onImageTap: (url,_,__,___) {
                      Route route = MaterialPageRoute(builder: (context) => ImageViewer(url:url));
                      Navigator.push(context, route);
                    },
                    onLinkTap:(url,_,__,___){
                      _launchURL(url);
                    } ,
                  ),
                ),*/

                Text(_data,style: TextStyle(  color: Theme.of(context).textTheme.bodyText1.color,),),
                SizedBox(height: 20),
              ],
            )
        )
    );

  }
  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }




}

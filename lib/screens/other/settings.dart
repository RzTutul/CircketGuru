

import 'package:firebase_messaging/firebase_messaging.dart';
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
import 'package:app/screens/other/privacy_policy.dart';
import 'package:app/screens/other/report.dart';
import 'package:app/screens/post/youtube_detail.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:need_resume/need_resume.dart';
import 'package:http/http.dart' as http;
import 'package:app/screens/loading.dart';
import 'dart:convert' as convert;

class Settings extends StatefulWidget {


  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool matchNotification = false;
  bool postNotification = false;
  bool statusNotification = false;
  bool AllNotification = false;
  String projectVersion = "..";

  FirebaseMessaging _messaging = FirebaseMessaging.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initSettings();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor:  Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor:  Theme.of(context).scaffoldBackgroundColor,
          centerTitle: false,
          title: Text("Settings"),
          elevation: 0,
          iconTheme: IconThemeData(color: Theme.of(context).textTheme.bodyText1.color),
          leading: new IconButton(
            icon: new Icon(LineIcons.angleLeft),
            onPressed: () =>  Navigator.of(context).pop(),
          ),
        ),

        body:SafeArea(
          child: SingleChildScrollView(
              child:Column(
                children: [
                  SizedBox(height: 50),
                  buildSettingItemNotification(),
                  buildSettingItem("Report bugs and help",LineIcons.questionCircle,(){
                    Route route = MaterialPageRoute(builder: (context) => Report(message:"",image:  Icon(Icons.mail,size: 100),title: "Report bugs and help",status: -1));
                    Navigator.push(context, route);
                  }),
                  buildSettingItem("Privacy policy",LineIcons.lock,(){
                    Route route = MaterialPageRoute(builder: (context) => PrivacyPolicy());
                    Navigator.push(context, route);
                  }),
                  buildInfoItem("App version",LineIcons.infoCircle,projectVersion),
                ],
              )

          ),
        )
    );

  }

  buildInfoItem(String title,IconData icon,String info) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 25,vertical: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Material(
          color:  Theme.of(context).cardColor, //
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.all(15),
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon,color: Theme.of(context).textTheme.subtitle1.color,size: 35),
              ),
              Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.subtitle1.color
                    ),
                  )
              ),
              Text(
                  "v"+projectVersion,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.subtitle1.color
                  ),
              ),
              SizedBox(width: 20)
            ],
          ),
        ),
      ),
    );
  }
  buildSettingItem(String title,IconData icon,Function action) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 25,vertical: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Material(
          color:  Theme.of(context).cardColor, //
          child: InkWell(
            splashColor: Theme.of(context).cardColor, //
            onTap:action,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.all(15),
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon,color: Theme.of(context).textTheme.subtitle1.color,size: 35),
                ),
                Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.subtitle1.color
                      ),
                    )
                ),
                Icon(
                  LineIcons.angleRight,
                  size: 18,
                  color: Theme.of(context).textTheme.subtitle2.color,
                ),
                SizedBox(width: 20)
              ],
            ),
          ),
        ),
      ),
    );
  }

  buildSettingItemNotification() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color:  Theme.of(context).cardColor, //
      ),
      margin: EdgeInsets.symmetric(horizontal: 25,vertical: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.all(15),
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(LineIcons.bell,color: Theme.of(context).textTheme.subtitle1.color,size: 35),
                ),
                Expanded(
                    child: Text(
                      "Notification Settings",
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.subtitle1.color
                      ),
                    )
                ),
                SizedBox(width: 20)

              ],
            ),
            Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Theme.of(context).textTheme.bodyText2.color,width: 0.2))
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    height: 30,
                    width: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.settings,color: Theme.of(context).textTheme.subtitle1.color,size: 25),
                  ),
                  Expanded(
                      child: Text(
                        "General notification",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.subtitle1.color
                        ),
                      )
                  ),
                  Switch(value: AllNotification, onChanged: (value){
                    setState(() {
                      AllNotification = value;
                      toggleSubscribeToApplication(value);
                    });
                  }),
                  SizedBox(width: 20)

                ],
              ),
            ),


            Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Theme.of(context).textTheme.bodyText2.color,width: 0.2))
              ),
              child:Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      height: 30,
                      width: 60,
                      child: Icon(LineIcons.newspaperAlt,color: Theme.of(context).textTheme.subtitle1.color,size: 25),

                    ),
                    Expanded(
                        child: Text(
                          "News Notifications",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.subtitle1.color
                          ),
                        )
                    ),
                    Switch(value: postNotification, onChanged: (value){
                      setState(() {
                        postNotification = value;
                        toggleSubscribeToNews(value);
                      });
                    }),
                    SizedBox(width: 20)
                  ]),
            ),
            Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Theme.of(context).textTheme.bodyText2.color,width: 0.2))
              ),
              child:Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      height: 30,
                      width: 60,
                      child: Icon(Icons.format_quote,color: Theme.of(context).textTheme.subtitle1.color,size: 25),

                    ),
                    Expanded(
                        child: Text(
                          "Status Notifications",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.subtitle1.color
                          ),
                        )
                    ),
                    Switch(value: statusNotification, onChanged: (value){
                      setState(() {
                        statusNotification = value;
                        toggleSubscribeToStatus(value);

                      });
                    }),
                    SizedBox(width: 20)
                  ]),
            ),
            Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Theme.of(context).textTheme.bodyText2.color,width: 0.2))
              ),
              child:Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      height: 30,
                      width: 60,
                      child: Icon(Icons.sports,color: Theme.of(context).textTheme.subtitle1.color,size: 25),

                    ),
                    Expanded(
                        child: Text(
                          "Matches Notifications",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.subtitle1.color
                          ),
                        )
                    ),
                    Switch(value: matchNotification, onChanged: (value){
                      setState(() {
                        matchNotification = value;
                        toggleSubscribeToMatches(value);
                      });
                    }),
                    SizedBox(width: 20)
                  ]),
            ),
          ],
        ),
      ),
    );
  }
  initSettings() async{


// Platform messages may fail, so we use a try/catch PlatformException.
    try {
      //projectVersion = await GetVersion.projectVersion;
      projectVersion = "1.0";
    } on PlatformException {
      projectVersion = 'Err';
    }
    setState(() {
      projectVersion=projectVersion;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.getBool("notification_news") == true){
        setState(() {
          postNotification = true;
        });
    }else{
      setState(() {
        postNotification = false;
      });
    }
    if(prefs.getBool("notification_status") == true){
      setState(() {
        statusNotification = true;
      });
    }else{
      setState(() {
        statusNotification = false;
      });
    }
    if(prefs.getBool("notification_matches") == true){
      setState(() {
        matchNotification = true;
      });
    }else{
      setState(() {
        matchNotification = false;
      });
    }
    if(prefs.getBool("notification_application") == true){
      setState(() {
        AllNotification = true;
      });
    }else{
      setState(() {
        AllNotification = false;
      });
    }
  }
  toggleSubscribeToNews(bool enbaled) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(enbaled){
      await _messaging.subscribeToTopic("news");
      prefs.setBool("notification_news", true);
    }else{
      await _messaging.unsubscribeFromTopic("news");
      prefs.setBool("notification_news", false);
    }
    setState(() {
      postNotification = enbaled;
    });
  }
  toggleSubscribeToMatches(bool enbaled) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(enbaled){
      await _messaging.subscribeToTopic("matches");
      prefs.setBool("notification_matches", true);
    }else{
      await _messaging.unsubscribeFromTopic("matches");
      prefs.setBool("notification_matches", false);
    }
    setState(() {
      matchNotification = enbaled;
    });
  }
  toggleSubscribeToStatus(bool enbaled) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(enbaled){
      await _messaging.subscribeToTopic("status");
      prefs.setBool("notification_status", true);
    }else{
      await _messaging.unsubscribeFromTopic("status");
      prefs.setBool("notification_status", false);
    }
    setState(() {
      statusNotification = enbaled;
    });
  }
  toggleSubscribeToApplication(bool enbaled) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(enbaled){
      await _messaging.subscribeToTopic("application");
      prefs.setBool("notification_application", true);
    }else{
      await _messaging.unsubscribeFromTopic("application");
      prefs.setBool("notification_application", false);
    }
    setState(() {
      AllNotification = enbaled;
    });
  }
}

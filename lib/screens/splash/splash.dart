

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:app/api/api_rest.dart';

import 'package:app/config/config.dart';
import 'package:app/model/match.dart';
import 'package:app/model/post.dart';
import 'package:app/model/status.dart';
import 'package:app/provider/notification_manager.dart';
import 'package:app/screens/home/home.dart';
import 'package:app/screens/matches/match_detail.dart';
import 'package:app/screens/post/post_detail.dart';
import 'package:http/http.dart' as http;
import 'package:app/screens/post/video_detail.dart';
import 'dart:convert' as convert;

import 'package:app/screens/post/youtube_detail.dart';
import 'package:app/screens/other/settings.dart';
import 'package:app/screens/status/image_detail.dart';
import 'package:app/screens/status/quote_detail.dart';
import 'package:app/screens/status/status_detail.dart';
import 'package:app/screens/test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';



class Splash extends StatefulWidget {

  String post;
  String status;
  String match;
  String appname ="";
  String appsubname ="";
  String applogo="";
  String appsponsors="";

  String localappname ;
  String localappsubname ;
  String localapplogo ;
  String localappsponsors;

  String type;
  String data ;
  String info ;



  Splash({this.post, this.status,this.appname,this.appsubname, this.type,this.data,this.applogo,this.appsponsors,this.info});

  @override
  _SplashState createState() => _SplashState();

}

class _SplashState extends State<Splash> {
  List<Post> favoritePostsList = [];


  @override
  void initState() {
    getAppConfig();

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
           Positioned(
                top: 0,
                bottom: 0,
                right: 0,
                left: 0,
                child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      CachedNetworkImage(
                          width: 90,
                          imageUrl: (widget.localapplogo == null ||  widget.localapplogo == "" )?widget.applogo:widget.localapplogo,
                          fit: BoxFit.fitWidth,
                        ),
                        SizedBox(height: 15),
                        Text(
                         (widget.localappname == null || widget.localappname == "" )?widget.appname:widget.localappname,
                          //widget.info,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Theme
                                .of(context)
                                .primaryTextTheme
                                .bodyText1
                                .color,
                          ),
                        ),
                        Text(
                          (widget.localappsubname == null )?widget.appsubname:widget.localappsubname,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Theme
                                  .of(context)
                                  .accentColor
                          ),
                        )
                      ],
                    )
                )
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  CachedNetworkImage(
                    width: double.infinity,
                    imageUrl: (widget.localappsponsors == null || widget.localappsponsors == "" )?widget.appsponsors:widget.localappsponsors,
                    fit: BoxFit.fitWidth,
                    errorWidget: (context, url, error) => Text(""),

                  ),
                  SizedBox(height: 20),
                  SpinKitFoldingCube(
                    size: 35,
                    duration: Duration(seconds: 2),
                    itemBuilder: (BuildContext context, int index) {
                      return DecoratedBox(
                        decoration: BoxDecoration(
                          color: index.isEven ? Theme
                              .of(context)
                              .accentColor : Theme
                              .of(context)
                              .accentColor,
                        ),
                      );
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<Match>  _getMatch() async{

    var response;
    var jsonData;
    var statusCode;
    try {
      response = await http.get(apiRest.getMatchById(widget.match));
      jsonData =  convert.jsonDecode(response.body);
      statusCode = response.statusCode;
    } catch (ex) {
      statusCode == 500;
    }


    if (statusCode == 200) {
      Match _match =  Match.fromJson(jsonData);

      Route route = MaterialPageRoute(builder: (context) => MatchDetail(match:_match,back : false));
      Navigator.pushReplacement(context, route);

    } else {
      Route route = MaterialPageRoute(builder: (context) => Home());
      Navigator.pushReplacement(context, route);
    }
  }
  Future<Post>  _getPost() async{

    var response;
    var jsonData;
    var statusCode;
    try {
      response = await http.get(apiRest.getPostById(widget.post));
      jsonData =  convert.jsonDecode(response.body);
      statusCode = response.statusCode;
    } catch (ex) {
      statusCode == 500;
    }


    if (statusCode == 200) {
      Post _post =  Post.fromJson(jsonData);


      SharedPreferences prefs = await SharedPreferences.getInstance();
      String  favoritePostsString=  await prefs.getString('post_favorires');

      if(favoritePostsString != null){
        favoritePostsList = Post.decode(favoritePostsString);
      }
      if(favoritePostsList == null){
        favoritePostsList= [];
      }
      for(Post  favorite_post in favoritePostsList){
        if(favorite_post.id == _post.id){
          _post.favorite = true;
        }
      }
      switch(_post.type){
        case "youtube":
          Route route = MaterialPageRoute(builder: (context) => YoutubeDetail(post:_post,back : false));
          Navigator.pushReplacement(context, route);
          break;
        case "video":
          Route route = MaterialPageRoute(builder: (context) => VideoDetail(post:_post,back : false));
          Navigator.pushReplacement(context, route);
          break;
        default:
          Route route = MaterialPageRoute(builder: (context) => PostDetail(post:_post,back : false));
          Navigator.pushReplacement(context, route);
          break;
      }
    } else {
      Route route = MaterialPageRoute(builder: (context) => Home());
      Navigator.pushReplacement(context, route);
    }
  }
  Future<Status>  _getStatus() async{

    var response;
    var jsonData;
    var statusCode;
    try {
      response = await http.get(apiRest.getStatusById(widget.status));
      jsonData =  convert.jsonDecode(response.body);
      statusCode = response.statusCode;
    } catch (ex) {
      statusCode == 500;
    }



    if (statusCode == 200) {
    Status _status =  Status.fromJson(jsonData);

      switch(_status.kind){
        case "image":
          Route route = MaterialPageRoute(builder: (context) => ImageDetail(status: _status ,back : false));
          Navigator.pushReplacement(context, route);
          break;
        case "quote":
          Route route = MaterialPageRoute(builder: (context) => QuoteDetail(status: _status ,back : false));
          Navigator.pushReplacement(context, route);
          break;
        default:
          Route route = MaterialPageRoute(builder: (context) => StatusDetail(status: _status,back : false));
          Navigator.pushReplacement(context, route);
          break;
      }
    } else {
      Route route = MaterialPageRoute(builder: (context) => Home());
      Navigator.pushReplacement(context, route);
    }
  }

  void redirectTo(){
    Future.delayed(const Duration(milliseconds: 4000), () {
      if(widget.data != null){
        if(widget.type == "link"){
          _launchURL(widget.data);
          Route route = MaterialPageRoute(builder: (context) => Home());
          Navigator.pushReplacement(context, route);
        }else if(widget.type == "status") {
          widget.status = widget.data;
          _getStatus();
        }else if(widget.type == "post") {
          widget.post = widget.data;
          _getPost();
        }else if(widget.type == "match") {
          widget.match = widget.data;
          _getMatch();
        }
      }else{
        if(widget.status != null) {
          _getStatus();
        }else if(widget.post != null) {
          _getPost();
        }else{
          Route route = MaterialPageRoute(builder: (context) => Home());
          Navigator.pushReplacement(context, route);
        }
      }
    });
  }
  Future<void>  getAppConfig() async{

    var response;
    var jsonData;
    var statusCode;
    try {
      response = await http.get(apiRest.getAppConfig());
      jsonData =  convert.jsonDecode(response.body);
      statusCode = response.statusCode;
    } catch (ex) {
      statusCode == 500;
    }



    if (statusCode == 200) {
      var _app_name = widget.appname;
      var _app_sub_name = widget.appsubname;
      var _app_logo = widget.applogo;
      var _app_sponsors = widget.appsponsors;
      var _app_star = "null";



      var response_android_ads_interstitial_facebook_id = "null";
      var response_android_ads_interstitial_admob_id = "null";
      var response_android_ads_interstitial_type = "null";
      var response_android_ads_interstitial_click =0;
      var response_android_ads_banner_facebook_id = "null";
      var response_android_ads_banner_admob_id = "null";
      var response_android_ads_banner_type = "null";
      var response_android_ads_native_admob_id = "null";
      var response_android_ads_native_facebook_id = "null";
      var response_android_ads_native_item =0;
      var response_android_ads_native_type = "null";
      var response_android_publisher_id = "null";
      var response_android_admob_app_id = "null";

      var response_ios_ads_interstitial_facebook_id = "null";
      var response_ios_ads_interstitial_admob_id = "null";
      var response_ios_ads_interstitial_type = "null";
      var response_ios_ads_interstitial_click =0;
      var response_ios_ads_banner_facebook_id = "null";
      var response_ios_ads_banner_admob_id = "null";
      var response_ios_ads_banner_type = "null";
      var response_ios_ads_native_admob_id = "null";
      var response_ios_ads_native_facebook_id = "null";
      var response_ios_ads_native_item =0;
      var response_ios_ads_native_type = "null";
      var response_ios_publisher_id = "null";
      var response_ios_admob_app_id = "null";





      for(Map i in jsonData["values"]) {
        if (i["name"] == "APP_NAME") {
              _app_name = i["value"];
        }
        if (i["name"] == "APP_SUB_NAME") {
            _app_sub_name = i["value"];
        }
        if (i["name"] == "APP_LOGO") {
            _app_logo = i["value"];
        }
        if (i["name"] == "APP_SPONSORS") {
          _app_sponsors = i["value"];
        }
        if (i["name"] == "APP_STAR") {
          _app_star = i["value"];
        }


        if (i["name"] == "ADMIN_ANDROID_INTERSTITIAL_FACEBOOK_ID") {
          response_android_ads_interstitial_facebook_id = i["value"];
        }
        if (i["name"] == "ADMIN_ANDROID_INTERSTITIAL_ADMOB_ID") {
          response_android_ads_interstitial_admob_id = i["value"];
        }


        if (i["name"] == "ADMIN_ANDROID_INTERSTITIAL_TYPE") {
          response_android_ads_interstitial_type = i["value"];
        }
        if (i["name"] == "ADMIN_ANDROID_INTERSTITIAL_CLICKS") {
          response_android_ads_interstitial_click = i["value"];
        }
        if (i["name"] == "ADMIN_ANDROID_BANNER_ADMOB_ID") {
          response_android_ads_banner_admob_id = i["value"];
        }
        if (i["name"] == "ADMIN_ANDROID_BANNER_FACEBOOK_ID") {
          response_android_ads_banner_facebook_id = i["value"];
        }
        if (i["name"] == "ADMIN_ANDROID_BANNER_TYPE") {
          response_android_ads_banner_type = i["value"];
        }
        if (i["name"] == "ADMIN_ANDROID_NATIVE_ADMOB_ID") {
          response_android_ads_native_admob_id = i["value"];
        }
        if (i["name"] == "ADMIN_ANDROID_NATIVE_FACEBOOK_ID") {
          response_android_ads_native_facebook_id = i["value"];
        }
        if (i["name"] == "ADMIN_ANDROID_NATIVE_ITEM") {
          response_android_ads_native_item = i["value"];
        }
        if (i["name"] == "ADMIN_ANDROID_NATIVE_TYPE") {
          response_android_ads_native_type = i["value"];
        }
        if (i["name"] == "ADMIN_ANDROID_PUBLISHER_ID") {
          response_android_publisher_id = i["value"];
        }
        if (i["name"] == "ADMIN_ANDROID_APP_ID") {
          response_android_admob_app_id = i["value"];
        }

        if (i["name"] == "ADMIN_IOS_INTERSTITIAL_FACEBOOK_ID") {
          response_ios_ads_interstitial_facebook_id = i["value"];
        }
        if (i["name"] == "ADMIN_IOS_INTERSTITIAL_ADMOB_ID") {
          response_ios_ads_interstitial_admob_id = i["value"];
        }
        if (i["name"] == "ADMIN_IOS_INTERSTITIAL_TYPE") {
          response_ios_ads_interstitial_type = i["value"];
        }
        if (i["name"] == "ADMIN_IOS_INTERSTITIAL_CLICKS") {
          response_ios_ads_interstitial_click = i["value"];
        }
        if (i["name"] == "ADMIN_IOS_BANNER_ADMOB_ID") {
          response_ios_ads_banner_admob_id = i["value"];
        }
        if (i["name"] == "ADMIN_IOS_BANNER_FACEBOOK_ID") {
          response_ios_ads_banner_facebook_id = i["value"];
        }
        if (i["name"] == "ADMIN_IOS_BANNER_TYPE") {
          response_ios_ads_banner_type = i["value"];
        }
        if (i["name"] == "ADMIN_IOS_NATIVE_FACEBOOK_ID") {
          response_ios_ads_native_facebook_id = i["value"];
        }
        if (i["name"] == "ADMIN_IOS_NATIVE_ADMOB_ID") {
          response_ios_ads_native_admob_id = i["value"];
        }
        if (i["name"] == "ADMIN_IOS_NATIVE_ITEM") {
          response_ios_ads_native_item = i["value"];
        }
        if (i["name"] == "ADMIN_IOS_NATIVE_TYPE") {
          response_ios_ads_native_type = i["value"];
        }
        if (i["name"] == "ADMIN_IOS_PUBLISHER_ID") {
          response_ios_publisher_id = i["value"];
        }
        if (i["name"] == "ADMIN_IOS_APP_ID") {
          response_ios_admob_app_id = i["value"];
        }

      }


      setState(() {
        if(widget.appname != _app_name)
          widget.localappname= _app_name;

        if(widget.appsubname != _app_sub_name)
          widget.localappsubname= _app_sub_name;

        if(widget.applogo != _app_logo)
          widget.localapplogo= _app_logo;

        if(widget.appsponsors != _app_sponsors)
          widget.localappsponsors= _app_sponsors;

      });



      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("app_name", _app_name);
      prefs.setString("app_sub_name", _app_sub_name);
      prefs.setString("app_logo", _app_logo);
      prefs.setString("app_sponsors", _app_sponsors);


      // save android ads ids in app

      prefs.setString("android_ads_interstitial_facebook_id", response_android_ads_interstitial_facebook_id);
      prefs.setString("android_ads_interstitial_admob_id", response_android_ads_interstitial_admob_id);
      prefs.setString("android_ads_interstitial_type", response_android_ads_interstitial_type);
      prefs.setInt("android_ads_interstitial_click", response_android_ads_interstitial_click);
      prefs.setString("android_ads_banner_facebook_id", response_android_ads_banner_facebook_id);
      prefs.setString("android_ads_banner_admob_id", response_android_ads_banner_admob_id);
      prefs.setString("android_ads_banner_type", response_android_ads_banner_type);
      prefs.setString("android_ads_native_admob_id", response_android_ads_native_admob_id);
      prefs.setString("android_ads_native_facebook_id", response_android_ads_native_facebook_id);
      prefs.setInt("android_ads_native_item", response_android_ads_native_item);
      prefs.setString("android_ads_native_type", response_android_ads_native_type);
      prefs.setString("android_admob_publisher_id", response_android_publisher_id);
      prefs.setString("android_admob_app_id", response_android_admob_app_id);

      // save ios ads ids in app

      prefs.setString("ios_ads_interstitial_facebook_id", response_ios_ads_interstitial_facebook_id);
      prefs.setString("ios_ads_interstitial_admob_id", response_ios_ads_interstitial_admob_id);
      prefs.setString("ios_ads_interstitial_type", response_ios_ads_interstitial_type);
      prefs.setInt("ios_ads_interstitial_click", response_ios_ads_interstitial_click);
      prefs.setString("ios_ads_banner_facebook_id", response_ios_ads_banner_facebook_id);
      prefs.setString("ios_ads_banner_admob_id", response_ios_ads_banner_admob_id);
      prefs.setString("ios_ads_banner_type", response_ios_ads_banner_type);
      prefs.setString("ios_ads_native_admob_id", response_ios_ads_native_admob_id);
      prefs.setString("ios_ads_native_facebook_id", response_ios_ads_native_facebook_id);
      prefs.setInt("ios_ads_native_item", response_ios_ads_native_item);
      prefs.setString("ios_ads_native_type", response_ios_ads_native_type);
      prefs.setString("ios_admob_publisher_id", response_ios_publisher_id);
      prefs.setString("ios_admob_app_id", response_ios_admob_app_id);


      String _old_app_star = prefs.getString("app_star");

      if(_old_app_star != _app_star){
        prefs.setString("app_star", _app_star);
      }
    }
    redirectTo();
  }
  _launchURL(String url) async {

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

}




import 'dart:io';

import 'package:facebook_audience_network/ad/ad_banner.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
//import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:line_icons/line_icons.dart';
import 'package:app/api/api_config.dart';
import 'package:app/api/api_rest.dart';
import 'package:app/model/post.dart';
import 'package:app/provider/ads_provider.dart';

import 'package:app/screens/articles/image_viewer.dart';
import 'package:app/screens/comments/comments_list.dart';
import 'package:need_resume/need_resume.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
class YoutubeDetail extends StatefulWidget {
  Post post;
  Function postFavorite;
  bool back;


  YoutubeDetail({this.post,this.postFavorite, this.back = true});

  @override
  _YoutubeDetailState createState() => _YoutubeDetailState();
}

class _YoutubeDetailState extends ResumableState<YoutubeDetail> {


  YoutubePlayerController _youtubeController;



  BannerAd myBanner ;
  Container adContainer = Container(height: 0);
  Widget _currentAd = SizedBox(width: 0.0, height: 0.0);
  AdsProvider adsProvider;

  initBannerAds() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    adsProvider =  AdsProvider(prefs,(Platform.isAndroid)?TargetPlatform.android:TargetPlatform.iOS);
    print(adsProvider.getBannerType());
    if(adsProvider.getBannerType() == "ADMOB"){
      showAdmobBanner();
    }else if(adsProvider.getBannerType() == "FACEBOOK"){
      showFacebookBanner();
    }else if(adsProvider.getBannerType() == "BOTH"){
      if(adsProvider.getBannerLocal() == "FACEBOOK"){
        adsProvider.setBannerLocal("ADMOB");
        showFacebookBanner();
      }else{
        adsProvider.setBannerLocal("FACEBOOK");
        showAdmobBanner();
      }
    }
  }
  showFacebookBanner(){
    String banner_fan_id = adsProvider.getBannerFacebookId();
    print("banner_fan_id : "+banner_fan_id);
    setState(() {
      _currentAd = FacebookBannerAd(
        placementId: banner_fan_id,
        bannerSize: BannerSize.STANDARD,
        listener: (result, value) {
          print("Banner Ad: $result -->  $value");
        },
      );
    });
  }
  showAdmobBanner(){
    String banner_admob_id = adsProvider.getBannerAdmobId();
    myBanner = BannerAd(
      adUnitId:banner_admob_id,
      size: AdSize.fullBanner,
      request: AdRequest(),
      listener: BannerAdListener(
          onAdLoaded: (Ad ad) => print('Ad loaded.'),
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            ad.dispose();
            print('Ad failed to load: $error');
          }
      ),
    );
    myBanner.load();
    AdWidget adWidget = AdWidget(ad: myBanner);
    setState(() {
      adContainer =  Container(
        alignment: Alignment.center,
        child: adWidget,
        width: myBanner.size.width.toDouble(),
        height: myBanner.size.height.toDouble(),
      );
    });
  }



  @override
  void initState() {
    // TODO: implement initState
    Future.delayed(Duration(milliseconds: 500), () {
      initBannerAds();
    });
    _youtubeController = YoutubePlayerController(
      initialVideoId: widget.post.video,
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    )..addListener(listener);
    super.initState();
    addView(widget.post);
    if(widget.back == false)
      initFavorite();


  }
  void listener() {

  }
  @override
  void deactivate() {
    // Pauses video while navigating to next page.
    _youtubeController.pause();
    super.deactivate();
  }

  @override
  void onResume() {
    // Implement your code inside here
    _youtubeController.play();
  }
  @override
  void onPause() {
    // Implement your code inside here
    _youtubeController.pause();
  }
  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      onExitFullScreen: () {
        // The player forces portraitUp after exiting fullscreen. This overrides the behaviour.
        SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      },
      player: YoutubePlayer(
        controller: _youtubeController,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.blueAccent,
        topActions: <Widget>[
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              _youtubeController.metadata.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18.0,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
              size: 25.0,
            ),
            onPressed: () {
              print('Settings Tapped!');
            },
          ),
        ],
      ),
      builder: (context, player) => WillPopScope(
        onWillPop: (){
          (widget.back == true)? Navigator.of(context).pop():Navigator.pushReplacementNamed(context, "/home");
        },
        child: Container(
          color:  Theme.of(context).primaryColor,

          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Scaffold(
                      appBar: AppBar(
                        backgroundColor: Theme.of(context).primaryColor,
                        centerTitle: false,
                        title: Text(widget.post.title),
                        elevation: 0,
                        iconTheme: IconThemeData(color: Theme.of(context).textTheme.bodyText1.color),
                        leading: new IconButton(
                          icon: new Icon(LineIcons.angleLeft),
                          onPressed: () => (widget.back == true)? Navigator.of(context).pop():Navigator.pushReplacementNamed(context, "/home"),
                        ),
                        actions: [
                          IconButton(
                            icon: new Icon((widget.post.favorite == true)?LineIcons.heartAlt:LineIcons.heart),
                            onPressed:() {
                              setState(() {
                                if(widget.back == false)
                                  postFavorite(widget.post);
                                else
                                  widget.postFavorite(widget.post);
                              });
                            },
                          ),
                          IconButton(
                            icon: new Icon(LineIcons.share),
                            onPressed: (){
                              addShare(widget.post);
                              Share.share(widget.post.title+' \n\nRead this post at : ' + apiConfig.api_url.replaceAll("/api/", "/post/")+widget.post.id.toString()+".html", subject: widget.post.title);
                            },
                          )
                        ],
                      ),
                      floatingActionButton: FloatingActionButton(
                        heroTag: "comment_hero_"+widget.post.id.toString(),
                        child: Icon(LineIcons.comments),
                        onPressed: (){
                         // Route route = MaterialPageRoute(builder: (context) => CommentsList(post:widget.post));
                          Route route = MaterialPageRoute(builder: (context) => CommentsList(post: widget.post));
                          push(context, route);
                        },
                      ),
                      body:SingleChildScrollView(
                          child:
                          Column(
                            children: [
                              player,
                              Container(
                                padding: EdgeInsets.only(left: 10,right: 10,bottom: 5,top: 20),
                                width: double.infinity,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Text(
                                        widget.post.title,
                                        style: TextStyle(
                                            color: Theme.of(context).textTheme.bodyText1.color,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 22
                                        )
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                        widget.post.date,
                                        style: TextStyle(
                                            color: Theme.of(context).textTheme.bodyText2.color,
                                            fontSize: 14
                                        )
                                    ),
                                    SizedBox(height: 15),
                                    Divider(),

                                  ],
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.all(5),
                                child: Html(

                                  data:widget.post.content,
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
                              ),
                              SizedBox(height: 20),
                            ],
                          )
                      )
                  ),
                ),
                adContainer,
                _currentAd
              ],
            ),
          ),
        ),
      ),
    );

  }

  addShare(Post post) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('shared_post_' + post.id.toString()) != true) {
      prefs.setBool('shared_post_' + post.id.toString(), true);

      int id_ = post.id + 55463938;
      convert.Codec<String, String> stringToBase64 = convert.utf8.fuse(convert.base64);
      String id_base_64 = stringToBase64.encode(id_.toString());

      var statusCode = 200;
      var response;
      var jsonData;
      try {
        response = await http.post(apiRest.addPostShare(), body: {'id': id_base_64});
        jsonData =  convert.jsonDecode(response.body);
        setState(() {
          widget.post.shares = widget.post.shares+1;
        });
      } catch (ex) {
        print(ex);
        statusCode =  500;
      }

    }
  }
  addView(Post post) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('viewed_post_' + post.id.toString()) != true) {
      prefs.setBool('viewed_post_' + post.id.toString(), true);

      int id_ = post.id + 55463938;
      convert.Codec<String, String> stringToBase64 = convert.utf8.fuse(convert.base64);
      String id_base_64 = stringToBase64.encode(id_.toString());

      var statusCode = 200;
      var response;
      var jsonData;
      try {
        response = await http.post(apiRest.addPostView(), body: {'id': id_base_64});
        jsonData =  convert.jsonDecode(response.body);
        setState(() {
          widget.post.views = widget.post.views+1;
        });
      } catch (ex) {
        statusCode =  500;
      }
    }
  }
  _launchURL(String url) async {

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  List<Post> favoritePostsList = [];

  postFavorite(Post post) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String  favoritePostsString=  await prefs.getString('post_favorires');

    if(favoritePostsString != null){
      favoritePostsList = Post.decode(favoritePostsString);
    }
    if(favoritePostsList == null){
      favoritePostsList= [];
    }


    Post favorited_post =  null;
    for(Post favorite_post in favoritePostsList){
      if(favorite_post.id == post.id){
        favorited_post = favorite_post;
      }
    }
    if(favorited_post == null){
      favoritePostsList.add(post);
      setState(() {
        post.favorite = true;
      });
    }else{
      favoritePostsList.remove(favorited_post);
      setState(() {
        post.favorite = false;
      });
    }

    String encodedData = Post.encode(favoritePostsList);
    prefs.setString('post_favorires',encodedData);
  }
  initFavorite() async{

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String  favoritePostsString=  await prefs.getString('post_favorires');

    if(favoritePostsString != null){
      favoritePostsList = Post.decode(favoritePostsString);
    }
    if(favoritePostsList == null){
      favoritePostsList= [];
    }
  }

}

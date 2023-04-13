import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:facebook_audience_network/ad/ad_banner.dart';
import 'package:flutter/cupertino.dart' as d;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:line_icons/line_icons.dart';
import 'package:app/api/api_rest.dart';
import 'package:app/model/status.dart';
import 'package:app/provider/ads_provider.dart';
import 'package:app/screens/comments/comments_list.dart';
import 'package:app/screens/other/report.dart';
import 'package:share/share.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

class QuoteDetail extends StatefulWidget {
  Status status;
  Function liked;
  Function viewed;
  Function shared;
  bool back;

  QuoteDetail({this.status, this.liked,this.viewed,this.shared,this.back = true});

  @override
  _QuoteDetailState createState() => _QuoteDetailState();
}

class _QuoteDetailState extends State<QuoteDetail> {


  List<String> menuList = ["Copy as text","Report photo"];
  List<IconData> menuIcons =[LineIcons.copy,LineIcons.flag];

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
    super.initState();
    Future.delayed(Duration(milliseconds: 500), () {
      initBannerAds();
    });
    if(widget.back == false)
        initLiked();
   if(widget.back == false)
      addView(widget.status);
    else
      widget.viewed(widget.status);
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        (widget.back == true)? Navigator.of(context).pop():Navigator.pushReplacementNamed(context, "/home");
      },
      child: d.Container(
        color: Color(int.parse("0xff"+widget.status.color)),
        child: d.SafeArea(
          top: false,
          child: Material(
            color: Colors.transparent,
            child: Hero(
              tag: "quote_hero_"+widget.status.id.toString(),
              child: d.Column(
                children: [
                  d.Expanded(
                    child: Scaffold(
                      backgroundColor: Color(int.parse("0xff"+widget.status.color)),
                      appBar: AppBar(
                          centerTitle: false,
                          elevation: 0,
                        backgroundColor: Colors.transparent,
                        iconTheme: IconThemeData(color: Colors.white),
                        leading: new IconButton(
                          icon: new Icon(LineIcons.angleLeft),
                          onPressed: () => (widget.back == true)? Navigator.of(context).pop():Navigator.pushReplacementNamed(context, "/home"),
                        ),
                        actions: <Widget>[
                          PopupMenuButton<String>(
                            onSelected: (String index){
                              switch(index){
                                case "0":
                                  _copyAsText();
                                  break;
                                case "1":
                                  _reportQuote();
                                  break;
                              }
                            },
                            color:  Theme.of(context).scaffoldBackgroundColor,
                            itemBuilder: (BuildContext context) {
                              return {0, 1}.map((int choice) {
                                return PopupMenuItem<String>(
                                  value: choice.toString(),
                                  child: Row(
                                    children: [
                                      Icon(menuIcons[choice],color:   Theme.of(context).textTheme.bodyText2.color,size: 16),
                                      SizedBox(width: 5),
                                      Text(menuList[choice],style: TextStyle(color:  Theme.of(context).textTheme.bodyText2.color)),
                                    ],
                                  ),
                                );
                              }).toList();
                            },
                          ),
                        ],

                      ),
                      body:
                      SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: RepaintBoundary(
                                key: _globalKey,
                                child: d.Container(
                                  decoration: d.BoxDecoration(
                                    color: Color(int.parse("0xff"+widget.status.color)),
                                    borderRadius: d.BorderRadius.circular(10)
                                  ),
                                  child: ConstrainedBox(
                                    constraints: new BoxConstraints(
                                      minHeight: 120.0,
                                    ),
                                    child: Center(
                                      child: Text(
                                        utf8.decode(base64Url.decode(widget.status.quote)),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 25,
                                            color: Colors.white,
                                            decoration: TextDecoration.none
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                  border: Border(top: BorderSide(color: Colors.grey))
                              ),
                              height: 50,
                              child:  Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Expanded(
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: (){
                                            setState(() {
                                              if(widget.back == false)
                                                statusLiked(widget.status);
                                              else
                                                widget.liked(widget.status);
                                            });
                                        },
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 17,horizontal: 5),
                                              child: Icon(
                                                (widget.status.liked == true)?Icons.thumb_up:Icons.thumb_up_outlined,
                                                color:Colors.white70,
                                                size: 16,
                                              ),
                                            ),
                                            Text(
                                              widget.status.likes.toString()+ " Likes",
                                              style: TextStyle(
                                                  color:Colors.white70,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: (){
                                          _shareQuote();
                                        },
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 17,horizontal: 5),
                                              child: Icon(
                                                LineIcons.share,
                                                color:Colors.white70,
                                                size: 16,
                                              ),
                                            ),
                                            Text(
                                              widget.status.shares.toString()+" Shares",
                                              style: TextStyle(
                                                  color:Colors.white70,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: (){
                                          Route route = MaterialPageRoute(builder: (context) => CommentsList(status:widget.status));
                                          Navigator.push(context, route);
                                        },
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 17,horizontal: 5),
                                              child: Icon(
                                                LineIcons.commentsAlt,
                                                color:Colors.white70,
                                                size: 16,
                                              ),
                                            ),
                                            Text(
                                              widget.status.comments.toString()+" Comments",
                                              style: TextStyle(
                                                  color:Colors.white70,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  adContainer,
                  _currentAd
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  _shareQuote() async {
   //await Share.share(utf8.decode(base64Url.decode(widget.status.quote)));
    setState(() {
      if(widget.back == false)
        addShare(widget.status);
      else
        widget.shared(widget.status);
    });
    _capturePng();
  }
  bool inside = false;
  Uint8List imageInMemory;
  GlobalKey _globalKey = new GlobalKey();

  Future<void> _capturePng() async {
    try {
      print('inside');
      inside = true;
      RenderRepaintBoundary boundary =
      _globalKey.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();
      String bs64 = base64Encode(pngBytes);
      print(pngBytes);
      print(bs64);
      File.fromRawPath(pngBytes);

      final appDir = await getTemporaryDirectory();
      File file = File('${appDir.path}/sth.jpg');
      await file.writeAsBytes(pngBytes);
      await Share.shareFiles([file.path], text: utf8.decode(base64Url.decode(widget.status.quote)));
      setState(() {
        widget.shared(widget.status);
      });
    } catch (e) {
      print(e);
    }
  }
  List<Status> likedStatusList = [];

  statusLiked(Status status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String  favoriteStatussString=  await prefs.getString('status_liked');

    if(favoriteStatussString != null){
      likedStatusList = Status.decode(favoriteStatussString);
    }
    if(likedStatusList == null){
      likedStatusList= [];
    }

    Status liked_status =  null;

    for(Status current_status in likedStatusList){
      if(current_status.id == status.id){
        liked_status = current_status;
      }
    }

    if(liked_status == null){
      likedStatusList.add(status);
      setState(() {
        status.liked = true;
        status.likes+=1;
        _toggleLike(status,"add");

      });
    }else{
      likedStatusList.remove(liked_status);
      setState(() {
        status.liked = false;
        status.likes-=1;
        _toggleLike(status,"delete");
      });
    }
    String encodedData = Status.encode(likedStatusList);
    prefs.setString('status_liked',encodedData);
  }
  Future<String>  _toggleLike(Status status,String state) async{
    int id_ = status.id + 55463938;
    convert.Codec<String, String> stringToBase64 = convert.utf8.fuse(convert.base64);
    String id_base_64 = stringToBase64.encode(id_.toString());

    var statusCode = 200;
    var response;
    var jsonData;
    try {
      response = await http.post(apiRest.toggleLike(state), body: {'id': id_base_64});
      jsonData =  convert.jsonDecode(response.body);
    } catch (ex) {
      print(ex);
      statusCode =  500;
    }
  }

  addShare(Status status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('shared_status_' + status.id.toString()) != true) {
      prefs.setBool('shared_status_' + status.id.toString(), true);

      int id_ = status.id + 55463938;
      convert.Codec<String, String> stringToBase64 = convert.utf8.fuse(convert.base64);
      String id_base_64 = stringToBase64.encode(id_.toString());
      setState(() {
        status.shares = status.shares+1;
      });
      var statusCode = 200;
      var response;
      var jsonData;
      try {
        response = await http.post(apiRest.addStatusShare(), body: {'id': id_base_64});
        jsonData =  convert.jsonDecode(response.body);

      } catch (ex) {
        print(ex);
        statusCode =  500;
      }

    }
  }

  addView(Status status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('viewed_status_' + status.id.toString()) != true) {
      prefs.setBool('viewed_status_' + status.id.toString(), true);

      int id_ = status.id + 55463938;
      convert.Codec<String, String> stringToBase64 = convert.utf8.fuse(convert.base64);
      String id_base_64 = stringToBase64.encode(id_.toString());
      setState(() {
        status.views = status.views+1;
      });
      var statusCode = 200;
      var response;
      var jsonData;
      try {
        response = await http.post(apiRest.addStatusView(), body: {'id': id_base_64});
        jsonData =  convert.jsonDecode(response.body);

      } catch (ex) {
        print(ex);
        statusCode =  500;
      }

    }
  }

  void initLiked() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String  likedStatusString=  await prefs.getString('status_liked');

    if(likedStatusString != null){
      likedStatusList = Status.decode(likedStatusString);
    }
    if(likedStatusList == null){
      likedStatusList= [];
    }

      for(Status liked_status in likedStatusList){
        if(liked_status.id == widget.status.id){
          setState(() {
            widget.status.liked = true;
          });
        }
      }
  }
  void _reportQuote() {
    Route route = MaterialPageRoute(builder: (context) => Report(message:"Report quote :"+widget.status.description,image: Icon(Icons.format_quote,size: 100),title: "Report "+widget.status.description,status: widget.status.id));
    Navigator.push(context, route);
  }
  void _copyAsText() {
    Clipboard.setData(new ClipboardData(text:widget.status.description));
    Fluttertoast.showToast(
      msg:"Your quote has been copied successfully!",
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

}


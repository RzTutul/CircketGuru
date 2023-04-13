import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:facebook_audience_network/ad/ad_banner.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
//import 'package:gallery_saver/gallery_saver.dart';
import 'package:line_icons/line_icons.dart';
import 'package:app/api/api_rest.dart';
import 'package:app/config/colors.dart';
import 'package:app/model/status.dart';
import 'package:app/provider/ads_provider.dart';
import 'package:app/screens/comments/comments_list.dart';
import 'package:app/screens/other/report.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share/share.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

class ImageDetail extends StatefulWidget {
  Status status;
  Function liked;
  Function shared;
  Function viewed;
  Function downloaded;
  bool back;

  ImageDetail({this.status,this.liked, this.shared, this.viewed,this.downloaded,this.back = true});

  @override
  _ImageDetailState createState() => _ImageDetailState();
}

class _ImageDetailState extends State<ImageDetail> {

  List<Status> likedStatusList = [];

  List<String> menuList = ["Save to phone","Share external","Report photo"];
  List<IconData> menuIcons =[LineIcons.download,LineIcons.share,LineIcons.flag];
  String state  =  null;


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
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        top: false,
        child: WillPopScope(
          onWillPop: () {
            (widget.back == true)? Navigator.of(context).pop():Navigator.pushReplacementNamed(context, "/home");
          },
          child: Material(
            color: Colors.transparent,
            child: Hero(
              tag: "image_hero_"+widget.status.id.toString(),
              child: Column(
                children: [
                  Expanded(
                    child: Scaffold(
                      backgroundColor:  Theme.of(context).scaffoldBackgroundColor,
                      appBar: AppBar(
                        centerTitle: false,
                        elevation: 0,
                          backgroundColor: Colors.transparent,
                        leading: new IconButton(
                          icon: new Icon(LineIcons.angleLeft),
                          onPressed: () => (widget.back == true)? Navigator.of(context).pop():Navigator.pushReplacementNamed(context, "/home"),
                        ),
                          actions: <Widget>[
                            PopupMenuButton<String>(
                              onSelected: (String index){
                                switch(index){
                                  case "0":
                                    _saveToPhone();
                                    break;
                                  case "1":
                                    _shareImage();
                                    break;
                                  case "2":
                                    _reportImage();
                                    break;
                                }
                              },
                              color:  Theme.of(context).scaffoldBackgroundColor,
                              itemBuilder: (BuildContext context) {
                                return {0, 1,2}.map((int choice) {
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
                      Column(
                        children: [
                          Expanded(
                              child: Stack(
                                children: [
                                  SafeArea(child: Container(child: PhotoView(backgroundDecoration:BoxDecoration(color:  Theme.of(context).scaffoldBackgroundColor),imageProvider: CachedNetworkImageProvider(widget.status.original)))),
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      color:  Theme.of(context).cardColor.withOpacity(0.4),
                                      padding: EdgeInsets.only(left: 10,right: 10,top: 10),
                                      child: SafeArea(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              widget.status.username,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color:  Theme.of(context).textTheme.bodyText1.color,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            SizedBox(height:5),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  LineIcons.clockAlt,
                                                  color:  Theme.of(context).textTheme.bodyText2.color,
                                                  size: 11,
                                                ),
                                                SizedBox(width:2),
                                                Text(
                                                  widget.status.created,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color:  Theme.of(context).textTheme.bodyText2.color,
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height:20),
                                            Text(
                                              widget.status.description,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color:  Theme.of(context).textTheme.bodyText1.color,
                                                fontSize: 12,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                            SizedBox(height:20),

                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ),
                          Container(
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
                                              color: Theme.of(context).textTheme.bodyText2.color,
                                              size: 16,
                                            ),
                                          ),
                                          Text(
                                            widget.status.likes.toString()+ " Likes",
                                            style: TextStyle(
                                                color: Theme.of(context).textTheme.bodyText2.color,
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
                                  child:
                                  (state!=null)?
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                                        child: SizedBox(child: CircularProgressIndicator(strokeWidth: 2),height: 20,width: 20),
                                      ),
                                      Text(
                                        state,
                                        style: TextStyle(
                                            color: Theme.of(context).textTheme.bodyText2.color,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12
                                        ),
                                      )
                                    ],
                                  )
                                      :
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: (){
                                        _shareImage();
                                      },
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 17,horizontal: 5),
                                            child: Icon(
                                              LineIcons.share,
                                              color: Theme.of(context).textTheme.bodyText2.color,
                                              size: 16,
                                            ),
                                          ),
                                          Text(
                                            widget.status.shares.toString()+" Shares",
                                            style: TextStyle(
                                                color: Theme.of(context).textTheme.bodyText2.color,
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
                                              color: Theme.of(context).textTheme.bodyText2.color,
                                              size: 16,
                                            ),
                                          ),
                                          Text(
                                            widget.status.comments.toString()+" Comments",
                                            style: TextStyle(
                                                color: Theme.of(context).textTheme.bodyText2.color,
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
                          ),
                        ],
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

  _shareImage() async {
    setState(() {
      state = "Sharing ...";
    });
    var appDocDir = await getTemporaryDirectory();
    String savePath = appDocDir.path + "/"+widget.status.id.toString()+"_temp."+widget.status.extension;
    await Dio().download(widget.status.original, savePath);
    await Share.shareFiles([savePath], text: widget.status.description +" image");
    setState(() {
      state = null;
      if(widget.back == false)
        addShare(widget.status);
      else
        widget.shared(widget.status);
    });

  }
  void _saveToPhone() async {

    bool permission = false;


    if (Platform.isAndroid) {
      if (await Permission.storage.request().isGranted) {
        permission= true;
      }
    } else if (Platform.isIOS) {
      if (await Permission.photos.request().isGranted) {
        permission= true;

      }
    }


    if(permission == true) {
      String path = widget.status.original ;

      setState(() {
        state = "Downloading ...";
      });
      var response = await Dio().get(path,
          options: Options(responseType: ResponseType.bytes));
      final result = await ImageGallerySaver.saveImage(
          Uint8List.fromList(response.data),
          quality: 60,
          name: "hello");

      setState(() {
        state = null;
        Fluttertoast.showToast(
          msg: "Your image has been downloaded successfully !",
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.blueAccent,
          textColor: Colors.white,
        );
        if(widget.back == false)
          addDownload(widget.status);
        else
          widget.downloaded(widget.status);
      });
    }else{
      Fluttertoast.showToast(
        msg: "Permission required !",
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.deepOrange,
        textColor: Colors.white,
      );
    }
  }
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
  addDownload(Status status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('downloaded_status_' + status.id.toString()) != true) {
      prefs.setBool('downloaded_status_' + status.id.toString(), true);

      int id_ = status.id + 55463938;
      convert.Codec<String, String> stringToBase64 = convert.utf8.fuse(convert.base64);
      String id_base_64 = stringToBase64.encode(id_.toString());
      setState(() {
        status.downloads = status.downloads+1;
      });
      var statusCode = 200;
      var response;
      var jsonData;
      try {
        response = await http.post(apiRest.addStatusDownload(), body: {'id': id_base_64});
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

  void _reportImage() {
    Route route = MaterialPageRoute(builder: (context) => Report(message:"Report image :"+widget.status.description,image:  Image.network(widget.status.image,fit: BoxFit.cover,),title: "Report "+widget.status.description,status: widget.status.id));
    Navigator.push(context, route);
  }

}

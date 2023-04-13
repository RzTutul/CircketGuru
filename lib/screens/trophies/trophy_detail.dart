

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:facebook_audience_network/ad/ad_banner.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:line_icons/line_icons.dart';
import 'package:app/config/colors.dart';
import 'package:app/model/trophy.dart';
import 'package:app/model/trophy.dart';
import 'package:app/provider/ads_provider.dart';
import 'package:app/screens/articles/image_viewer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
class TrophyDetail extends StatefulWidget {
  Trophy trophy;


  TrophyDetail({this.trophy});

  @override
  _TrophyDetailState createState() => _TrophyDetailState();
}

class _TrophyDetailState extends State<TrophyDetail> {

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
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                  child:
                  Column(
                    children: [
                      Stack(
                        children:[
                          Container(
                            height: 350,
                            decoration:BoxDecoration(
                              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15),bottomRight: Radius.circular(15)),
                              boxShadow: [BoxShadow(
                                  color: Colors.black,
                                  offset: Offset(0,0),
                                  blurRadius: 7
                              )],
                              image: DecorationImage(
                                image: CachedNetworkImageProvider(widget.trophy.image),
                                fit: BoxFit.cover,
                              ),
                            ) ,
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).accentColor.withOpacity(0.4),
                                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15),bottomRight: Radius.circular(15)),
                              ),
                            ),
                          ),
                          Positioned(
                              bottom: 20,
                              left: 20,
                              right: 20,
                              child:Center(
                                child: Text(
                                    widget.trophy.title,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 19
                                    )
                                ),
                              )
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            top: 50,
                            bottom: 0,
                            child: Center(
                              child: Container(
                                width: 130,
                                height: 160,
                                padding: EdgeInsets.all(10),
                                child: Stack(
                                  children: [
                                    Positioned(
                                        height: 30,
                                        width: 110,
                                        child: Center(
                                            child: Text(
                                              widget.trophy.number,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 26
                                              ),
                                            )
                                        )
                                    ),
                                    Positioned(
                                      top: 40,
                                      width: 110,
                                      height: 100,
                                      child: Center(
                                        child: Image(
                                            image: NetworkImage(widget.trophy.icon),
                                            height: 100,
                                            width: 110,
                                            color: Colors.white
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(7),
                                  color:Theme.of(context).accentColor
                                ),
                              ),
                            ),
                          ),
                          AppBar(
                            centerTitle: false,
                            elevation: 0,
                            backgroundColor: Colors.transparent,
                            iconTheme: IconThemeData(color: Colors.white),
                            leading: new IconButton(
                              icon: new Icon(LineIcons.angleLeft),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.all(5),
                        width: MediaQuery.of(context).size.width,
                        child:Center(
                          child: Text(
                              widget.trophy.description,
                              style: TextStyle(
                                  color: Theme.of(context).textTheme.bodyText1.color,
                                  fontWeight: FontWeight.w800,
                                fontSize: 13
                              )
                          ),
                        ),
                        decoration: BoxDecoration(
                          border: Border(left: BorderSide(color: Theme.of(context).textTheme.bodyText1.color,width: 5)),
                          color:Theme.of(context).textTheme.bodyText1.color.withOpacity(0.1),
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        margin: EdgeInsets.all(0),
                        child: Html(

                            data:widget.trophy.content,
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
              ),
            ),
            SafeArea(
                top: false,
                child: Stack(
                  children: [
                    adContainer,
                    _currentAd
                  ],
                ))
          ],
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

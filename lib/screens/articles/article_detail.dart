

import 'dart:io';

import 'package:facebook_audience_network/ad/ad_banner.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:line_icons/line_icons.dart';
import 'package:app/config/colors.dart';
import 'package:app/model/article.dart';
import 'package:app/provider/ads_provider.dart';
import 'package:app/screens/articles/image_viewer.dart';
import 'package:shared_preferences/shared_preferences.dart';
class ArticleDetail extends StatefulWidget {
  Article article;


  ArticleDetail({this.article});

  @override
  _ArticleDetailState createState() => _ArticleDetailState();
}

class _ArticleDetailState extends State<ArticleDetail> {

  BannerAd myBanner ;
  Container adContainer = Container(height: 0);
  Widget _currentAd = SizedBox(width: 0.0, height: 0.0);
  AdsProvider adsProvider;

  initBannerAds() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    adsProvider =  AdsProvider(prefs,(Platform.isAndroid)?TargetPlatform.android:TargetPlatform.iOS);
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
                        height: MediaQuery.of(context).size.height/2.5,
                        decoration:BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15),bottomRight: Radius.circular(15)),
                              boxShadow: [BoxShadow(
                                  color: Colors.black,
                                  offset: Offset(0,0),
                                  blurRadius: 7
                              )],
                              image: DecorationImage(
                                image: NetworkImage(widget.article.image),
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
                          child:Text(
                            widget.article.title,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 19
                            )
                          )
                        ),
                        AppBar(
                          centerTitle: false,
                          elevation: 0,
                          backgroundColor: Colors.transparent,
                          iconTheme: IconThemeData(color: Colors.white),
                          leading: new IconButton(
                            icon: new Icon(LineIcons.alignLeft),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 20),
                    Html(
                      data:widget.article.content,
                      style: {
                        "*": Style(
                            color: Theme.of(context).textTheme.bodyText1.color,
                        ),
                      },
                      onImageTap: (url, _, __, ___) {
                        Route route = MaterialPageRoute(builder: (context) => ImageViewer(url:url));
                        Navigator.push(context, route);
                      },
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
}

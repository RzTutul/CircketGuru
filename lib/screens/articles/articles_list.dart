import 'dart:io';

import 'package:facebook_audience_network/ad/ad_interstitial.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:line_icons/line_icons.dart';
import 'package:app/api/api_rest.dart';
import 'package:app/config/colors.dart';
import 'package:app/model/team.dart';
import 'package:http/http.dart' as http;
import 'package:app/model/article.dart';
import 'package:app/provider/ads_provider.dart';
import 'package:app/screens/articles/article_detail.dart';
import 'dart:convert' as convert;

import 'package:app/screens/articles/article_widget.dart';
import 'package:app/screens/loading.dart';
import 'package:app/screens/tryagain.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ArticlesList extends StatefulWidget {
  Team team;

  ArticlesList({this.team});

  @override
  _ArticlesListState createState() => _ArticlesListState();
}

class _ArticlesListState extends State<ArticlesList> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    refreshing = false;
    _getList();
    initInterstitialAd();

  }
  List<Article> articlesList = [];
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  bool loading =  false;
  String state =  "progress";
  bool refreshing =  true;


  InterstitialAd _admobInterstitialAd;
  static final AdRequest request = AdRequest();
  Route article_route = null;
  AdsProvider adsProvider;

  int should_be_displaed= 1;
  int ads_interstitial_click;
  String ads_interstitial_type;

  bool _isInterstitialAdLoaded = false;
  bool _interstitialReady = false;

  String interstitial_facebook_id;
  String interstitial_admob_id;


  void _loadInterstitialAd() {
    FacebookInterstitialAd.destroyInterstitialAd();
    FacebookInterstitialAd.loadInterstitialAd(
      placementId:interstitial_facebook_id,
      listener: (result, value) {
        print(">> FAN > Interstitial Ad: $result --> $value");
        if (result == InterstitialAdResult.LOADED){
          _isInterstitialAdLoaded = true;
        }
        if(result == InterstitialAdResult.ERROR){
        }
        /// Once an Interstitial Ad has been dismissed and becomes invalidated,
        /// load a fresh Ad by calling this function.
        if (result == InterstitialAdResult.DISMISSED ) {
          if(article_route != null)
            Navigator.push(context, article_route);
          _isInterstitialAdLoaded = false;
          _loadInterstitialAd();
        }
      },
    );
  }

  void initInterstitialAd() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    adsProvider =  AdsProvider(prefs,(Platform.isAndroid)?TargetPlatform.android:TargetPlatform.iOS);
    should_be_displaed =adsProvider.getInterstitialClicksStep();

    interstitial_admob_id =adsProvider.getAdmobInterstitialId();
    interstitial_facebook_id =adsProvider.getFacebookInterstitialId();
    ads_interstitial_type =adsProvider.getInterstitialType();
    ads_interstitial_click = adsProvider.getInterstitialClicks();

    if(ads_interstitial_type == "ADMOB"){
      MobileAds.instance.initialize().then((InitializationStatus status) {
        print('Initialization done: ${status.adapterStatuses}');
        MobileAds.instance
            .updateRequestConfiguration(RequestConfiguration(
            tagForChildDirectedTreatment:
            TagForChildDirectedTreatment.unspecified))
            .then((value) {
          createInterstitialAd();
        });
      });
    }else if(ads_interstitial_type == "FACEBOOK"){
      FacebookAudienceNetwork.init();
      _loadInterstitialAd();
    }else if(ads_interstitial_type == "BOTH"){

      MobileAds.instance.initialize().then((InitializationStatus status) {
        print('Initialization done: ${status.adapterStatuses}');
        MobileAds.instance
            .updateRequestConfiguration(RequestConfiguration(
            tagForChildDirectedTreatment:
            TagForChildDirectedTreatment.unspecified))
            .then((value) {
          createInterstitialAd();
        });
      });

      FacebookAudienceNetwork.init();
      _loadInterstitialAd();

    }
  }
  @override
  void dispose() {
    _admobInterstitialAd?.dispose();
    super.dispose();
  }
  void createInterstitialAd() {


    InterstitialAd.load(
        adUnitId: interstitial_admob_id,
        request: request,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print('$ad loaded');
            _admobInterstitialAd = ad;
            _admobInterstitialAd.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error.');
            _admobInterstitialAd = null;
            _interstitialReady = false;
            createInterstitialAd();
          },
        ));
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: false,
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: Theme.of(context).textTheme.bodyText1.color),
          leading: new IconButton(
            icon: new Icon(LineIcons.angleLeft),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(widget.team.title,style: TextStyle(color: Theme.of(context).textTheme.bodyText1.color)),
          elevation: 0.0
      ),
      body: buildHome(),
    );
  }

  Future<List<Article>>  _getList() async{
    if(loading)
      return null;
    articlesList.clear();
    loading =  true;

    if(refreshing == false){
      setState(() {
        state =  "progress";
      });
      refreshing = true;
    }
    print(apiRest.getArticlesByTeam(widget.team.id));
    var response;
    try {
      response = await http.get( apiRest.getArticlesByTeam(widget.team.id));
    } catch (ex) {
      loading = false;
      setState(() {
        state =  "error";
      });
    }
    if(!loading)
      return null;

    if (response.statusCode == 200) {
      var data  = await http.get( apiRest.getArticlesByTeam(widget.team.id));
      var jsonData =  convert.jsonDecode(data.body);
      for(Map i in jsonData){
        Article position = Article.fromJson(i);
        articlesList.add(position);
      }
      setState(() {
        state =  "success";
      });
    } else {
      setState(() {
        state =  "error";
      });
    }
    loading = false;
    return articlesList;
  }
  Widget buildHome() {
    switch(state){
      case "success":
        return RefreshIndicator(
          backgroundColor: Theme.of(context).primaryColor,
          key: refreshKey,
          onRefresh:_getList,
          child: ListView.builder(
              itemCount: articlesList.length,
              itemBuilder: (context, index) {
                return ArticleWidget(article:articlesList[index],index: index,navigate: navigate);
              }
          ),
        );
        break;
      case "progress":
        return LoadingWidget();
        break;
      case "error":
        return TryAgainButton(action:(){
          refreshing = false;
          _getList();
        });
        break;
    }
  }

  navigate(Article article){
    article_route = MaterialPageRoute(builder: (context) => ArticleDetail(article:article));
    if( ads_interstitial_type == "BOTH" && should_be_displaed == 0) {
      if(adsProvider.getInterstitialLocal() == "ADMOB" && _interstitialReady ){
        adsProvider.setInterstitialLocal("FACEBOOK");
        _admobInterstitialAd.show();
        should_be_displaed = 1;
        adsProvider.setInterstitialClicksStep(should_be_displaed) ;
      }else if(adsProvider.getInterstitialLocal() == "FACEBOOK" && _isInterstitialAdLoaded){
        adsProvider.setInterstitialLocal("ADMOB");
        FacebookInterstitialAd.showInterstitialAd();
        should_be_displaed = 1;
        adsProvider.setInterstitialClicksStep(should_be_displaed);
      }else{
        if( adsProvider.getInterstitialLocal() == "ADMOB"){
          adsProvider.setInterstitialLocal("FACEBOOK");
        }else{
          adsProvider.setInterstitialLocal("ADMOB");
        }
        should_be_displaed = 1;
        adsProvider.setInterstitialClicksStep(should_be_displaed);
        Navigator.push(context, article_route);
      }
    }else if(_isInterstitialAdLoaded && ads_interstitial_type == "FACEBOOK" && should_be_displaed == 0){
      FacebookInterstitialAd.showInterstitialAd();
      should_be_displaed = 1;
      adsProvider.setInterstitialClicksStep(should_be_displaed);
    }else if(_interstitialReady && ads_interstitial_type == "ADMOB" && should_be_displaed == 0){
      _admobInterstitialAd.show();
      should_be_displaed = 1;
      adsProvider.setInterstitialClicksStep(should_be_displaed);
    }else{
      should_be_displaed = (should_be_displaed >= ads_interstitial_click)? 0:should_be_displaed+1;
      adsProvider.setInterstitialClicksStep(should_be_displaed);
      Navigator.push(context, article_route);
    }
  }

}

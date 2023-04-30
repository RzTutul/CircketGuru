
import 'dart:io';

import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:line_icons/line_icons.dart';
import 'package:app/api/api_rest.dart';
import 'package:app/config/colors.dart';
import 'package:app/model/social.dart';
import 'package:app/model/team.dart';
import 'package:app/provider/ads_provider.dart';
import 'package:app/screens/articles/articles_list.dart';
import 'package:app/screens/home/club_title_widget.dart';
import 'package:app/screens/home/social_widget.dart';
import 'package:app/screens/home/title_home_widget.dart';
import 'package:http/http.dart' as http;
import 'package:app/screens/loading.dart';
import 'package:app/screens/players/players_list.dart';
import 'package:app/screens/staffs/staffs_list.dart';
import 'package:app/screens/trophies/trophies_list.dart';
import 'dart:convert' as convert;

import 'package:app/screens/tryagain.dart';
import 'package:shared_preferences/shared_preferences.dart';
class Club extends StatefulWidget {
  @override
  _ClubState createState() => _ClubState();
}

class _ClubState extends State<Club> {
  List<Team> teamList = [];
  List<Social> socialList = [];
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  bool loading =  false;
  bool refreshing =  true;
  String state =  "progress";


  InterstitialAd _admobInterstitialAd;
  static final AdRequest request = AdRequest();
  Route team_route = null;
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
          if(team_route != null)
            Navigator.push(context, team_route);
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
    if(_admobInterstitialAd != null)
      return;

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
  void initState() {
    // TODO: implement initState
    super.initState();

    refreshing =  false;
    _getList();
    initInterstitialAd();

  }
  
  Future<List<Team>>  _getList() async{
    if(loading)
      return null;
    teamList.clear();
    socialList.clear();
    loading =  true;

    if(refreshing == false) {
      setState(() {
        state = "progress";
      });
      refreshing =  true;

    }
    // Await the http get response, then decode the json-formatted response.
    var response;
    try {
      response = await http.get(apiRest.getClubItems());
    } catch (ex) {
      loading = false;
      setState(() {
        state =  "error";
      });
    }
    if(!loading)
      return null;

    if (response.statusCode == 200) {
      var data  = await http.get(apiRest.getClubItems());
      var jsonData =  convert.jsonDecode(data.body);
      var itemsjsonData = jsonData["items"];
      var socialsjsonData = jsonData["socials"];

      for(Map i in socialsjsonData){
        Social social = Social.fromJson(i);
        socialList.add(social);
      }
      teamList.add(Team());

      if(socialList.length>0){
        teamList.add(Team(id: -1));
      }
      for(Map i in itemsjsonData){
        Team team = Team.fromJson(i);
        teamList.add(team);
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
    return teamList;
  }

  Widget buildHome() {
    switch(state){
      case "success":
        return RefreshIndicator(
          backgroundColor: Theme.of(context).primaryColor,
          key: refreshKey,
          onRefresh:_getList,
          child: ListView.builder(
            itemCount: teamList.length,
            itemBuilder: (context, index) {
              if(teamList[index].id == null){
                return TitleHomeWidget(title: "The Team");
              }else if(teamList[index].id == -1){
                return  Container(
                  height: 55,
                  child: ListView.builder(
                    itemCount: socialList.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context,index){
                      return  SocialWidget(social: socialList[index]);
                    }
                  ),
                );
              }else{
                return ClubItemWidget(team: teamList[index],navigate: navigate);
              }
          },),
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
  
  @override
  Widget build(BuildContext context) {
    return
      buildHome();
  }

  navigate(Team team){
    switch(team.type){
      case "players":
        team_route = MaterialPageRoute(builder: (context) => PlayersList(team : team));
        break;
      case "articles":
        team_route = MaterialPageRoute(builder: (context) => ArticlesList(team : team));
        break;
      case "staffs":
        team_route = MaterialPageRoute(builder: (context) => StaffsList(team : team));
        break;
      case "trophies":
        team_route = MaterialPageRoute(builder: (context) => TrophiesList(team : team));
        break;
    }
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
        Navigator.push(context, team_route);
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
      Navigator.push(context, team_route);
    }

  }
}

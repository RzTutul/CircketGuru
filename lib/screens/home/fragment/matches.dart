
import 'dart:io';

import 'package:facebook_audience_network/ad/ad_interstitial.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:app/api/api_rest.dart';
import 'package:app/config/colors.dart';
import 'package:app/model/competition.dart';
import 'package:app/model/match.dart';
import 'package:app/model/post.dart';
import 'package:app/provider/ads_provider.dart';
import 'package:app/screens/ads/item_facebook_native.dart';
import 'package:app/screens/ads/item_native_admob.dart';
import 'package:app/screens/loading.dart';
import 'package:app/screens/matches/competitions_widget.dart';
import 'package:app/screens/matches/match_detail.dart';
import 'package:app/screens/status/create_widget.dart';
import 'package:app/screens/matches/match_mini_widget.dart';
import 'package:app/screens/status/status_widget.dart';
import 'package:app/screens/home/title_home_widget.dart';

import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:app/screens/tryagain.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'match_details.dart';

class Matches extends StatefulWidget {
  @override
  _MatchesState createState() => _MatchesState();
}

class _MatchesState extends State<Matches> {
  List<Competition> competitionsList = [];
  List<Match> matchesList = [];
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  bool loading =  false;
  bool refreshing =  true;
  String state =  "progress";
  String state_matches =  "progress";

  Competition selected_competition;

  bool load_more = false;
  int page = 0;

  ScrollController listViewController= new ScrollController();

  /* native ads */
  int native_ads_position = 0;
  int native_ads_item = 0;
  String native_ads_type = "NONE";
  String native_ads_current_type = "NONE";
  String facebook_native_ad_id = "NONE";
  String admob_native_ad_id = "NONE";

  /* end native ads */

  InterstitialAd _admobInterstitialAd;
  static final AdRequest request = AdRequest();
  Route match_route = null;
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
          if(match_route != null)
            Navigator.push(context, match_route);
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
  void initNativeAd() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    adsProvider =  AdsProvider(prefs,(Platform.isAndroid)?TargetPlatform.android:TargetPlatform.iOS);
    facebook_native_ad_id = await  adsProvider.getNativeFacebookId();
    admob_native_ad_id = await  adsProvider.getNativeAdmobId();
    native_ads_type =  await adsProvider.getNativeType();
    native_ads_item =  await  adsProvider.getNativeItem();

  }
  void insertAds(){
    if(native_ads_position  ==  native_ads_item){
      native_ads_position = 0;
      if(native_ads_type == "ADMOB"){
        matchesList.add(Match(id:-5));
      }else if(native_ads_type =="FACEBOOK"){
        matchesList.add(Match(id:-6));
      }else if(native_ads_type =="BOTH"){
        if(native_ads_current_type == "ADMOB"){
          matchesList.add(Match(id:-5));
          native_ads_current_type = "FACEBOOK";
        }else{
          matchesList.add(Match(id:-6));
          native_ads_current_type = "ADMOB";
        }
      }
    }
    native_ads_position++;
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
    initInterstitialAd();
    initNativeAd();
    refreshing =  false;
    _getList();
    listViewController.addListener(_scrollListener);
  }

  _scrollListener() {
    if (listViewController.offset >= (listViewController.position.maxScrollExtent) && !listViewController.position.outOfRange) {
      _loadMore(selected_competition);
    }

  }
  Future<List<CompetitionsWidget>>  _getList() async{
    if(loading)
      return null;

    competitionsList.clear();
    loading =  true;

    if(refreshing == false) {
      setState(() {
        state = "progress";
      });
      refreshing =  true;
    }
    // Await the http get response, then decode the json-formatted response.
    var response;
    var statusCode = 200;
    try {
      response = await http.get(apiRest.competitionsList());
    } catch (ex) {
      statusCode = 500;
    }
    if(!loading)
      return null;
    if (statusCode == 200) {
      if (response.statusCode == 200) {
        var jsonData =  convert.jsonDecode(response.body);

        Competition all_competition = Competition(id: 0,selected: true);
        selected_competition =all_competition;
        competitionsList.add(all_competition);

        for(Map i in jsonData){
          Competition competition = Competition.fromJson(i);
          competitionsList.add(competition);
        }
        setState(() {
          state =  "success";
          _getMatchsList(selected_competition);
        });
      } else {
        setState(() {
          state =  "error";
        });
      }
    }else if(statusCode == 500){
      setState(() {
        state =  "error";
      });
    }
    loading = false;
  }

  Future<List<Match>>  _getMatchsList(Competition competition) async{
    setState(() {
      state_matches = "progress";
    });
    matchesList.clear();
    page = 0;
    var response;
    var statusCode = 200;
    try {
      response = await http.get(apiRest.matchesByCompetition(competition.id,page));
    } catch (ex) {
      statusCode = 500;
    }


    if (statusCode == 200) {
      if (response.statusCode == 200) {
        var jsonData =  convert.jsonDecode(response.body);

        for(Map i in jsonData){
          Match competition = Match.fromJson(i);
          matchesList.add(competition);
          insertAds();
        }
        setState(() {
          state_matches = "success";
        });
      } else {
        setState(() {
          state_matches = "error";
        });
      }
    }else if(statusCode == 500){
      setState(() {
        state_matches = "error";
      });
    }
  }

  Widget buildHome() {
    switch(state){
      case "success":
        return RefreshIndicator(
          backgroundColor: Theme.of(context).primaryColor,
          key: refreshKey,
          onRefresh:_getList,
          child: ListView.builder(
            itemCount: 3,
            controller: listViewController,
            itemBuilder: (context, index) {
              if(index== 0){
                return TitleHomeWidget(title : "Matches");
              }else if(index == 1){
                return CompetitionsWidget(competitions : competitionsList,action: selectTables);
              }else{
                switch(state_matches){
                  case "success":
                    return  ListView.builder(
                      shrinkWrap: true,
                      primary: false,
                      itemCount: matchesList.length,
                      itemBuilder: (context, jndex) {
                        if (matchesList[jndex].id == -5){
                          return AdmobNativeAdItem(adUnitID: admob_native_ad_id);
                        }else if (matchesList[jndex].id == -6){
                          return FacebookNativeAdItem(PLACEMENT_ID: facebook_native_ad_id);
                        }else{
                           return  MatchMiniWidget(match :  matchesList[jndex],navigate: navigate);
                        }
                      },
                    );
                    break;
                  case "progress":
                    return Container(child: LoadingWidget(),height: MediaQuery.of(context).size.height/2);
                    break;
                  default:
                    return Container(
                      height: MediaQuery.of(context).size.height/2,
                      child: TryAgainButton(action:(){
                        refreshing = false;
                        _getMatchsList(selected_competition);
                      }),
                    );
                }
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
    return Stack(
      children: [
        buildHome(),
        Positioned(
          left: 0,
          right: 0,
          bottom: 5,
          child: Visibility(
            visible: load_more  ,
            child: Center(
                child: Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [BoxShadow(
                          color: Colors.black,
                          offset: Offset(0,0),
                          blurRadius: 1
                      )]
                  ),
                  height: 35,
                  width: 35,
                  padding: EdgeInsets.all(8),
                  child: CircularProgressIndicator(
                    backgroundColor: Theme.of(context).primaryColor,
                    strokeWidth: 2,
                  ),
                )
            ),
          ),
        )
      ],
    );
  }
  selectTables(Competition competition) {
    setState(() {
      selected_competition = competition;
      _getMatchsList(competition);
      for(Competition c in competitionsList)
        c.selected=false;
        competition.selected=true;


    });
  }

  Future<void>  _loadMore(Competition competition) async{
    if(loading)
      return null;

    loading =  true;

    setState(() {
      load_more = true;
    });

    page +=1;
    // Await the http get response, then decode the json-formatted response.
    var response;
    var statusCode = 200;
    try {
      response = await http.get(apiRest.matchesByCompetition(competition.id,page));
    } catch (ex) {
      statusCode = 500;
    }
    if(!loading)
      return null;
    if (statusCode == 200) {
      if (response.statusCode == 200) {
        var jsonData =  convert.jsonDecode(response.body);

        for(Map i in jsonData){
          Match _match = Match.fromJson(i);
          matchesList.add(_match);

          insertAds();

        }
        setState(() {
          load_more = false;
        });
      } else {
        setState(() {
          load_more = false;
        });
      }
    }else if(statusCode == 500){
      setState(() {
        load_more = false;
      });
    }
    loading = false;
  }

  navigate(Match match,int _tag){
    match_route = MaterialPageRoute(builder: (context) => MatchDetail(match :  match,tag: _tag));

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
        Navigator.push(context, match_route);
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
      Navigator.push(context, match_route);
    }


  }
}







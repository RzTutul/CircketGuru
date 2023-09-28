import 'dart:io';

import 'package:action_broadcast/action_broadcast.dart';
import 'package:app/global_helper.dart';
import 'package:app/model/get_over_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:facebook_audience_network/ad/ad_banner.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:line_icons/line_icons.dart';
import 'package:app/api/api_rest.dart';
import 'package:app/model/event.dart';
import 'package:app/model/match.dart';
import 'package:app/model/statistic.dart';
import 'package:app/model/table.dart' as table;
import 'package:app/provider/ads_provider.dart';
import 'package:app/screens/home/live_widget.dart';
import 'package:app/screens/home/ranking_table_widget.dart';
import 'package:app/screens/loading.dart';
import 'package:app/screens/matches/competitions_widget.dart';
import 'package:app/screens/matches/match_mini_widget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:app/screens/tryagain.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../model/current_match_model.dart';
import '../../model/scoreboard.dart';

class RecentMatchDetails extends StatefulWidget {
  RecentMatch match;
  int tag;
  bool back;

  RecentMatchDetails({this.match, this.tag,this.back = true});

  @override
  _MatchDetailState createState() => _MatchDetailState();
}

class _MatchDetailState extends State<RecentMatchDetails> {
  int selected_index = 0;

  List<RecentMatch> matchesList = [];
  List<Statistic> statisticsList = [];
  ScoreBoardResponse scoreboard;
  GetOverResponse event;
  List<Event> eventsList = [];
  List<table.Table> tablesList = [];

  String state_matches =  "progress";
  String state_scoreboard =  "progress";
  String state_events =  "progress";
  String state_raking =  "progress";
  StreamSubscription receiver;
  Event _notif_event = Event(id: 1,type: "home",name: "name",title: "title",time: "0",subtitle: "subtitle",image: "");
  double event_widget_bottom = -100;

  BannerAd myBanner ;
  Container adContainer = Container(height: 0);
  Widget _currentAd = SizedBox(width: 0.0, height: 0.0);
  AdsProvider adsProvider;
  Timer _timer;

  /* end native ads */


  InterstitialAd _admobInterstitialAd;
  static final AdRequest request = AdRequest();
  Route post_route = null;

  int should_be_displaed= 1;
  int ads_interstitial_click;
  String ads_interstitial_type;

  bool _isInterstitialAdLoaded = false;
  bool _interstitialReady = false;

  String interstitial_facebook_id;
  String interstitial_admob_id;


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

    _timer = Timer.periodic(Duration(seconds: 10), (timer) => _getEvents(widget.match,fromTimer: true));

    _getEvents(widget.match);
    initBannerAds();

    initInterstitialAd();

    receiver = registerReceiver(['matchNotif']).listen((intent){

      var messages = intent.data;
      print('${messages}');

      String type = '${messages["type"]}';
      String event = '${messages["event"]}';
      print(event);


    });

  }

  @override
  void dispose(){
    _timer.cancel();
    receiver.cancel();
    _admobInterstitialAd?.dispose();

    super.dispose();
  }
  void initInterstitialAd() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    adsProvider =  AdsProvider(prefs,(Platform.isAndroid)?TargetPlatform.android:TargetPlatform.iOS);
    should_be_displaed =adsProvider.getInterstitialClicksStep();

    interstitial_admob_id =adsProvider.getAdmobInterstitialId();
    interstitial_facebook_id =adsProvider.getFacebookInterstitialId();
    ads_interstitial_type =adsProvider.getInterstitialType();
    ads_interstitial_click = adsProvider.getInterstitialClicks();

    print(interstitial_admob_id);
    print("interstitial_admob_id");

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
            _admobInterstitialAd.show();
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error.');
            _admobInterstitialAd = null;
            _interstitialReady = false;
            createInterstitialAd();
          },
        ));
  }


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
          if(post_route != null)
            _isInterstitialAdLoaded = false;
          _loadInterstitialAd();
          Navigator.push(context, post_route);
        }
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        (widget.back == true)? Navigator.of(context).pop():Navigator.pushReplacementNamed(context, "/home");
      },
      child: Container(
        color: Theme.of(context).primaryColor,
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Scaffold(
                      appBar: AppBar(
                        backgroundColor: Theme.of(context).primaryColor,
                        centerTitle: false,
                        title: Text(widget.match.matchInfo.team1.teamName + " vs " + widget.match.matchInfo.team2.teamName),
                        elevation: 0,
                        iconTheme: IconThemeData(color: Theme.of(context).textTheme.bodyText1.color),
                        leading: new IconButton(
                          icon: new Icon(LineIcons.angleLeft),
                          onPressed: () => (widget.back == true)? Navigator.of(context).pop():Navigator.pushReplacementNamed(context, "/home"),
                        ),
                        actions: [
                        ],
                      ),
                      body: Container(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  boxShadow: [BoxShadow(
                                      color: Colors.black54.withOpacity(0.2),
                                      offset: Offset(0,0),
                                      blurRadius: 5
                                  )]
                              ),
                              child: Column(
                                children: [
                                  Hero(
                                    tag: "hero_match_"+ widget.match.matchInfo.matchId.toString()+"_"+widget.tag.toString(),
                                    transitionOnUserGestures: true,
                                    child: Material(
                                      type: MaterialType.transparency, // likely needed
                                      child: Container(
                                        height: 130,
                                        child: Stack(
                                          children: [
                                              Positioned(
                                                left: 20,
                                                top: 20,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                    Container(
                                                      margin: EdgeInsets.only(bottom: 10),
                                                      height: 60,
                                                      width: 60,
                                                      decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(10),
                                                          border: Border.all(color: Theme.of(context).accentColor,width: 2)
                                                      ),
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Image.asset(HelperUtils.getFlagFromName(widget.match.matchInfo.team1.teamSName)),
                                                      ),
                                                    ),
                                                    Text(
                                                        widget.match.matchInfo.team1.teamName,
                                                        style: TextStyle(
                                                            color: Theme.of(context).textTheme.bodyText2.color,
                                                            fontSize: 13,
                                                            fontWeight: FontWeight.w700
                                                        )
                                                    ),
                                                       Padding(
                                                         padding: const EdgeInsets.only(top: 8.0),
                                                         child: Text(
                                                             widget.match.matchScore==null?"":widget.match.matchScore.team1Score==null?"":widget.match.matchScore.team1Score.inngs1==null?"":  "${widget.match.matchScore.team1Score.inngs1.runs.toString()}/${widget.match.matchScore.team1Score.inngs1.wickets==null?"0":widget.match.matchScore.team1Score.inngs1.wickets} (${widget.match.matchScore.team1Score.inngs1.overs.toString()})",
                                                          style: TextStyle(
                                                              color: Theme.of(context).textTheme.bodyText2.color,
                                                              fontSize: 13,
                                                              fontWeight: FontWeight.w700
                                                          )
                                                    ),
                                                       )


                                                  ],
                                                ),
                                              ),
                                              Positioned(
                                                  top: 20,
                                                  left: 140,
                                                  right: 140,
                                                  child:  Center(child: buildDetail(context))
                                              ),
                                              Positioned(
                                              right: 20,
                                              top: 20,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  Container(
                                                    margin: EdgeInsets.only(bottom: 10),
                                                    height: 60,
                                                    width: 60,
                                                    decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(10),
                                                        border: Border.all(color: Theme.of(context).accentColor,width: 2)
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Image.asset(HelperUtils.getFlagFromName(widget.match.matchInfo.team2.teamSName)),
                                                    ),
                                                  ),
                                                  Text(
                                                    widget.match.matchInfo.team2.teamName,
                                                    style: TextStyle(
                                                        color: Theme.of(context).textTheme.bodyText2.color,
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.w700
                                                    ),
                                                  ),  Padding(
                                                    padding: const EdgeInsets.only(top: 8.0),
                                                    child: Text(
                                                      widget.match.matchScore==null?"":widget.match.matchScore.team2Score==null?"":widget.match.matchScore.team2Score.inngs1==null?"":  "${widget.match.matchScore.team2Score.inngs1.runs.toString()}/${widget.match.matchScore.team2Score.inngs1.wickets==null?"0":widget.match.matchScore.team2Score.inngs1.wickets} (${widget.match.matchScore.team2Score.inngs1.overs.toString()})",
                                                      style: TextStyle(
                                                          color: Theme.of(context).textTheme.bodyText2.color,
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.w700
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
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    height: 40,
                                    child: ListView(
                                      scrollDirection: Axis.horizontal,
                                      children: [
                                        buildTab("MATCH FACTS",0),
                                        buildTab("SCOREBOARD",1),
                                        //buildTab("COMMENTARY",2),

                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                child: buildContentTab(),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    AnimatedPositioned(
                        bottom:event_widget_bottom,
                        left: 20,
                        right: 20,
                        child: SafeArea(
                          child: Material(
                            color: Colors.transparent,
                            child:Container(
                              height: 65,
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: buildEvent(_notif_event),
                              decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [BoxShadow(
                                      color: Colors.black54.withOpacity(0.2),
                                      offset: Offset(0,0),
                                      blurRadius: 5
                                  )]
                              ),
                            ),
                          ),
                        ),
                        duration: Duration(milliseconds: 250)
                    )
                  ],
                ),
              ),
              adContainer,
              _currentAd
            ],
          ),
        ),
      ),
    );
  }
  buildDetail(BuildContext context) {

    return Text(widget.match.matchInfo.state);
  }


  buildTab(String s,int index) {
    return GestureDetector(
      onTap: (){
        setState(() {
          selected_index = index;
          if(index == 4){
            _getMatchsList(widget.match);
          }
          if(index == 1){
            _getStatistics(widget.match);
          }
          if(index == 3){
            _getTables();
          }

          if(index == 0){
            _getEvents(widget.match);
          }
        });
      },
      child: Container(
        color: Theme.of(context).primaryColor,
        margin: EdgeInsets.only(right: 2),
        padding: EdgeInsets.only(left: 10,right: 10,top: 10),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              s,
              style: TextStyle(
                color: (selected_index == index)? Theme.of(context).textTheme.subtitle1.color:Theme.of(context).textTheme.subtitle2.color.withOpacity(0.5),
                fontSize: 12,
                fontWeight: FontWeight.bold
              ),
            ),
            Visibility(
              visible:(selected_index == index),
              child: Container(
                height: 4,
                width: 65,
                color: Theme.of(context).accentColor,
              ),
            )
          ],
        ),
      ),
    );
  }

  buildContentTab() {
    switch(selected_index){
      case 0:
        return buildInfos();
        break;
      case 1:
        return buildScoreboard();
        break;
      case 2:
        return buildHightlights();
        break;
      case 3:
        return  buildRankingTables();
        break;
      case 4:
        return buildHeadToHead();
        break;
      default:
        return  buildInfos();
        break;
    }
  }

  Widget buildInfos() {
    return Padding(padding: EdgeInsets.symmetric(horizontal: 15),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: 15,bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  SizedBox(width: 5),
                  Text(
                    widget.match.matchInfo.team1.teamName +" - "+widget.match.matchInfo.team2.teamName,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color:  Theme.of(context).textTheme.bodyText2.color
                    ),
                  ),
                ],
              ),
            ),
              Container(
              padding: EdgeInsets.only(bottom: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset("assets/images/stadium.png",color: Theme.of(context).textTheme.bodyText2.color,height: 18,width:18),
                  SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      widget.match.matchInfo.venueInfo.ground,
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyText2.color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                ],
              ),
            ),
              Divider(),
              buildEvents(),

          ],
        ),
      )
    );
  }
  Widget buildScoreboard() {
    switch(state_scoreboard){
      case "success":
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 560,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ListView.builder(
                      itemCount: scoreboard.scoreCard.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context,index){
                        var item = scoreboard.scoreCard[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            //Batting Data
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10.0),
                              child: ExtractHeader(width: 300,title: item.batTeamDetails.batTeamName,fontSize: 20,),
                            ),
                            Row(
                              children: [
                                ExtractHeader(width: 150,title: "Batting",fontSize: 12,),
                                ExtractHeader(width: 150,title: "",fontSize: 12,),
                                SizedBox(
                                  width: 10,
                                ),
                                ExtractHeader(width: 50,title: "R",fontSize: 12,),
                                ExtractHeader(width: 50,title: "B",fontSize: 12,),
                                ExtractHeader(width: 50,title: "4s",fontSize: 12,),
                                ExtractHeader(width: 50,title: "6s",fontSize: 12,),
                                ExtractHeader(width: 50,title: "SR",fontSize: 12,),
                              ],
                            ),

                            ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount:item.batTeamDetails.batsmenData.length,
                                itemBuilder: (context,batIndex){
                                  String key = item.batTeamDetails.batsmenData.keys.elementAt(batIndex);
                                  var batdata = item.batTeamDetails.batsmenData[key];
                                  return Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                                        child: Row(
                                          children: [
                                             SizedBox(
                                      width: 150,
                                                child: Text(batdata.batName)),
                                             SizedBox(
                                      width: 150,
                                                child: Text(batdata.outDesc)),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            SizedBox(
                                                width: 50,
                                                child: Text(batdata.runs==null?"0":batdata.runs.toString())),
                                            SizedBox(
                                                width: 50,
                                                child: Text("${batdata.balls}")),
                                            SizedBox(
                                                width: 50,
                                                child: Text("${batdata.fours}")),
                                            SizedBox(
                                                width: 50,
                                                child: Text("${batdata.sixes}")),
                                            SizedBox(
                                                width: 50,
                                                child: Text("${batdata.strikeRate}")),

                                          ],
                                        ),
                                      ),
                                      Divider(
                                        height: 0.6,
                                      )
                                    ],
                                  );
                            }),


                            //Balling Data

                            Row(
                              children: [
                                ExtractHeader(width: 150,title: "Balling",fontSize: 12,),
                                SizedBox(
                                  width: 10,
                                ),
                                ExtractHeader(width: 50,title: "O",fontSize: 12,),
                                ExtractHeader(width: 50,title: "M",fontSize: 12,),
                                ExtractHeader(width: 50,title: "R",fontSize: 12,),
                                ExtractHeader(width: 50,title: "W",fontSize: 12,),
                                ExtractHeader(width: 50,title: "B",fontSize: 12,),
                              ],
                            ),
                            //Bolwing Data

                            ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount:item.bowlTeamDetails.bowlersData.length,
                                itemBuilder: (context,batIndex){
                                  String key = item.bowlTeamDetails.bowlersData.keys.elementAt(batIndex);
                                  var balldata = item.bowlTeamDetails.bowlersData[key];
                                  return Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                                width: 150,
                                                child: Text(balldata.bowlName)),

                                            SizedBox(
                                              width: 10,
                                            ),
                                            SizedBox(
                                                width: 50,
                                                child: Text(balldata.overs==null?"0":balldata.overs.toString())),
                                            SizedBox(
                                                width: 50,
                                                child: Text("${balldata.maidens}")),
                                            SizedBox(
                                                width: 50,
                                                child: Text("${balldata.runs}")),
                                            SizedBox(
                                                width: 50,
                                                child: Text("${balldata.wickets}")),
                                            SizedBox(
                                                width: 50,
                                                child: Text("${balldata.balls}")),

                                          ],
                                        ),
                                      ),
                                      Divider(
                                        height: 0.6,
                                      )
                                    ],
                                  );
                                })
                          ],
                        );
                  }),
                ],
              ),
            ),
          ),
        );
        break;
      case "progress":
        return Container(child: LoadingWidget(),height: MediaQuery.of(context).size.height/2);
        break;
      default:
        return Container(
          height: MediaQuery.of(context).size.height/2,
          child: TryAgainButton(action:(){
            _getStatistics(widget.match);
          }),
        );
    };
  }
  Widget buildHeadToHead() {
    switch(state_matches){
      case "success":
        return  ListView.builder(
          itemCount: matchesList.length,
          itemBuilder: (context, jndex) {
            return  Container(color: Colors.red,height: 100,width: 1000,);
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
            _getMatchsList(widget.match);
          }),
        );
    }

  }
  Widget buildHightlights() {
    return Column(
      children: [
        GestureDetector(
          onTap: (){
            //_launchURL(widget.match.highlights);
          },
          child: Container(
            margin: EdgeInsets.all(10),
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black,
                gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    stops: [
                      0.6,
                      0.9
                    ],
                    colors: [
                      Colors.black,
                      Theme.of(context).accentColor
                    ]),
              borderRadius: BorderRadius.circular(10)
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 25,
                  left: 15,
                  child: Text(
                    "RecentMatch Hightlights",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                        color:  Colors.white
                    ),
                  ),
                ),
                Positioned(
                  top: 55,
                   left: 15,
                    child: Text(
                      widget.match.matchInfo.team1.teamName,
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color:  Colors.white
                      ),
                    ),
                ),
                Positioned(
                  bottom: 5,
                  right: 5,
                  child: Icon(
                    Icons.play_circle_filled_rounded,
                    color: Colors.white,
                    size: 35,
                  ),
                ),
                Positioned(
                  left: 10,
                  bottom: 10,
                  child:Row(
                    children: [
                      SizedBox(width: 10),
                      Column(
                        children: [
                            Text(
                              widget.match.matchInfo.state,
                              style: TextStyle(
                                  color:Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800
                              ),
                            ),

                        ],
                      ),
                      SizedBox(width: 10),
                    ],
                  )
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
  Future<List<RecentMatch>>  _getMatchsList(RecentMatch match) async{
    setState(() {
      state_matches = "progress";
    });
    matchesList.clear();
    var response;
    var statusCode = 200;
    try {
      response = await http.get(apiRest.matchesByClubs(1,2));
    } catch (ex) {
      statusCode = 500;
    }


    if (statusCode == 200) {
      if (response.statusCode == 200) {
        var jsonData =  convert.jsonDecode(response.body);

        for(Map i in jsonData){
            RecentMatch _match = RecentMatch.fromJson(i as String);
             matchesList.add(_match);
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


  Future<List<RecentMatch>>  _getStatistics(RecentMatch match) async{
    setState(() {
      state_scoreboard = "progress";
    });
    statisticsList.clear();
    var response;
    var statusCode = 200;
    try {
      response = await apiRest.getScoreBoard(match.matchInfo.matchId);
    } catch (ex) {
      statusCode = 500;
    }


    if (statusCode == 200) {
      if (response.statusCode == 200) {
        String responseapi = response.body.toString().replaceAll("\n","");
        debugPrint(responseapi);
        ScoreBoardResponse responsedata =  ScoreBoardResponse.fromJson(responseapi);
        scoreboard = responsedata;

        setState(() {
          state_scoreboard = "success";
        });
      } else {
        setState(() {
          state_scoreboard = "error";
        });
      }
    }else if(statusCode == 500){
      setState(() {
        state_scoreboard = "error";
      });
    }
  }
  Future<List<table.Table>>  _getTables() async{
    setState(() {
      state_raking = "progress";
    });
    tablesList.clear();
    var response;
    var statusCode = 200;
    try {
      response = await http.get(apiRest.tableByCompetition("2"));
    } catch (ex) {
      statusCode = 500;
    }


    if (statusCode == 200) {
      if (response.statusCode == 200) {
        var jsonData =  convert.jsonDecode(response.body);

        for(Map i in jsonData){
          table.Table _table = table.Table.fromJson(i);
          tablesList.add(_table);
        }
        setState(() {
          state_raking = "success";
        });
      } else {
        setState(() {
          state_raking = "error";
        });
      }
    }else if(statusCode == 500){
      setState(() {
        state_raking = "error";
      });
    }
  }
   _getEvents(RecentMatch match,{bool fromTimer=false}) async{
    if(!fromTimer)
      {
        setState(() {
          state_events = "progress";
        });
      }

    eventsList.clear();
    var response;
    var statusCode = 200;
    try {
      response = await apiRest.geMatchOver(match.matchInfo.matchId);
    } catch (ex) {
      statusCode = 500;
    }


    if (statusCode == 200) {
      if (response.statusCode == 200) {
        String responseapi = response.body.toString().replaceAll("\n","");
        debugPrint(responseapi);
        GetOverResponse responsedata =  GetOverResponse.fromJson(responseapi);
        event = responsedata;

        setState(() {
          state_events= "success";
        });
      } else {
        setState(() {
          state_events = "error";
        });
      }
    }else if(statusCode == 500){
      setState(() {
        state_events = "error";
      });
    }
  }

  buildEvents() {
    switch(state_events){
      case "success":
        return   SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 560,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      //Batting Data
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(vertical: 10.0),
                      //   child: ExtractHeader(width: 300,title: item.batTeamDetails.batTeamName,fontSize: 20,),
                      // ),
                      Row(
                        children: [
                          ExtractHeader(width: 150,title: "Batting",fontSize: 12,),
                          SizedBox(
                            width: 10,
                          ),
                          ExtractHeader(width: 50,title: "R",fontSize: 12,),
                          ExtractHeader(width: 50,title: "B",fontSize: 12,),
                          ExtractHeader(width: 50,title: "4s",fontSize: 12,),
                          ExtractHeader(width: 50,title: "6s",fontSize: 12,),
                          ExtractHeader(width: 50,title: "SR",fontSize: 12,),
                        ],
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            SizedBox(
                                width: 150,
                                child: Text(event.batsmanStriker.batName)),
                            SizedBox(
                              width: 10,
                            ),
                            SizedBox(
                                width: 50,
                                child: Text("${event.batsmanStriker.batRuns}")),
                            SizedBox(
                                width: 50,
                                child: Text("${event.batsmanStriker.batBalls}")),
                            SizedBox(
                                width: 50,
                                child: Text("${event.batsmanStriker.batFours}")),
                            SizedBox(
                                width: 50,
                                child: Text("${event.batsmanStriker.batSixes}")),
                            SizedBox(
                                width: 50,
                                child: Text("${event.batsmanStriker.batStrikeRate}")),

                          ],
                        ),
                      ),
                      Divider(
                        height: 0.6,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            SizedBox(
                                width: 150,
                                child: Text(event.batsmanNonStriker.batName)),
                            SizedBox(
                              width: 10,
                            ),
                            SizedBox(
                                width: 50,
                                child: Text("${event.batsmanNonStriker.batRuns}")),
                            SizedBox(
                                width: 50,
                                child: Text("${event.batsmanNonStriker.batBalls}")),
                            SizedBox(
                                width: 50,
                                child: Text("${event.batsmanNonStriker.batFours}")),
                            SizedBox(
                                width: 50,
                                child: Text("${event.batsmanNonStriker.batSixes}")),
                            SizedBox(
                                width: 50,
                                child: Text("${event.batsmanNonStriker.batStrikeRate}")),

                          ],
                        ),
                      ),

                      SizedBox(
                        height: 20,
                      ),

                      //Balling Data

                      Row(
                        children: [
                          ExtractHeader(width: 150,title: "Balling",fontSize: 12,),
                          SizedBox(
                            width: 10,
                          ),
                          ExtractHeader(width: 50,title: "O",fontSize: 12,),
                          ExtractHeader(width: 50,title: "M",fontSize: 12,),
                          ExtractHeader(width: 50,title: "R",fontSize: 12,),
                          ExtractHeader(width: 50,title: "W",fontSize: 12,),
                        ],
                      ),
                      //Bolwing Data
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            SizedBox(
                                width: 150,
                                child: Text(event.bowlerStriker.bowlName)),

                            SizedBox(
                              width: 10,
                            ),
                            SizedBox(
                                width: 50,
                                child: Text("${event.bowlerStriker.bowlOvs}")),
                            SizedBox(
                                width: 50,
                                child: Text("${event.bowlerStriker.bowlMaidens}")),
                            SizedBox(
                                width: 50,
                                child: Text("${event.bowlerStriker.bowlRuns}")),
                            SizedBox(
                                width: 50,
                                child: Text("${event.bowlerStriker.bowlWkts}")),


                          ],
                        ),
                      ),
                      Divider(
                        height: 0.6,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            SizedBox(
                                width: 150,
                                child: Text(event.bowlerNonStriker.bowlName)),

                            SizedBox(
                              width: 10,
                            ),
                            SizedBox(
                                width: 50,
                                child: Text("${event.bowlerNonStriker.bowlOvs}")),
                            SizedBox(
                                width: 50,
                                child: Text("${event.bowlerNonStriker.bowlMaidens}")),
                            SizedBox(
                                width: 50,
                                child: Text("${event.bowlerNonStriker.bowlRuns}")),
                            SizedBox(
                                width: 50,
                                child: Text("${event.bowlerNonStriker.bowlWkts}")),


                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(top: 15.0),
                        child: Text("Last Wicket",style: TextStyle(fontStyle: FontStyle.italic,fontWeight: FontWeight.w700),),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: SizedBox(
                            width: 300,
                            child: Text("${event.lastWicket}")),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );

        break;
      case "progress":
        return Container(child: LoadingWidget(),height: MediaQuery.of(context).size.height/2);
        break;
      default:
        return Container(
          height: MediaQuery.of(context).size.height/2,
          child: TryAgainButton(action:(){
            _getEvents(widget.match);
          }),
        );
    };
  }
  _launchURL(String url) async {

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  buildRankingTables() {
    switch(state_raking){
      case "success":
        return  RefreshIndicator(
          onRefresh: _getTables,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: tablesList.length,
            itemBuilder: (context, jndex) {
              return  RankingTable(table : tablesList[jndex]);
            },
          ),
        );;
        break;
      case "progress":
        return Container(child: LoadingWidget(),height: MediaQuery.of(context).size.height/2);
        break;
      default:
        return Container(
          height: MediaQuery.of(context).size.height/2,
          child: TryAgainButton(action:(){
            _getTables();
          }),
        );
    }
  }

  Widget buildHomeEvent(Event event) {
    return Container(
      margin: EdgeInsets.only(bottom: 3,top: 3),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            child: Center(
              child: Text(
                event.time,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800
                ),
              ),
            ),
          ),
          Container(
            height: 40,
            width: 40,
            padding: EdgeInsets.all(9),
            child: CachedNetworkImage(imageUrl:event.image,height: 22,width: 22,),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 40,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: TextStyle(
                        color: Theme
                            .of(context)
                            .textTheme
                            .subtitle1
                            .color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  if(event.subtitle != null &&
                      event.subtitle != "" && event.subtitle != "null")
                    SizedBox(height: 2),
                  if(event.subtitle != null &&
                      event.subtitle != "" && event.subtitle != "null")
                    Text(
                      event.subtitle,
                      style: TextStyle(
                          color: Theme
                              .of(context)
                              .textTheme
                              .subtitle2
                              .color,
                          fontSize: 12

                      ),
                    ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
  Widget buildAwayEvent(Event event) {
    return Container(
      margin: EdgeInsets.only(bottom: 3,top: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [

          Expanded(
            child: Container(
              height: 40,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    event.title,
                    style: TextStyle(
                        color: Theme
                            .of(context)
                            .textTheme
                            .subtitle1
                            .color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  if(event.subtitle != null &&
                      event.subtitle != "" && event.subtitle != "null")
                    SizedBox(height: 2),
                  if(event.subtitle != null &&
                      event.subtitle != "" && event.subtitle != "null")
                    Text(
                      event.subtitle,
                      style: TextStyle(
                          color: Theme
                              .of(context)
                              .textTheme
                              .subtitle2
                              .color,
                          fontSize: 12

                      ),
                    ),

                ],
              ),
            ),
          ),
          SizedBox(width: 10),

          Container(
            height: 40,
            width: 40,
            padding: EdgeInsets.all(9),
            child: CachedNetworkImage(imageUrl:event.image,height: 22,width: 22,),
          ),
          Container(
            height: 40,
            width: 40,
            child: Center(
              child: Text(
                event.time,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget buildMatchEvent(Event event) {
    return Container(
      margin: EdgeInsets.only(bottom: 3,top: 3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.only(left:10),

            decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(10),bottomLeft: Radius.circular(10))
            ),
            height: 30,
            child: Center(
              child: Text(
                event.time,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 5,bottom: 5),

            color: Theme.of(context).cardColor,
            height: 30,
            width: 40,
            padding: EdgeInsets.all(5),
            child: CachedNetworkImage(imageUrl:event.image,height: 22,width: 22,),
          ),
          Container(
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.only(topRight: Radius.circular(10),bottomRight: Radius.circular(10))
            ),
            height: 30,
            padding: EdgeInsets.only(right: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: TextStyle(
                      color: Theme
                          .of(context)
                          .textTheme
                          .subtitle1
                          .color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold
                  ),
                ),
                if(event.subtitle != null &&
                    event.subtitle != "" && event.subtitle != "null")
                  SizedBox(height: 2),
                if(event.subtitle != null &&
                    event.subtitle != "" && event.subtitle != "null")
                  Text(
                    event.subtitle,
                    style: TextStyle(
                        color: Theme
                            .of(context)
                            .textTheme
                            .subtitle2
                            .color,
                        fontSize: 12

                    ),
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }

  buildEvent(Event event) {
    switch(event.type ) {
      case "home":
        return buildHomeEvent(event);
        break;
      case "away":
        return buildAwayEvent(event);
        break;
      default:
        return buildMatchEvent(event);
        break;
    }
  }
  navigate(RecentMatch match,int _tag){
    Route match_route = MaterialPageRoute(builder: (context) => RecentMatchDetails(match :  match,tag: _tag));
    Navigator.push(context, match_route);
  }
}

class ExtractHeader extends StatelessWidget {
   ExtractHeader({
    Key key,
    this.width,
    this.title,
    this.fontSize
  }) : super(key: key);
double width;
final title;
double fontSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: width,
        child: Text(title, style: TextStyle(
          color: Colors.redAccent,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
        ),));
  }
}


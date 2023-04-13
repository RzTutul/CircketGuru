import 'dart:io';

import 'package:action_broadcast/action_broadcast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:facebook_audience_network/ad/ad_banner.dart';
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

class MatchDetail extends StatefulWidget {
  Match match;
  int tag;
  bool back;

  MatchDetail({this.match, this.tag,this.back = true});

  @override
  _MatchDetailState createState() => _MatchDetailState();
}

class _MatchDetailState extends State<MatchDetail> {
  int selected_index = 0;

  List<Match> matchesList = [];
  List<Statistic> statisticsList = [];
  List<Event> eventsList = [];
  List<table.Table> tablesList = [];

  String state_matches =  "progress";
  String state_statistics =  "progress";
  String state_events =  "progress";
  String state_raking =  "progress";
  StreamSubscription receiver;
  Event _notif_event = Event(id: 1,type: "home",name: "name",title: "title",time: "0",subtitle: "subtitle",image: "");
  double event_widget_bottom = -100;

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
    _getEvents();
    Future.delayed(Duration(milliseconds: 500), () {
      initBannerAds();
    });
    receiver = registerReceiver(['matchNotif']).listen((intent){

      var messages = intent.data;
      print('${messages}');

      String type = '${messages["type"]}';
      String event = '${messages["event"]}';
      print(event);

      if(type == "match"){
        String id = '${messages["id"]}';
        if(id.toString()  ==  widget.match.id.toString()){
          if(event  != "yes"){

            String club_home_result = '${messages["club_home_result"]}';
            String club_away_result = '${messages["club_away_result"]}';
            String club_away_sub_result = '${messages["club_away_sub_result"]}';
            String club_home_sub_result = '${messages["club_home_sub_result"]}';
            setState(() {
              if(club_home_result != null && club_home_result != "null")
                widget.match.homeresult = club_home_result;
              if(club_away_result != null && club_away_result != "null")
                widget.match.awayresult = club_away_result;
              if(club_away_sub_result != null && club_away_sub_result != "null")
                widget.match.awaysubresult = club_away_sub_result;
              if(club_home_sub_result != null && club_home_sub_result != "null")
                widget.match.homesubresult = club_home_sub_result;
            });
          }else{



              String event_id = '${messages["event_id"]}';
              String event_name = '${messages["event_name"]}';
              String event_image = '${messages["event_image"]}';
              String event_title = '${messages["event_title"]}';
              String event_subtitle = '${messages["event_subtitle"]}';
              String event_time = '${messages["event_time"]}';
              String event_type = '${messages["event_type"]}';


             setState(() {
               _notif_event  =  Event(id: int.parse(event_id),name: event_name,image: event_image,time: event_time,subtitle: event_subtitle,title: event_title,type: event_type);
               event_widget_bottom = 20;

             });
              Future.delayed(const Duration(milliseconds: 7000), () {
                 setState(() {
                   if(eventsList != null) {
                     event_widget_bottom = -100;
                     bool notexist = false;
                     for (Event envt in eventsList) {
                       if (envt.id == _notif_event.id) {
                         notexist = true;
                       }
                     }
                     if (notexist == false)
                       eventsList.add(_notif_event);
                   }
                 });
              });
          }
        }
      }
    });

  }

  @override
  void dispose(){
    receiver.cancel();
    super.dispose();
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
                        title: Text(widget.match.homeclub.name + " vs " + widget.match.awayclub.name),
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
                                    tag: "hero_match_"+ widget.match.id.toString()+"_"+widget.tag.toString(),
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
                                                        child: CachedNetworkImage(imageUrl: widget.match.homeclub.image),
                                                      ),
                                                    ),
                                                    Text(
                                                        widget.match.homeclub.name,
                                                        style: TextStyle(
                                                            color: Theme.of(context).textTheme.bodyText2.color,
                                                            fontSize: 12,
                                                            fontWeight: FontWeight.w400
                                                        )
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
                                                      child: CachedNetworkImage(imageUrl: widget.match.awayclub.image),
                                                    ),
                                                  ),
                                                  Text(
                                                    widget.match.awayclub.name,
                                                    style: TextStyle(
                                                        color: Theme.of(context).textTheme.bodyText2.color,
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w400
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 40,
                                    child: ListView(
                                      scrollDirection: Axis.horizontal,
                                      children: [
                                        buildTab("MATCH FACTS",0),
                                        buildTab("STATISTICS",1),
                                        if(widget.match.highlights != null)
                                        buildTab("HIGHLIGHTS",2),
                                        buildTab("RANKING",3),
                                        buildTab("HEAD TO HEAD",4),
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
    switch(widget.match.state){
      case "playing":
        return buildPlaying(context);
        break;
      case "programmed":
        return buildProgrammed(context);
        break;
      case "ended":
        return buildEnded(context);
        break;
      case "postponed":
        return buildPostponed(context);
        break;
      case "canceled":
        return buildCanceled(context);
        break;
    }
  }

  buildEnded(BuildContext context){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if(widget.match.homeresult!= null && widget.match.awayresult != null)
          Text(
            widget.match.homeresult + " - "+widget.match.awayresult,
            style: TextStyle(
                color: Theme.of(context).textTheme.bodyText1.color,
                fontSize: 16,
                fontWeight: FontWeight.w800
            ),
          ),
        if(widget.match.homesubresult!= null && widget.match.awaysubresult != null)
          Text(
            widget.match.homesubresult + " - "+widget.match.awaysubresult,
            style: TextStyle(
                color: Theme.of(context).textTheme.bodyText2.color,
                fontSize: 12,
                fontWeight: FontWeight.w800
            ),
          ),
        SizedBox(
            height: 10),
        SizedBox(
          height: 10,
          width: 100,
          child: Divider(),
        ),
        if(widget.match.highlights != null)
          TextButton.icon(
              style: TextButton.styleFrom(
                  padding: EdgeInsets.all(5),
                  textStyle: TextStyle(
                    color: Theme.of(context).accentColor,
                  )
              ),
              onPressed: (){
                _launchURL(widget.match.highlights);
              },
              icon: Icon(LineIcons.play,size: 11,color: Colors.white),
              label: Text("Highlights",
                style: TextStyle
                  (
                  color: Colors.white,
                    fontSize: 11
                ),
              )
          )
        else
          Padding(
            padding: const EdgeInsets.only(top:8.0),
            child: Text(
              widget.match.time + widget.match.date,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyText1.color,
                fontWeight: FontWeight.w500,
                fontSize: 10,
              ),
            ),
          ),
      ],
    );
  }
  buildPlaying(BuildContext context){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if(widget.match.homeresult!= null && widget.match.awayresult != null)
          Text(
            widget.match.homeresult + " - "+widget.match.awayresult,
            style: TextStyle(
                color: Theme.of(context).textTheme.bodyText1.color,
                fontSize: 16,
                fontWeight: FontWeight.w800
            ),
          ),
        SizedBox(height: 5),
        if(widget.match.homesubresult!= null && widget.match.awaysubresult != null)
          Text(
            widget.match.homesubresult + " - "+widget.match.awaysubresult,
            style: TextStyle(
                color: Theme.of(context).textTheme.bodyText2.color,
                fontSize: 13,
                fontWeight: FontWeight.w800
            ),
          ),
        SizedBox(height: 5),
        Wrap(
          direction: Axis.vertical,
          children: <Widget>[
            Container(
              height: 50,
              child: LiveWidget(),
            )
          ],
        ),
      ],
    );
  }
  buildProgrammed(BuildContext context){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(height: 15),
        Text(
          widget.match.time,
          style: TextStyle(
              color: Theme.of(context).accentColor,
              fontWeight: FontWeight.w900,
              fontSize: 25
          ),
        ),
        SizedBox(height: 5),
        Text(
          widget.match.date,
          style: TextStyle(
              color: Theme.of(context).textTheme.bodyText1.color,
              fontWeight: FontWeight.w500,
              fontSize: 11
          ),
        ),

      ],
    );
  }
  buildCanceled(BuildContext context){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(height: 5),
        Text(
          "Canceled",
          style: TextStyle(
            color: Theme.of(context).accentColor,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        Text(
          widget.match.time,
          style: TextStyle(
              color: Theme.of(context).accentColor,
              fontWeight: FontWeight.w900,
              fontSize: 15,
              decoration: TextDecoration.lineThrough
          ),
        ),
        SizedBox(height: 5),
        Text(
          widget.match.date,
          style: TextStyle(
              color: Theme.of(context).textTheme.bodyText1.color,
              fontWeight: FontWeight.w500,
              fontSize: 11,
              decoration: TextDecoration.lineThrough
          ),
        ),
        SizedBox(height: 5),
        if(widget.match.stadium != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/stadium.png",color: Theme.of(context).textTheme.bodyText2.color,height: 18,width:18),
              SizedBox(width: 5),
              Flexible(
                child: Text(
                  widget.match.stadium,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyText2.color,
                      fontWeight: FontWeight.w500,
                      fontSize: 11
                  ),
                ),
              )
            ],
          )
      ],
    );
  }
  buildPostponed(BuildContext context){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(height: 5),
        Text(
          "Postponed",
          style: TextStyle(
            color: Theme.of(context).accentColor,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 5),
        Text(
          widget.match.time,
          style: TextStyle(
              color: Theme.of(context).accentColor,
              fontWeight: FontWeight.w900,
              fontSize: 15,
              decoration: TextDecoration.lineThrough
          ),
        ),
        SizedBox(height: 5),
        Text(
          widget.match.date,
          style: TextStyle(
              color: Theme.of(context).textTheme.bodyText1.color,
              fontWeight: FontWeight.w500,
              fontSize: 11,
              decoration: TextDecoration.lineThrough
          ),
        ),
      ],
    );
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
            _getEvents();
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
        return buildStats();
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
      child: RefreshIndicator(
        onRefresh: _getEvents,
        child: ListView(
          children: [
            Container(
              padding: EdgeInsets.only(top: 15,bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  CachedNetworkImage(imageUrl: widget.match.competition.image,color: Theme.of(context).textTheme.bodyText2.color,height: 20,width: 20),
                  SizedBox(width: 5),
                  Text(
                    widget.match.competition.name +" - "+widget.match.title,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color:  Theme.of(context).textTheme.bodyText2.color
                    ),
                  ),
                ],
              ),
            ),
            if(widget.match.stadium != null)
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
                      widget.match.stadium,
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
  Widget buildStats() {
    switch(state_statistics){
      case "success":
        return  ListView.builder(
          itemCount: statisticsList.length,
          itemBuilder: (context, jndex) {
            return  Container(
              padding: EdgeInsets.symmetric(horizontal: 20,vertical: 17),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: (int.parse(statisticsList[jndex].away.replaceAll(new RegExp(r'[^0-9]'),'')) < int.parse(statisticsList[jndex].home.replaceAll(new RegExp(r'[^0-9]'),'')) )? Colors.blueAccent.withOpacity(0.2):Colors.transparent,
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: Text(
                      statisticsList[jndex].home,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16
                      ),
                    ),
                  ),
                  Text(
                    statisticsList[jndex].name,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        color: (int.parse(statisticsList[jndex].away.replaceAll(new RegExp(r'[^0-9]'),'')) > int.parse(statisticsList[jndex].home.replaceAll(new RegExp(r'[^0-9]'),'')) )? Colors.red.withOpacity(0.2):Colors.transparent,
                        borderRadius: BorderRadius.circular(5)
                    ),
                    child: Text(
                      statisticsList[jndex].away,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16
                      ),
                    ),
                  ),
                ],
              ),
            );
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
            return  MatchMiniWidget(match :  matchesList[jndex],navigate: navigate);
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
            _launchURL(widget.match.highlights);
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
                    "Match Hightlights",
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
                      widget.match.competition.name +" - "+widget.match.title,
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color:  Colors.white
                      ),
                    ),
                ),
                Positioned(
                  right: 15,
                  top: 15,
                  bottom: 15,
                  child: CachedNetworkImage(imageUrl: widget.match.competition.image,color: Colors.white.withOpacity(0.2)),
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
                      CachedNetworkImage(imageUrl: widget.match.homeclub.image,height: 60,width: 60),
                      SizedBox(width: 10),
                      Column(
                        children: [
                          if(widget.match.homeresult!= null && widget.match.awayresult != null)
                            Text(
                              widget.match.homeresult + " - "+widget.match.awayresult,
                              style: TextStyle(
                                  color:Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800
                              ),
                            ),
                          if(widget.match.homesubresult!= null && widget.match.awaysubresult != null)
                            Text(
                              widget.match.homesubresult + " - "+widget.match.awaysubresult,
                              style: TextStyle(
                                  color:Colors.white70,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800
                              ),
                            ),
                        ],
                      ),
                      SizedBox(width: 10),
                      CachedNetworkImage(imageUrl: widget.match.awayclub.image,height: 60,width: 60)
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
  Future<List<Match>>  _getMatchsList(Match match) async{
    setState(() {
      state_matches = "progress";
    });
    matchesList.clear();
    var response;
    var statusCode = 200;
    try {
      response = await http.get(apiRest.matchesByClubs(match.homeclub.id,match.awayclub.id));
    } catch (ex) {
      statusCode = 500;
    }


    if (statusCode == 200) {
      if (response.statusCode == 200) {
        var jsonData =  convert.jsonDecode(response.body);

        for(Map i in jsonData){
            Match _match = Match.fromJson(i);
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


  Future<List<Match>>  _getStatistics(Match match) async{
    setState(() {
      state_statistics = "progress";
    });
    statisticsList.clear();
    var response;
    var statusCode = 200;
    try {
      response = await http.get(apiRest.matchStatistics(match.id));
    } catch (ex) {
      statusCode = 500;
    }


    if (statusCode == 200) {
      if (response.statusCode == 200) {
        var jsonData =  convert.jsonDecode(response.body);

        for(Map i in jsonData){
          Statistic _statistic = Statistic.fromJson(i);
          statisticsList.add(_statistic);
        }
        setState(() {
          state_statistics = "success";
        });
      } else {
        setState(() {
          state_statistics = "error";
        });
      }
    }else if(statusCode == 500){
      setState(() {
        state_statistics = "error";
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
      response = await http.get(apiRest.tableByCompetition(widget.match.competition.id.toString()));
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
  Future<List<Match>>  _getEvents() async{
    setState(() {
      state_events = "progress";
    });
    eventsList.clear();
    var response;
    var statusCode = 200;
    try {
      response = await http.get(apiRest.matchEvents(widget.match.id));
    } catch (ex) {
      statusCode = 500;
    }


    if (statusCode == 200) {
      if (response.statusCode == 200) {
        var jsonData =  convert.jsonDecode(response.body);

        for(Map i in jsonData){
          Event _event = Event.fromJson(i);
          eventsList.add(_event);
        }
        setState(() {
          state_events = "success";
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
        return  ListView.builder(
          shrinkWrap: true,
          primary: false,
          reverse: true,
          itemCount: eventsList.length,
          itemBuilder: (context, jndex) {
           return buildEvent(eventsList[jndex]);
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
            _getEvents();
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
  navigate(Match match,int _tag){
    Route match_route = MaterialPageRoute(builder: (context) => MatchDetail(match :  match,tag: _tag));
    Navigator.push(context, match_route);
  }
}


import 'dart:convert';
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

import '../../../model/live_line_response.dart';

class MatchDetailV2 extends StatefulWidget {
  String matchid;
  String match;
  int tag;
  bool back;

  MatchDetailV2({this.matchid, this.match, this.tag, this.back = true});

  @override
  _MatchDetailV2State createState() => _MatchDetailV2State();
}

class _MatchDetailV2State extends State<MatchDetailV2> {
  int selected_index = 0;

  List<Match> matchesList = [];
  List<Statistic> statisticsList = [];
  List<Event> eventsList = [];
  List<table.Table> tablesList = [];

  String state_matches = "progress";
  String state_statistics = "progress";
  String state_events = "progress";
  String state_raking = "progress";
  StreamSubscription receiver;
  Event _notif_event = Event(
      id: 1,
      type: "home",
      name: "name",
      title: "title",
      time: "0",
      subtitle: "subtitle",
      image: "");
  double event_widget_bottom = -100;

  BannerAd myBanner;
  Container adContainer = Container(height: 0);
  Widget _currentAd = SizedBox(width: 0.0, height: 0.0);
  AdsProvider adsProvider;

  initBannerAds() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    adsProvider = AdsProvider(prefs,
        (Platform.isAndroid) ? TargetPlatform.android : TargetPlatform.iOS);
    print(adsProvider.getBannerType());
    if (adsProvider.getBannerType() == "ADMOB") {
      showAdmobBanner();
    } else if (adsProvider.getBannerType() == "FACEBOOK") {
      showFacebookBanner();
    } else if (adsProvider.getBannerType() == "BOTH") {
      if (adsProvider.getBannerLocal() == "FACEBOOK") {
        adsProvider.setBannerLocal("ADMOB");
        showFacebookBanner();
      } else {
        adsProvider.setBannerLocal("FACEBOOK");
        showAdmobBanner();
      }
    }
  }

  showFacebookBanner() {
    String banner_fan_id = adsProvider.getBannerFacebookId();
    print("banner_fan_id : " + banner_fan_id);
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

  showAdmobBanner() {
    String banner_admob_id = adsProvider.getBannerAdmobId();
    myBanner = BannerAd(
      adUnitId: banner_admob_id,
      size: AdSize.fullBanner,
      request: AdRequest(),
      listener: BannerAdListener(
          onAdLoaded: (Ad ad) => print('Ad loaded.'),
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            ad.dispose();
            print('Ad failed to load: $error');
          }),
    );
    myBanner.load();
    AdWidget adWidget = AdWidget(ad: myBanner);
    setState(() {
      adContainer = Container(
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
  void dispose() {
    receiver.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black26,
          title: Text(widget.match),
          bottom: TabBar(
            indicatorColor: Colors.red,
            isScrollable: false,
            tabs: [
              Tab(
                icon: Icon(Icons.live_tv),
                text: "Info",
              ),
              Tab(
                icon: Icon(Icons.scoreboard_rounded),
                text: "Score",
              ),
              Tab(
                icon: Icon(Icons.auto_graph),
                text: "Match Odds",
              ),
              Tab(
                icon: Icon(Icons.info_outline),
                text: "Stats",
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            InfoMatch(widget.matchid),
            InfoMatch(widget.matchid),
            InfoMatch(widget.matchid),
            InfoMatch(widget.matchid),
          ],
        ),
      ),
    );
  }
}

class InfoMatch extends StatefulWidget {
  InfoMatch(this.matchId);
  final String matchId;
  @override
  State<InfoMatch> createState() => _InfoMatchState();
}

class _InfoMatchState extends State<InfoMatch> {
  List<MatchLiveData> matchesList = [];
  String state_matches = "progress";
  Timer _timer;


  void _startTimer() {
    // Create a timer that fires every second
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      // Make your API call here
      _getMatchDetails();
    });
  }

  _getMatchDetails() async {
    var response;
    var statusCode = 200;
    try {
      response = await apiRest.getMatchDetails(widget.matchId);
    } catch (ex) {
      print("exfdsf");
      print(ex);
      statusCode = 500;
    }
    if (statusCode == 200) {
      if (response.statusCode == 200) {
        String responseapi =
            response.body.toString().replaceAll("\n", "").replaceAll("\$", "");
        print(responseapi);
        List<dynamic> data = jsonDecode(responseapi);
        matchesList = data.map((json) => MatchLiveData.fromMap(json)).toList();
        setState(() {
          state_matches = "success";
        });
      } else {
        setState(() {
          state_matches = "error";
        });
      }
    } else if (statusCode == 500) {
      setState(() {
        state_matches = "error";
      });
    }
  }

  Color _getColor(String ball) {
    if (ball == "6") {
      return Colors.green;
    } else if (ball == "4") {
      return Colors.blue;
    } else if (ball == "W") {
      return Colors.red;
    } else {
      return Colors.grey.shade100;
    }
  }

  Color _getTextColor(String ball) {
    if (ball == "W") {
      return Colors.white;
    } else {
      return Colors.black;
    }
  }

  getStr(String title)
  {
    if (title.contains("C.RR")) {
      String str3, str4;
      List<String> split1 = title.split("C.RR");
      if (split1.length > 1) {
        List<String> split2 = split1[1].split("R.RR");
        str3 = split2[0].replaceAll(":", "").replaceAll(",", "").trim();
        str4 = (split2.length > 1 && split2[1] != null) ? split2[1].replaceAll(":", "").replaceAll(",", "").trim() : "";

        // Displaying the values
        print("C.R.R : $str3");
        print("R.R.R : $str4");
      }
    }
  }

  @override
  void initState() {
    _getMatchDetails();
    _startTimer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    switch (state_matches) {
      case "success":
        Map<String, dynamic> matchData =
            jsonDecode(matchesList[0].jsondata.toString().replaceAll("\n", ""));
        String teamABanner = matchData['jsondata']['TeamABanner'];
        String teamBBanner = matchData['jsondata']['TeamBBanner'];

        String teamA = matchData['jsondata']['teamA'];
        String teamB = matchData['jsondata']['teamB'];

        String wicketA = matchData['jsondata']['wicketA'];
        String wicketB = matchData['jsondata']['wicketB'];
        String bowler = matchData['jsondata']['bowler'];
        String matchId = matchData['jsondata']['MatchId'];
        String imgeUrl = matchData['jsondata']['imgurl'];
        String title = matchData['jsondata']['title'];
        String score = matchData['jsondata']['score'];
        String overA = matchData['jsondata']['oversA'];
        List<String> balls = matchData['jsondata']['Last6Balls'].split("-");
        String str3, str4;
        if (title.contains("C.RR")) {
    
          List<String> split1 = title.split("C.RR");
          if (split1.length > 1) {
            List<String> split2 = split1[1].split("R.RR");
            str3 = split2[0].replaceAll(":", "").replaceAll(",", "").trim();
            str4 = (split2.length > 1 && split2[1] != null) ? split2[1].replaceAll(":", "").replaceAll(",", "").trim() : "";

            // Displaying the values
            print("C.R.R : $str3");
            print("R.R.R : $str4");
          }
        }
        return ListView(children: [
          Container(
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black54.withOpacity(0.3),
                      offset: Offset(0, 0),
                      blurRadius: 5)
                ]),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CachedNetworkImage(
                              imageUrl: "${imgeUrl}${teamABanner}",
                              errorWidget: (context, url, error) => Icon(
                                LineIcons.image,
                                size: 50,
                              ),
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                width: 50.0,
                                height: 50.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      image: imageProvider, fit: BoxFit.cover),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                teamA,
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .color,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Text(
                              wicketA,
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .color,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                        flex: 1,
                        child: Image.asset(
                          "assets/images/vs.png",
                          width: 50,
                          height: 50,
                        )),
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            CachedNetworkImage(
                              imageUrl: "${imgeUrl}${teamBBanner}",
                              errorWidget: (context, url, error) => Icon(
                                LineIcons.image,
                                size: 50,
                              ),
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                width: 50.0,
                                height: 50.0,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      image: imageProvider, fit: BoxFit.cover),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                teamB,
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .color,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Text(
                              wicketB,
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .color,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  width: double.infinity,
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10))),
                  child: Column(
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Batting',
                              style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CachedNetworkImage(
                                      imageUrl: "${imgeUrl}${teamABanner}",
                                      errorWidget: (context, url, error) => Icon(
                                        LineIcons.image,
                                        size: 50,
                                      ),
                                      imageBuilder: (context, imageProvider) =>
                                          Container(
                                        width: 50.0,
                                        height: 50.0,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.cover),
                                        ),
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          wicketA,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 23,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 3.0),
                                          child: Text(
                                            overA,
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    teamA,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                // Text(
                                //   score,
                                //   style: TextStyle(
                                //       color: Colors.black,
                                //       fontSize: 17,
                                //       fontWeight: FontWeight.bold),
                                // ),
                                //   Text(
                                //   str3,
                                //   style: TextStyle(
                                //       color: Colors.black,
                                //       fontSize: 17,
                                //       fontWeight: FontWeight.bold),
                                // ),
                                //   Text(
                                //   str4,
                                //   style: TextStyle(
                                //       color: Colors.black,
                                //       fontSize: 17,
                                //       fontWeight: FontWeight.bold),
                                // ),


                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(10.0),
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.grey[200],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          "Last 6 Balls",
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: balls.map((ball) {
                          return Expanded(
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(8.0),
                              decoration: ShapeDecoration(
                                color: _getColor(ball),
                                shape: CircleBorder(),
                              ),
                              child: Text(
                                ball,
                                style: TextStyle(
                                  color: _getTextColor(ball),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  width: double.infinity,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10))),
                  child: Text(
                    title,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          )
        ]);
        break;
      case "progress":
        return Container(
            child: LoadingWidget(),
            height: MediaQuery.of(context).size.height / 2);
        break;
      default:
        return Container(
          height: MediaQuery.of(context).size.height / 2,
          child: TryAgainButton(action: () {
            _getMatchDetails();
          }),
        );
    }
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app/api/api_rest.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:facebook_audience_network/ad/ad_interstitial.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:line_icons/line_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../global_helper.dart';
import '../../../../model/live_line_response.dart';
import '../../../../provider/ads_provider.dart';
import '../../../loading.dart';
import '../../../tryagain.dart';

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
  bool isSpeak = true;


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

  int should_be_displaed = 1;
  int ads_interstitial_click;
  String ads_interstitial_type;

  bool _isInterstitialAdLoaded = false;
  bool _interstitialReady = false;

  String interstitial_facebook_id;
  String interstitial_admob_id;

  void _loadInterstitialAd() {
    FacebookInterstitialAd.destroyInterstitialAd();
    FacebookInterstitialAd.loadInterstitialAd(
      placementId: interstitial_facebook_id,
      listener: (result, value) {
        print(">> FAN > Interstitial Ad: $result --> $value");
        if (result == InterstitialAdResult.LOADED) {
          _isInterstitialAdLoaded = true;
        }
        if (result == InterstitialAdResult.ERROR) {}

        /// Once an Interstitial Ad has been dismissed and becomes invalidated,
        /// load a fresh Ad by calling this function.
        if (result == InterstitialAdResult.DISMISSED) {
          if (match_route != null) Navigator.push(context, match_route);
          _isInterstitialAdLoaded = false;
          _loadInterstitialAd();
        }
      },
    );
  }

  void initInterstitialAd() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    adsProvider = AdsProvider(prefs,
        (Platform.isAndroid) ? TargetPlatform.android : TargetPlatform.iOS);
    should_be_displaed = adsProvider.getInterstitialClicksStep();

    interstitial_admob_id = adsProvider.getAdmobInterstitialId();
    interstitial_facebook_id = adsProvider.getFacebookInterstitialId();
    ads_interstitial_type = adsProvider.getInterstitialType();
    ads_interstitial_click = adsProvider.getInterstitialClicks();

    if (ads_interstitial_type == "ADMOB") {
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
    } else if (ads_interstitial_type == "FACEBOOK") {
      FacebookAudienceNetwork.init();
      _loadInterstitialAd();
    } else if (ads_interstitial_type == "BOTH") {
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

  void initNativeAd() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    adsProvider = AdsProvider(prefs,
        (Platform.isAndroid) ? TargetPlatform.android : TargetPlatform.iOS);
    facebook_native_ad_id = await adsProvider.getNativeFacebookId();
    admob_native_ad_id = await adsProvider.getNativeAdmobId();
    native_ads_type = await adsProvider.getNativeType();
    native_ads_item = await adsProvider.getNativeItem();
  }

  void insertAds() {
    if (native_ads_position == native_ads_item) {
      native_ads_position = 0;
      if (native_ads_type == "ADMOB") {
        // matchesList.add(EMatch(id:"-5"));
      } else if (native_ads_type == "FACEBOOK") {
        // matchesList.add(EMatch(id:"-6"));
      } else if (native_ads_type == "BOTH") {
        if (native_ads_current_type == "ADMOB") {
          //matchesList.add(EMatch(id:"-5"));
          native_ads_current_type = "FACEBOOK";
        } else {
          // matchesList.add(EMatch(id:"-6"));
          native_ads_current_type = "ADMOB";
        }
      }
    }
    native_ads_position++;
  }

  void _startTimer() {
    // Create a timer that fires every second
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      // Make your API call here
      _getMatchDetails();
    });
  }


  @override
  void dispose() {
    _admobInterstitialAd?.dispose();
    _timer.cancel();
    super.dispose();
  }

  void createInterstitialAd() {
    if (_admobInterstitialAd != null) return;

    InterstitialAd.load(
        adUnitId: interstitial_admob_id,
        request: request,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print('$ad loaded');
            _admobInterstitialAd = ad;
            _admobInterstitialAd.show();
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
      return Colors.greenAccent;
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

  getStr(String title) {
    if (title.contains("C.RR")) {
      String str3, str4;
      List<String> split1 = title.split("C.RR");
      if (split1.length > 1) {
        List<String> split2 = split1[1].split("R.RR");
        str3 = split2[0].replaceAll(":", "").replaceAll(",", "").trim();
        str4 = (split2.length > 1 && split2[1] != null)
            ? split2[1].replaceAll(":", "").replaceAll(",", "").trim()
            : "";

        // Displaying the values
        print("C.R.R : $str3");
        print("R.R.R : $str4");
      }
    }
  }

  String textToSpeechData(String str) {
    String str2;
    if (isSpeak) {
      if (str == "4-4-4") {
        str2 = "4 run";
      } else if (str == "0") {
        str2 = "Dot Ball";
      } else if (str == "1") {
        str2 = "1 run";
      } else if (str == "2") {
        str2 = "2 run";
      } else if (str == "3") {
        str2 = "3 run";
      } else if (str == "Ball") {
        str2 = " Ball";
      } else if (str == "Over") {
        str2 = " Over";
      } else {
        str2 = str == "6-6-6" ? "6 run" : str;
      }
    }
    return str2;
  }

  @override
  void initState() {
    super.initState();
    initInterstitialAd();
    initNativeAd();
    if (mounted) {
      _getMatchDetails();
      _startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (state_matches) {
      case "success":
        if (matchesList.length > 0) {
          Map<String, dynamic> matchData = jsonDecode(
              matchesList[0].jsondata.toString().replaceAll("\n", ""));
          String teamABanner =
              "${"${matchData['jsondata']['imgurl']}${matchData['jsondata']['TeamABanner']}"}";
          String teamBBanner =
              "${"${matchData['jsondata']['imgurl']}${matchData['jsondata']['TeamBBanner']}"}";

          String teamA = matchData['jsondata']['teamA'];
          String teamB = matchData['jsondata']['teamB'];

          String wicketA = matchData['jsondata']['wicketA'];
          String wicketB = matchData['jsondata']['wicketB'];
          String bowler = matchData['jsondata']['bowler'];
          String lastwicket = matchData['jsondata']['lastwicket'];
          String matchId = matchData['jsondata']['MatchId'];
          String imgeUrl = matchData['jsondata']['imgurl'];
          String title = matchData['jsondata']['title'];
          String score = matchData['jsondata']['score'];
          String overA = matchData['jsondata']['oversA'];
          List<String> balls = matchData['jsondata']['Last6Balls'].split("-");
          String strikerName = matchData['jsondata']['batsman']
              .substring(0, matchData['jsondata']['batsman'].indexOf("|"));
          String nonstrikerName = matchData['jsondata']['batsman']
              .substring(matchData['jsondata']['batsman'].indexOf("|") + 1);
          String substring = matchData['jsondata']['oversB']
              .substring(0, matchData['jsondata']['oversB'].indexOf("|"));
          List<String> runs = substring.split(",");

          String substring2 = matchData['jsondata']['oversB']
              .substring(matchData['jsondata']['oversB'].indexOf("|") + 1);
          List<String> ballsdata = substring2.split(",");

          String strikerSR = HelperUtils().getStrikerSR(runs[1], ballsdata[1]);
          String nonstrikerSR =
              HelperUtils().getNonStrikerSR(runs[0], ballsdata[0]);

          String crr = HelperUtils().extractCRR(title);

          // List<Map<String, dynamic>> bowlers = [];
          // for (int i = 1; i <= 8; i++) {
          //   String bowlerKey = 'bowler$i';
          //   String boverKey = 'bover$i';
          //   String brunKey = 'brun$i';
          //   String bwicketKey = 'bwicket$i';
          //
          //   if (matchData['jsondata'][bowlerKey] != null) {
          //     Map<String, dynamic> bowlerInfo = {
          //       'bowler': matchData['jsondata'][bowlerKey],
          //       'overs': matchData['jsondata'][boverKey],
          //       'runs': matchData['jsondata'][brunKey],
          //       'wickets': matchData['jsondata'][bwicketKey]
          //     };
          //     bowlers.add(bowlerInfo);
          //   }
          // }

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
                                key: ValueKey("teamABanner"),
                                imageUrl: teamABanner,
                                errorWidget: (context, url, error) => Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey.shade200,
                                  ),
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
                                    fontSize: 15,
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
                                key: ValueKey("teamBBanner"),
                                imageUrl: teamBBanner,
                                errorWidget: (context, url, error) => Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey.shade200,
                                  ),
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
                                    fontSize: 15,
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
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CachedNetworkImage(
                                          key: ValueKey("teamABanner"),
                                          imageUrl: teamABanner,
                                          errorWidget: (context, url, error) =>
                                              Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.grey.shade200,
                                            ),
                                          ),
                                          imageBuilder:
                                              (context, imageProvider) =>
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
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0, vertical: 8.0),
                                          child: Column(
                                            children: [
                                              Text(
                                                wicketA,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 23,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 3.0),
                                                child: Text(
                                                  overA,
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
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
                            ),
                            Container(
                              height: 50,
                              width: 1,
                              color: Colors.grey.shade300,
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  children: [
                                    Text(
                                      textToSpeechData(score),
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        "C.RR: $crr",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 17,
                                            fontWeight: FontWeight.normal),
                                      ),
                                    ),
                                  ],
                                ),
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
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.grey[200],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15.0),
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
                                  shadows: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      offset: Offset(0, 0),
                                      blurRadius: 5,
                                    ),
                                  ],
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
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10))),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  "Batsman",
                                  style: TextStyle(
                                      color: Colors.blueAccent,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  "R",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  "B",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  "4s",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  "6s",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  "SR",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  strikerName,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 17,
                                      fontWeight: FontWeight.normal),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  runs[1],
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 17,
                                      fontWeight: FontWeight.normal),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  substring2.split(",")[1],
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 17,
                                      fontWeight: FontWeight.normal),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  matchData['jsondata']['s4'],
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 17,
                                      fontWeight: FontWeight.normal),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  matchData['jsondata']['s6'],
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 17,
                                      fontWeight: FontWeight.normal),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  strikerSR,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 17,
                                      fontWeight: FontWeight.normal),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  nonstrikerName,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 17,
                                      fontWeight: FontWeight.normal),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  runs[0],
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 17,
                                      fontWeight: FontWeight.normal),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  substring2.split(",")[0],
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 17,
                                      fontWeight: FontWeight.normal),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  matchData['jsondata']['ns4'],
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 17,
                                      fontWeight: FontWeight.normal),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  matchData['jsondata']['ns6'],
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 17,
                                      fontWeight: FontWeight.normal),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  nonstrikerSR,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 17,
                                      fontWeight: FontWeight.normal),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: [
                              Text(
                                "Bowler:",
                                style: TextStyle(
                                    color: Colors.blueAccent,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                "${matchData['jsondata']['bowler']}",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 17,
                                    fontWeight: FontWeight.normal),
                              ),
                            ],
                          ),       SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: [
                              Text(
                                "Last Wicket:",
                                style: TextStyle(
                                    color: Colors.blueAccent,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                "${matchData['jsondata']['lastwicket']}",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 17,
                                    fontWeight: FontWeight.normal),
                              ),
                            ],
                          ),

                          SizedBox(
                            height: 15,
                          ),

                          // ListView.builder(
                          //   shrinkWrap: true,
                          //   itemCount: bowlers.length,
                          //   physics: NeverScrollableScrollPhysics(),
                          //   itemBuilder: (BuildContext context, int index) {
                          //     return ListTile(
                          //       title: Text('Bowler: ${bowlers[index]['bowler']}'),
                          //       subtitle: Text('Overs: ${bowlers[index]['overs']}, Runs: ${bowlers[index]['runs']}, Wickets: ${bowlers[index]['wickets']}'),
                          //     );
                          //   },
                          // )

                        ],
                      )),
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
                          fontSize: 16,
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                ],
              ),
            )
          ]);
        } else
          return Center(child: Text("No Data Available"));

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

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app/global_helper.dart';
import 'package:app/model/current_match_model.dart';
import 'package:app/model/live_line_response.dart';
import 'package:app/model/live_match_model.dart';
import 'package:app/model/match_type.dart';
import 'package:app/screens/home/fragment/match_details.dart';
import 'package:app/screens/home/fragment/match_details_v2.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
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
import 'package:line_icons/line_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../model/upcomming_match_response.dart';

class CurrentMatchesV2 extends StatefulWidget {
  @override
  _MatchesState createState() => _MatchesState();
}

class _MatchesState extends State<CurrentMatchesV2> {
  List<MatchTypeData> competitionsList = [];
  List<MatchLiveData> matchesList = [];
  List<AllMatch> upcomingMatchesList = [];
  List<LiveMatchData> liveMatchesList = [];
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  bool loading = false;
  bool refreshing = true;
  String state = "progress";
  String state_matches = "progress";

  MatchTypeData selected_competition;

  bool load_more = false;
  int page = 0;
  int selected_index = 0;
  int item_selected = -1;
  bool item_selected_status = false;

  ScrollController listViewController = new ScrollController();

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

  Timer _timer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initInterstitialAd();
    initNativeAd();
    refreshing = false;
    _getList();
    _startTimer();

    listViewController.addListener(_scrollListener);
  }

  void _startTimer() {
    // Create a timer that fires every second
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      // Make your API call here
      _getMatchsList(selected_competition);
    });
  }

  _scrollListener() {
    if (listViewController.offset >=
            (listViewController.position.maxScrollExtent) &&
        !listViewController.position.outOfRange) {
      //_loadMore(selected_competition);
    }
  }

  Future<List<MatchTypeData>> _getList() async {
    if (loading) return null;

    competitionsList.clear();
    loading = true;

    MatchTypeData data1 = MatchTypeData(
        id: 0,
        name: "live",
        value: "LiveLine",
        image: "assets/images/live_icon.png",
        selected: true);



    MatchTypeData data2 = MatchTypeData(
        id: 1,
        name: "upcoming",
        value: "upcomingMatches",
        image: "assets/images/upcoming.png",
        selected: false);

       MatchTypeData data3 = MatchTypeData(
        id: 2,
        name: "result",
        value: "MatchResults",
        image: "assets/images/cricket.png",
        selected: false);


    selected_competition = data1;
    competitionsList.add(data1);
    competitionsList.add(data2);
    competitionsList.add(data3);

    setState(() {
      state_matches = "progress";
      _getMatchsList(selected_competition);
    });
  }

  Future<List<TypeMatch>> _getMatchsList(
      MatchTypeData selected_competition) async {
    page = 0;
    var response;
    var statusCode = 200;
    try {
      response = await apiRest.getLiveMatchData(selected_competition.value);
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
          state = "success";

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

  Future<List<TypeMatch>> _getUpcommingList(MatchTypeData selected_competition,{isAllMatch=false}) async {
    page = 0;
    var response;
    var statusCode = 200;
    try {
      if(isAllMatch)
        {
          response = await apiRest.getMatchResult("1","20");
        }
      else
        {
          response = await apiRest.getLiveMatchData(selected_competition.value);
        }
    } catch (ex) {
      print("exfdsf");
      print(ex);
      statusCode = 500;
    }
    if (statusCode == 200) {
      if (response.statusCode == 200) {
        UpcommingResponse responsedata =
            UpcommingResponse.fromJson(response.body);
        upcomingMatchesList = responsedata.allMatch;
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


  Widget buildHome() {
    switch (state) {
      case "success":
        return RefreshIndicator(
          backgroundColor: Theme.of(context).primaryColor,
          key: refreshKey,
          onRefresh: _getList,
          child: ListView.builder(
            itemCount: 4,
            controller: listViewController,
            itemBuilder: (context, index) {
              if (index == 0) {
                return TitleHomeWidget(title: "Current Matches");
              }
              else if (index == 1) {
                return MatchTypeWidget(
                    competitions: competitionsList, action: selectTables);
              }
              else if (index == 2) {
                switch (state_matches) {
                  case "success":
                    return ListView.builder(
                      shrinkWrap: true,
                      primary: false,
                      itemCount: upcomingMatchesList.length,
                      itemBuilder: (context, jndex) {
                        AllMatch match = upcomingMatchesList[jndex];
                        return InkWell(
                          onTap: (){
                            if(selected_competition.id==2)
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        MatchDetailV2(
                                          match: match.title,
                                          matchid: "${match.matchId}",
                                        )));

                          },
                          child: Container(
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
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: Theme.of(context).accentColor,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10))),
                                  child: Text(
                                    match.title,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            CachedNetworkImage(
                                              imageUrl:
                                                  "${match.imageUrl}${match.teamAImage}",
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
                                              errorWidget: (context, url, error) => Container(
                                                width: 50,
                                                height: 50,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.grey.shade200,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  vertical: 8.0),
                                              child: Text(
                                                match.teamA,
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodyText1
                                                        .color,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold),
                                              ),
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
                                              imageUrl:
                                                  "${match.imageUrl}${match.teamBImage}",
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
                                              errorWidget: (context, url, error) => Container(
                                                width: 50,
                                                height: 50,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.grey.shade200,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  vertical: 8.0),
                                              child: Text(
                                                match.teamB,
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodyText1
                                                        .color,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    " ${match.matchtime}",
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyText1
                                            .color,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5.0, horizontal: 5),
                                  child: Text(
                                    match.venue,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyText1
                                            .color,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),

                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.2),
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(10),
                                          bottomRight: Radius.circular(10))),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment
                                        .center,
                                    children: [

                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: Center(
                                          child: Text(
                                            match.result != null
                                                ? match.result
                                                : "Upcoming",
                                            style: TextStyle(
                                                color: Theme
                                                    .of(context)
                                                    .textTheme
                                                    .bodyText1
                                                    .color,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              ],
                            ),
                          ),
                        );
                      },
                    );

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
                        refreshing = false;
                        _getList();
                      }),
                    );
                }
              }
              else {
                switch (state_matches) {
                  case "success":
                    return ListView.builder(
                      shrinkWrap: true,
                      primary: false,
                      itemCount: matchesList.length,
                      itemBuilder: (context, jndex) {
                        MatchLiveData match = matchesList[jndex];

                        if (match.jsondata.toString().length > 0) {
                          Map<String, dynamic> matchData = jsonDecode(
                              match.jsondata.toString().replaceAll("\n", ""));
                          String teamABanner = matchData['jsondata']['TeamABanner'];
                          String teamBBanner = matchData['jsondata']['TeamBBanner'];

                          String teamA = matchData['jsondata']['teamA'];
                          String teamB = matchData['jsondata']['teamB'];

                          String wicketA = matchData['jsondata']['wicketA'];
                          String wicketB = matchData['jsondata']['wicketB'];
                          String bowler = matchData['jsondata']['bowler'];
                          String matchId = matchData['jsondata']['MatchId'];
                          String title = matchData['jsondata']['title'];
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          MatchDetailV2(
                                            match: title,
                                            matchid: matchId,
                                          )));
                            },
                            child: Container(
                              margin: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: Theme
                                      .of(context)
                                      .cardColor,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black54.withOpacity(0.3),
                                        offset: Offset(0, 0),
                                        blurRadius: 5)
                                  ]),
                              child: Column(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        color: Theme
                                            .of(context)
                                            .accentColor,
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10))),
                                    child: Text(
                                      match.title,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                            children: [
                                              CachedNetworkImage(
                                                imageUrl:
                                                "${match
                                                    .imgeUrl}${teamABanner}",
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
                                                errorWidget: (context, url, error) => Container(
                                                  width: 50,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.grey.shade200,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    vertical: 8.0),
                                                child: Text(
                                                  teamA,
                                                  style: TextStyle(
                                                      color: Theme
                                                          .of(context)
                                                          .textTheme
                                                          .bodyText1
                                                          .color,
                                                      fontSize: 16,
                                                      fontWeight: FontWeight
                                                          .bold),
                                                ),
                                              ),
                                              Text(
                                                wicketA,
                                                style: TextStyle(
                                                    color: Theme
                                                        .of(context)
                                                        .textTheme
                                                        .bodyText1
                                                        .color,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight
                                                        .bold),
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
                                                imageUrl:
                                                "${match
                                                    .imgeUrl}${teamBBanner}",
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
                                                errorWidget: (context, url, error) => Container(
                                                  width: 50,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.grey.shade200,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    vertical: 8.0),
                                                child: Text(
                                                  teamB,
                                                  style: TextStyle(
                                                      color: Theme
                                                          .of(context)
                                                          .textTheme
                                                          .bodyText1
                                                          .color,
                                                      fontSize: 16,
                                                      fontWeight: FontWeight
                                                          .bold),
                                                ),
                                              ),
                                              Text(
                                                wicketB,
                                                style: TextStyle(
                                                    color: Theme
                                                        .of(context)
                                                        .textTheme
                                                        .bodyText1
                                                        .color,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight
                                                        .bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      " ${match.matchtime}",
                                      style: TextStyle(
                                          color: Theme
                                              .of(context)
                                              .textTheme
                                              .bodyText1
                                              .color,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5.0, horizontal: 5),
                                    child: Text(
                                      match.venue,
                                      style: TextStyle(
                                          color: Theme
                                              .of(context)
                                              .textTheme
                                              .bodyText1
                                              .color,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.2),
                                        borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(10),
                                            bottomRight: Radius.circular(10))),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .center,
                                      children: [
                                        bowler != "0"
                                            ? Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          width: 20,
                                          height: 20,
                                          decoration: ShapeDecoration(
                                              color: Colors.green,
                                              shape: CircleBorder()),
                                        )
                                            : SizedBox.shrink(),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Center(
                                            child: Text(
                                              match.result
                                                  .trim()
                                                  .length > 0
                                                  ? match.result
                                                  : bowler != "0"
                                                  ? "Live"
                                                  : "Upcoming",
                                              style: TextStyle(
                                                  color: Theme
                                                      .of(context)
                                                      .textTheme
                                                      .bodyText1
                                                      .color,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          return Container();
                        }
                      },
                    );
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
                        refreshing = false;
                        _getList();
                      }),
                    );
                }
              }
            },
          ),
        );
        break;
      case "progress":
        return LoadingWidget();
        break;
      case "error":
        return TryAgainButton(action: () {
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
            visible: load_more,
            child: Center(
                child: Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black,
                        offset: Offset(0, 0),
                        blurRadius: 1)
                  ]),
              height: 35,
              width: 35,
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(
                backgroundColor: Theme.of(context).primaryColor,
                strokeWidth: 2,
              ),
            )),
          ),
        )
      ],
    );
  }

  selectTables(MatchTypeData competition) {
    print("competition.id");
    print(competition.id);
    print(competition.value);
    upcomingMatchesList.clear();
    matchesList.clear();
    setState(() {
      selected_competition = competition;

      if (competition.id == 0) {
        _getMatchsList(selected_competition);
      } else if (competition.id == 1) {
        _getUpcommingList(selected_competition,isAllMatch: false);
      }
      else if (competition.id == 2) {
        _getUpcommingList(selected_competition,isAllMatch: true);
      }


      for (MatchTypeData c in competitionsList) c.selected = false;
      competition.selected = true;
    });
  }
}

class MatchTypeWidget extends StatefulWidget {
  List<MatchTypeData> competitions;
  Function action;

  MatchTypeWidget({this.competitions, this.action});

  @override
  _MatchTypeWidgetState createState() => _MatchTypeWidgetState();
}

class _MatchTypeWidgetState extends State<MatchTypeWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      child: ListView.builder(
          itemCount: widget.competitions.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, int index) {
            return buildCompetition(index);
          }),
    );
  }

  Widget buildCompetition(int index) {
    return GestureDetector(
      onTap: () {
        widget.action(widget.competitions[index]);
      },
      child: Container(
        margin: EdgeInsets.only(left: 10, right: 5, top: 10, bottom: 10),
        decoration:
            BoxDecoration(borderRadius: BorderRadius.circular(10), boxShadow: [
          BoxShadow(
              color: Colors.black54.withOpacity(0.3),
              offset: Offset(0, 0),
              blurRadius: 5)
        ]),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 500),
          curve: Curves.linearToEaseOut,
          decoration: BoxDecoration(
            color: (widget.competitions[index].selected == true)
                ? Theme.of(context).accentColor
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
            child: Row(
              children: [
                // (widget.competitions[index].id  == 0)?
                // Icon(LineIcons.trophy,color: (widget.competitions[index].selected == true)
                //     ? Colors.white
                //     : Theme.of(context).textTheme.bodyText2.color
                // )
                //     :
                Image.asset(widget.competitions[index].image,
                    color: (widget.competitions[index].selected == true)
                        ? Colors.white
                        : Theme.of(context).textTheme.bodyText2.color),
                SizedBox(width: 7),
                Text(
                  widget.competitions[index].name.toUpperCase(),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: (widget.competitions[index].selected == true)
                          ? Colors.white
                          : Theme.of(context).textTheme.bodyText2.color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

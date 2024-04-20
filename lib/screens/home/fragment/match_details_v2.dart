import 'dart:convert';
import 'dart:io';

import 'package:action_broadcast/action_broadcast.dart';
import 'package:app/global_helper.dart';
import 'package:app/screens/home/fragment/match_details/all_palyer_info.dart';
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
import 'match_details/match_info.dart';
import 'match_details/stats_info.dart';

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white54,
          centerTitle: false,
          title: Text(widget.match,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.w600)),

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
                icon: Icon(Icons.info_outline),
                text: "Stats",
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            InfoMatch(widget.matchid),
            AllPlayer(widget.matchid),
            Stats(widget.matchid),
          ],
        ),
      ),
    );
  }
}



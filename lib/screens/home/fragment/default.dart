
import 'dart:async';
import 'dart:convert';
import 'dart:io';


import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:facebook_audience_network/ad/ad_interstitial.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:flutter/material.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:line_icons/line_icons.dart';
import 'package:app/api/api_rest.dart';
import 'package:app/config/colors.dart';
import 'package:app/model/match.dart';
import 'package:app/model/post.dart';
import 'package:app/model/player.dart';
import 'package:app/model/question.dart';
import 'package:app/provider/ads_provider.dart';
import 'package:app/screens/ads/item_facebook_native.dart';
import 'package:app/screens/ads/item_native_admob.dart';
import 'package:app/screens/matches/match_mini_widget.dart';
import 'package:app/screens/post/post_detail.dart';
import 'package:app/screens/post/video_detail.dart';
import 'package:app/screens/post/youtube_detail.dart';
import 'package:app/screens/status/create_widget.dart';
import 'package:app/screens/home/sondage_wedget.dart';
import 'package:app/screens/matches/match_widget.dart';
import 'package:app/screens/players/player_mini_widget.dart';
import 'package:app/screens/post/post_widget.dart';
import 'package:app/screens/status/status_widget.dart';
import 'package:app/screens/home/team_title_widget.dart';
import 'package:app/screens/home/title_home_widget.dart';
import 'package:app/screens/tryagain.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:app/screens/loading.dart';
import 'dart:convert' as convert;

import '../../../model/current_match_model.dart';
import '../../../model/live_line_response.dart';
import '../../../model/match_type.dart';
import 'match_details_v2.dart';
class Default extends StatefulWidget {
  @override
  _DefaultState createState() => _DefaultState();
}

class _DefaultState extends State<Default> {

  List<Post> favoritePostsList = [];
  List<Post> postsList = [];
  List<Player> playersList = [];
  List<Question> questionsList = [];
  List<Match> matchesList = [];
  List<MatchLiveData> liveMatchesList = [];
  bool load_more = false;
  int page = 0;
  String state_matches = "progress";

  var refreshKey = GlobalKey<RefreshIndicatorState>();
  bool loading =  false;
  bool refreshing =  true;
  String state =  "progress";

  ScrollController listViewController= new ScrollController();


  String  _appname ="";
  String _appsubname ="";
  String _applogo="";

  String _appstar = "";


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
  Route post_route = null;
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
          if(post_route != null)
            _isInterstitialAdLoaded = false;
            _loadInterstitialAd();
            Navigator.push(context, post_route);
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
  Timer _timer;

  @override
  void initState() {
    // TODO: implement initState
    refreshing =  false;
    listViewController.addListener(_scrollListener);
    initInterstitialAd();
    initNativeAd();
    _getList();
    if (mounted) {
      _startTimer();
    }
    super.initState();
    initAppInfos();
  }
  void _startTimer() {
    // Create a timer that fires every second
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      // Make your API call here
      _getMatchsList();
    });
  }


  Future initAppInfos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _appname = prefs.getString("app_name");
      _appsubname = prefs.getString("app_sub_name");
      _applogo =  prefs.getString("app_logo");
      _appstar =  prefs.getString("app_star");
    });
    return _appstar;

  }
  _scrollListener() {
    if (listViewController.offset >= (listViewController.position.maxScrollExtent) && !listViewController.position.outOfRange) {
      _loadMore();
    }

  }
  Future<List<Post>>  _getList() async{
    if(loading)
      return null;
    postsList.clear();
    playersList.clear();
    questionsList.clear();
    matchesList.clear();
    page = 0;
    native_ads_position = 0;
    loading =  true;

    if(refreshing == false) {
      setState(() {
        state = "progress";
      });
      refreshing =  true;

    }
    // Await the http get response, then decode the json-formatted response.
    var response;
    print(apiRest.getHomeItems());
    try {
      response = await http.get(apiRest.getHomeItems());
    } catch (ex) {
      loading = false;
      setState(() {
        state =  "error";
      });
    }
    if(!loading)
      return null;

    if (response.statusCode == 200) {
      var data  = await http.get(apiRest.getHomeItems());
      var jsonData =  convert.jsonDecode(data.body);
      var postsjsonData = jsonData["posts"];
      var playersjsonData = jsonData["players"];
      var questionsjsonData = jsonData["questions"];
      var matchesjsonData = jsonData["matches"];

      for(Map i in playersjsonData){
        Player player = Player.fromJson(i);
        playersList.add(player);
      }

      for(Map i in matchesjsonData){
        Match _match = Match.fromJson(i);
        matchesList.add(_match);
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>  votedQuestions=  await prefs.getStringList('voted_question');
      if(votedQuestions==null){
        votedQuestions=  [];
      }
      for(Map i in questionsjsonData){
        Question question = Question.fromJson(i);
        for(String questionId in votedQuestions){
          if(int.parse(questionId) == question.id){
            question.open = false;
          }
        }
        questionsList.add(question);
      }

      String  favoritePostsString=  await prefs.getString('post_favorires');

      if(favoritePostsString != null){
        favoritePostsList = Post.decode(favoritePostsString);
      }
      if(favoritePostsList == null){
        favoritePostsList= [];
      }



      postsList.add(Post(id: -1));
      postsList.add(Post(id: -11));
      if(matchesList.length>0){
        postsList.add(Post(id: -2));
      }
      if(playersList.length>0){
        postsList.add(Post(id: -3));
      }

      if(questionsList.length>0){
        postsList.add(Post(id: -4));
      }



      for(Map p in postsjsonData){
        Post post = Post.fromJson(p);
        for(Post  favorite_post in favoritePostsList){
          if(favorite_post.id == post.id){
            post.favorite = true;
          }
        }
        postsList.add(post);

        insertAds();

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
    return postsList;
  }

  Future<List<TypeMatch>> _getMatchsList() async {
    page = 0;
    var response;
    var statusCode = 200;
    try {
      response = await apiRest.getLiveMatchData("LiveLine");
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
        liveMatchesList = data.map((json) => MatchLiveData.fromMap(json)).toList();
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


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          right: 0,
          top: 0,
          child:Container(
            height: 230,
            child:
            FutureBuilder(
                future: initAppInfos(),
                builder: (context, snapshot) {
                  if(snapshot.hasData)
                    return Opacity(child: CachedNetworkImage(
                      height: 240,
                      imageUrl: snapshot.data,
                      errorWidget: (context, url, error) => Icon(Icons.error),
                      fit: BoxFit.fitWidth,
                    ),opacity: 0.9);
                  else
                    return Text("");
                }
            )
          ),
        ),
        Positioned(
          child: buildHome()
        ),
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

  Widget buildHome() {
    switch(state){
      case "success":
        return RefreshIndicator(
          backgroundColor: Theme.of(context).primaryColor,
          key: refreshKey,
          onRefresh:_getList,
          child: ListView.builder(
            controller: listViewController,
            itemCount: postsList.length,
            itemBuilder: (context, index) {

              if(postsList[index].id == -1){
                return TeamTitleWidget(applogo:_applogo,appname:_appname,appsubname:_appsubname);
              }
                if(postsList[index].id == -11){

                  switch (state_matches) {
                    case "success":

                      return   CarouselSlider.builder(
                        itemCount: liveMatchesList.length,
                        itemBuilder: (BuildContext context, int jndex, int pageViewIndex)
                        {
                          MatchLiveData match = liveMatchesList[jndex];

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
                                    Expanded(
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
                                        ],
                                      ),
                                    ),

                                    Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Container(
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
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            return Container();
                          }
                        },  options: CarouselOptions(
                        height: 280,
                        viewportFraction: 1,
                        initialPage: 0,
                        enableInfiniteScroll: true,
                        reverse: false,
                        autoPlay: false,
                        autoPlayInterval: Duration(seconds: 7),
                        autoPlayAnimationDuration: Duration(milliseconds: 800),
                        autoPlayCurve: Curves.fastOutSlowIn,
                        enlargeCenterPage: true,
                        enlargeFactor: 0.0,
                        scrollDirection: Axis.horizontal,
                      ),


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


              else if (postsList[index].id == -2){
                return Container(
                  width: MediaQuery.of(context).size.width,
                  child: ListView.builder(
                      primary: false,
                      shrinkWrap: true,
                      itemCount: matchesList.length,
                      itemBuilder: (context,int index){
                        return MatchWidget(match: matchesList[index]);
                      }
                  ),
                );
              }
              else if(postsList[index].id == -3){
                return Container(
                  height: 170,
                  padding: EdgeInsets.only(left: 5,right: 0,top: 5,bottom: 5),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: playersList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return   PlayerMiniWidget(player: playersList[index],bgimage : _applogo);
                    },
                  ),
                );
              }else if (postsList[index].id == -4){
                return Container(
                  width: MediaQuery.of(context).size.width,
                  child: ListView.builder(
                      primary: false,
                      shrinkWrap: true,
                      itemCount: questionsList.length,
                      itemBuilder: (context,int index){
                        return SondageWidget(question: questionsList[index]);
                      }
                  ),
                );
              }else if (postsList[index].id == -5){
                return AdmobNativeAdItem(adUnitID: admob_native_ad_id);
              }else if (postsList[index].id == -6){
               return FacebookNativeAdItem(PLACEMENT_ID: facebook_native_ad_id);
              }

              else{
                return PostWidget(post: postsList[index],favorite: postFavorite,navigate:navigate);
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
  navigate(Post post,Function _postFavorite) async {


    switch(post.type){
      case "youtube":
        post_route = MaterialPageRoute(builder: (context) => YoutubeDetail(post:post,postFavorite: _postFavorite));
        break;
      case "video":
        post_route = MaterialPageRoute(builder: (context) => VideoDetail(post:post,postFavorite: _postFavorite));
        break;
      default:
        post_route = MaterialPageRoute(builder: (context) => PostDetail(post:post,postFavorite: _postFavorite));
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
            Navigator.push(context, post_route);
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
      Navigator.push(context, post_route);
    }



  }
  postFavorite(Post post) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String  favoritePostsString=  await prefs.getString('post_favorires');

    if(favoritePostsString != null){
      favoritePostsList = Post.decode(favoritePostsString);
    }
    if(favoritePostsList == null){
      favoritePostsList= [];
    }
    Post favorited_post =  null;
    for(Post favorite_post in favoritePostsList){
        if(favorite_post.id == post.id){
          favorited_post = favorite_post;
        }
    }
    if(favorited_post == null){
      favoritePostsList.add(post);
      setState(() {
        post.favorite = true;
      });
    }else{
      favoritePostsList.remove(favorited_post);
      setState(() {
        post.favorite = false;
      });
    }

    String encodedData = Post.encode(favoritePostsList);
    prefs.setString('post_favorires',encodedData);
  }

  Future<void>  _loadMore() async{
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
      response = await http.get(apiRest.postByPage(page));
    } catch (ex) {
      statusCode = 500;
    }
    if(!loading)
      return null;
    if (statusCode == 200) {
      if (response.statusCode == 200) {
        var jsonData =  convert.jsonDecode(response.body);

        for(Map i in jsonData){
          Post post = Post.fromJson(i);
          for(Post  favorite_post in favoritePostsList){
            if(favorite_post.id == post.id){
              post.favorite = true;
            }
          }
          postsList.add(post);

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

  void insertAds(){
    if(native_ads_position  ==  native_ads_item){
      native_ads_position = 0;
      if(native_ads_type == "ADMOB"){
        postsList.add(Post(id:-5));
      }else if(native_ads_type =="FACEBOOK"){
        postsList.add(Post(id:-6));
      }else if(native_ads_type =="BOTH"){
        if(native_ads_current_type == "ADMOB"){
          postsList.add(Post(id:-5));
          native_ads_current_type = "FACEBOOK";
        }else{
          postsList.add(Post(id:-6));
          native_ads_current_type = "ADMOB";
        }
      }
    }
    native_ads_position++;
  }

  void initNativeAd() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    adsProvider =  AdsProvider(prefs,(Platform.isAndroid)?TargetPlatform.android:TargetPlatform.iOS);
    facebook_native_ad_id = await  adsProvider.getNativeFacebookId();
    admob_native_ad_id = await  adsProvider.getNativeAdmobId();
    native_ads_type =  await adsProvider.getNativeType();
    native_ads_item =  await  adsProvider.getNativeItem();

    print(facebook_native_ad_id);
    print(admob_native_ad_id);
    print(native_ads_type);
    print(native_ads_item);
  }


}




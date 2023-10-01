
import 'dart:convert';
import 'dart:io';

import 'package:app/global_helper.dart';
import 'package:app/model/current_match_model.dart';
import 'package:app/model/live_match_model.dart';
import 'package:app/model/match_type.dart';
import 'package:app/screens/home/fragment/match_details.dart';
import 'package:cached_network_image/cached_network_image.dart';
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


class CurrentMatches extends StatefulWidget {
  @override
  _MatchesState createState() => _MatchesState();
}

class _MatchesState extends State<CurrentMatches> {
  List<MatchTypeData> competitionsList = [];
  List<TypeMatch> matchesList = [];
  List<LiveMatchData> liveMatchesList = [];
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  bool loading =  false;
  bool refreshing =  true;
  String state =  "progress";
  String state_matches =  "progress";

  MatchTypeData selected_competition;

  bool load_more = false;
  int page = 0;
  int selected_index = 0;
  int item_selected=-1;
  bool item_selected_status=false;

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


  void _loadInterstitialAd()   {
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
       // matchesList.add(EMatch(id:"-5"));
      }else if(native_ads_type =="FACEBOOK"){
       // matchesList.add(EMatch(id:"-6"));
      }else if(native_ads_type =="BOTH"){
        if(native_ads_current_type == "ADMOB"){
          //matchesList.add(EMatch(id:"-5"));
          native_ads_current_type = "FACEBOOK";
        }else{
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
      //_loadMore(selected_competition);
    }

  }

  Future<List<MatchTypeData>>  _getList() async{
    if(loading)
      return null;

    competitionsList.clear();
    loading =  true;


        MatchTypeData data1 = MatchTypeData(id: 0,name: "live",image: "assets/images/live_icon.png",selected: true);
        MatchTypeData data2 = MatchTypeData(id: 0,name: "recent",image: "assets/images/cricket.png",selected: false);
        MatchTypeData data3 = MatchTypeData(id: 0,name: "upcoming",image: "assets/images/upcoming.png",selected: false);
        selected_competition =data1;
        competitionsList.add(data1);
        competitionsList.add(data2);
        competitionsList.add(data3);

        setState(() {
          state =  "success";
          _getMatchsList(selected_competition);
        });

  }


  Future<List<TypeMatch>>  _getMatchsList(MatchTypeData selected_competition) async{

        print("calling...");
        setState(() {
          state_matches = "progress";
        });
        matchesList.clear();
        page = 0;
        var response;
        var statusCode = 200;
        try {
          response = await apiRest.getEScoreMatch(selected_competition.name);
          print(response.toString());
        } catch (ex) {
          print("exfdsf");
          print(ex);
          statusCode = 500;
        }
        if (statusCode == 200) {
          if (response.statusCode == 200) {
            String responseapi = response.body.toString().replaceAll("\n","");
            debugPrint(responseapi);
            RecentMatchResponse responsedata =  RecentMatchResponse.fromJson(responseapi);
            matchesList = responsedata.typeMatches;
            setState(() {
              state =  "success";
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
            itemCount: 4,
            controller: listViewController,
            itemBuilder: (context, index) {
              if(index== 0){
                return TitleHomeWidget(title : "Current Matches");
              }
              else if(index==1){
              return MatchTypeWidget(competitions : competitionsList,action: selectTables);
              }
              else if(index == 2){
           return Container(
                  height: 40,
                  child: ListView.builder(
                    itemCount:  matchesList.length,
                    itemBuilder: (context,typeIndex){
                      var item = matchesList[typeIndex].matchType;
                      return Row(
                        children: [
                          buildTab(item,typeIndex),
                        ],
                      );

                    },
                    scrollDirection: Axis.horizontal,

                  ),
                );
              }
              else{
                switch(state_matches){
                  case "success":
                return ListView.builder(
                      shrinkWrap: true,
                      primary: false,
                      itemCount: matchesList[selected_index].seriesMatches.length,
                      itemBuilder: (context, jndex) {
                        SeriesMatch match = matchesList[selected_index].seriesMatches[jndex];
                   return Hero(
                     tag: "hero_match_",
                     transitionOnUserGestures: true,
                     child: Material(
                       type: MaterialType.transparency, // likely needed
                       child: Container(
                         width: MediaQuery.of(context).size.width,
                         decoration: BoxDecoration(
                             color: Theme.of(context).cardColor,
                             borderRadius: BorderRadius.circular(10),
                             boxShadow: [BoxShadow(
                                 color: Colors.black54.withOpacity(0.2),
                                 offset: Offset(0,0),
                                 blurRadius: 5
                             )]
                         ),
                         margin: EdgeInsets.only(left: 10,right: 10,bottom: 5,top: 5),
                         child: Column(
                           children: <Widget>[
                             if (match.seriesAdWrapper==null) SizedBox.shrink() else InkWell(
                               onTap: (){
                                 item_selected=jndex;
                                 item_selected_status=!item_selected_status;
                                 setState(() {
                                 });
                                 print(item_selected);
                                 print(jndex);
                                 print(   match.seriesAdWrapper.seriesName);
                               },
                               child: Container(
                                 child: Row(
                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                   crossAxisAlignment: CrossAxisAlignment.center,
                                   children: [


                                     SizedBox(width: 5),
                                       Expanded(
                                         child: Padding(
                                           padding: const EdgeInsets.all(8.0),
                                           child: Text(
                                           match.seriesAdWrapper==null?"":match.seriesAdWrapper.seriesName,
                                           style: TextStyle(
                                               fontSize: 14,
                                               fontWeight: FontWeight.bold,
                                               color:  Colors.redAccent
                                           ),
                                     ),
                                         ),
                                       ),

                                     Icon(Icons.arrow_drop_down)
                                   ],
                                 ),
                                 height: 60,
                                 decoration: BoxDecoration(
                                     border: Border(bottom: BorderSide(width: 1,color: Colors.grey.withOpacity(0.1)))
                                 ),
                               ),
                             ),

                             item_selected==jndex && item_selected_status?  ListView.builder(
                               shrinkWrap: true,
                                 physics: NeverScrollableScrollPhysics(),
                                 itemCount: match.seriesAdWrapper.matches.length,
                                 itemBuilder: (context, matchIndex){
                                   RecentMatch rm =match.seriesAdWrapper.matches[matchIndex];
                               return InkWell(
                                 onTap: (){
                                   Route match_route = MaterialPageRoute(builder: (context) => RecentMatchDetails(match :  rm,tag: 1));
                                   Navigator.push(context, match_route);
                                 },
                                 child: Container(
                                   width: MediaQuery.of(context).size.width,
                                   decoration: BoxDecoration(
                                       color: Theme.of(context).cardColor,
                                       borderRadius: BorderRadius.circular(10),
                                       boxShadow: [BoxShadow(
                                           color: Colors.black54.withOpacity(0.2),
                                           offset: Offset(0,0),
                                           blurRadius: 5
                                       )]
                                   ),
                                   margin: EdgeInsets.only(left: 10,right: 10,bottom: 5,top: 5),
                                   child: Column(
                                     children: [
                                       Row(
                                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                         children: [
                                           Container(
                                             clipBehavior: Clip.none,
                                             height: 25,
                                             color: Colors.orangeAccent,
                                             child: Align(
                                               alignment: Alignment.center,
                                               child: Padding(
                                                 padding: const EdgeInsets.only(left: 8.0,right: 8),
                                                 child: Text(
                                                     rm.matchInfo.state,
                                                     style: TextStyle(
                                                         color: Theme.of(context).textTheme.bodyText2.color,
                                                         fontSize: 12,
                                                         fontWeight: FontWeight.w700
                                                     )
                                                 ),
                                               ),
                                             ),
                                           ),

                                        Row(
                                          children: [
                                            Image.asset("assets/images/cricket.png",height: 18,width:18),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 8.0),
                                              child: Text(
                                                  rm.matchInfo.matchFormat.name,
                                                  style: TextStyle(
                                                      color: Theme.of(context).textTheme.bodyText2.color,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w700
                                                  )
                                              ),
                                            ),
                                          ],
                                        ),
                                           Container(
                                             height: 25,
                                             child: Align(
                                               alignment: Alignment.center,
                                               child: Padding(
                                                 padding: const EdgeInsets.only(right: 8.0),
                                                 child: Text(
                                                     rm.matchInfo.matchDesc,
                                                     style: TextStyle(
                                                         color: Theme.of(context).textTheme.bodyText2.color,
                                                         fontSize: 12,
                                                         fontWeight: FontWeight.w700
                                                     )
                                                 ),
                                               ),
                                             ),
                                           ),
                                     ],
                                       ),
                                       Padding(
                                         padding: const EdgeInsets.only(left: 10,right: 10,bottom: 5,top: 5),
                                         child: Row(
                                           children: [
                                             Expanded(
                                               child: Container(
                                                 child: Column(
                                                   mainAxisAlignment: MainAxisAlignment.start,
                                                   crossAxisAlignment: CrossAxisAlignment.start,
                                                   children: <Widget>[
                                                 /*    Container(
                                                       margin: EdgeInsets.only(bottom: 10),
                                                       height: 60,
                                                       width: 60,
                                                       decoration: BoxDecoration(
                                                           borderRadius: BorderRadius.circular(10),
                                                           border: Border.all(color: Theme.of(context).accentColor,width: 2)
                                                       ),
                                                       child: Padding(
                                                           padding: const EdgeInsets.all(8.0),
                                                           child:
                                                           CachedNetworkImage(
                                                             imageUrl: rm.t1Img,
                                                             height: 44,
                                                             width: 44,
                                                           )
                                                       ),
                                                     ),*/
                                                     Container(
                                                       height: 35,
                                                       child: Align(
                                                         alignment: Alignment.centerLeft,
                                                         child: Text(
                                                             rm.matchInfo.team1.teamName,
                                                             style: TextStyle(
                                                                 color: Theme.of(context).textTheme.bodyText2.color,
                                                                 fontSize: 14,
                                                                 fontWeight: FontWeight.w400
                                                             )
                                                         ),
                                                       ),
                                                     ),
                                              Container(
                                                       height: 35,
                                                       child: Align(
                                                         alignment: Alignment.centerLeft,
                                                         child: Text(
                                                             rm.matchScore==null?"":rm.matchScore.team1Score==null?"":rm.matchScore.team1Score.inngs1==null?"":  "${rm.matchScore.team1Score.inngs1.runs.toString()}/${rm.matchScore.team1Score.inngs1.wickets==null?"0":rm.matchScore.team1Score.inngs1.wickets} (${rm.matchScore.team1Score.inngs1.overs.toString()})",
                                                             style: TextStyle(
                                                                 color: Theme.of(context).textTheme.bodyText2.color,
                                                                 fontSize: 12,
                                                                 fontWeight: FontWeight.w900
                                                             )
                                                         ),
                                                       ),
                                                     ),


                                                   ],
                                                 ),
                                               ),
                                             ),

                                             Expanded(
                                               child: Container(
                                                 child: Column(
                                                   mainAxisAlignment: MainAxisAlignment.start,
                                                   crossAxisAlignment: CrossAxisAlignment.end,
                                                   children: <Widget>[
                                             /*        Container(
                                                       margin: EdgeInsets.only(bottom: 10),
                                                       height: 60,
                                                       width: 60,
                                                       decoration: BoxDecoration(
                                                           borderRadius: BorderRadius.circular(10),
                                                           border: Border.all(color: Theme.of(context).accentColor,width: 2)
                                                       ),
                                                       child: Padding(
                                                           padding: const EdgeInsets.all(8.0),
                                                           child:
                                                           CachedNetworkImage(
                                                             imageUrl: match.t2Img,
                                                             height: 44,
                                                             width: 44,
                                                           )
                                                       ),
                                                     ),*/
                                                     Container(
                                                       height: 35,
                                                       child: Align(
                                                         alignment: Alignment.centerRight,
                                                         child: Text(
                                                          rm.matchInfo.team2.teamName,
                                                           textAlign: TextAlign.right,
                                                           style: TextStyle(
                                                               color: Theme.of(context).textTheme.bodyText2.color,
                                                               fontSize: 14,
                                                               fontWeight: FontWeight.w400
                                                           ),
                                                         ),
                                                       ),
                                                     ),
                                                      Container(
                                                       height: 35,
                                                       child: Align(
                                                         alignment: Alignment.centerRight,
                                                         child: Text(
                                            rm.matchScore==null?"":     rm.matchScore.team2Score==null?"":rm.matchScore.team2Score.inngs1==null?"":  "${rm.matchScore.team2Score.inngs1.runs.toString()}/${rm.matchScore.team2Score.inngs1.wickets==null?"0":rm.matchScore.team2Score.inngs1.wickets.toString()} (${rm.matchScore.team2Score.inngs1.overs.toString()})",
                                                           textAlign: TextAlign.right,
                                                           style: TextStyle(
                                                               color: Theme.of(context).textTheme.bodyText2.color,
                                                               fontSize: 12,
                                                               fontWeight: FontWeight.w900
                                                           ),
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
                                       Container(
                                         height: 25,
                                         child: Align(
                                           alignment: Alignment.center,
                                           child: Text(
                                               rm.matchInfo.status==null?"":rm.matchInfo.status,
                                               style: TextStyle(
                                                   color: Colors.green,
                                                   fontSize: 12,
                                                   fontWeight: FontWeight.w700
                                               )
                                           ),
                                         ),
                                       ),
                                       Container(
                                         height: 35,
                                         child: Align(
                                           alignment: Alignment.center,
                                           child: Text(
                                     rm.matchInfo.startDate==null?"":   HelperUtils.convertMillisecondsToIST(int.parse(rm.matchInfo.startDate)),
                                               style: TextStyle(
                                                   color: Theme.of(context).textTheme.bodyText2.color,
                                                   fontSize: 12,
                                                   fontWeight: FontWeight.w400
                                               )
                                           ),
                                         ),
                                       ),

                                       Container(
                                         height: 35,
                                         child: Align(
                                           alignment: Alignment.center,
                                           child: Text(
                                               rm.matchInfo.venueInfo==null?"":"${rm.matchInfo.venueInfo.ground}, ${rm.matchInfo.venueInfo.city}",
                                               style: TextStyle(
                                                   color: Theme.of(context).textTheme.bodyText2.color,
                                                   fontSize: 12,
                                                   fontWeight: FontWeight.w400
                                               )
                                           ),
                                         ),
                                       ),
                                     ],
                                   ),
                                 ),
                               );
                             }):SizedBox.shrink()

                           ],
                         ),
                       ),
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
                        refreshing = false;
                        _getList();
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

  buildTab(String s,int index) {
    return GestureDetector(
      onTap: (){
        setState(() {
          selected_index = index;
          if(index == 4){
           // _getMatchsList(widget.match);
          }
          if(index == 1){
           // _getStatistics(widget.match);
          }
          if(index == 3){
           // _getTables();
          }

          if(index == 0){
            //_getEvents();
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
                  fontSize: 15,
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

 /* buildContentTab() {
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
  }*/

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
  selectTables(MatchTypeData competition) {
    print("competition.id");
    print(competition.id);
    setState(() {
      selected_competition = competition;
     _getMatchsList(selected_competition);
      for(MatchTypeData c in competitionsList)
        c.selected=false;
        competition.selected=true;
    });
  }




//   Future<void>  _loadMore(Competition competition) async{
//     if(loading)
//       return null;
//
//     loading =  true;
//
//     setState(() {
//       load_more = true;
//     });
//
//     page +=1;
//     // Await the http get response, then decode the json-formatted response.
//     var response;
//     var statusCode = 200;
//     try {
//       response = await http.get(apiRest.matchesByCompetition(competition.id,page));
//     } catch (ex) {
//       statusCode = 500;
//     }
//     if(!loading)
//       return null;
//     if (statusCode == 200) {
//       if (response.statusCode == 200) {
//         var jsonData =  convert.jsonDecode(response.body);
//
//         for(Map i in jsonData){
//          // EMatch _match = EMatch.fromJson(i);
// //          matchesList.add(_match);
//
//           insertAds();
//
//         }
//         setState(() {
//           load_more = false;
//         });
//       } else {
//         setState(() {
//           load_more = false;
//         });
//       }
//     }else if(statusCode == 500){
//       setState(() {
//         load_more = false;
//       });
//     }
//     loading = false;
//   }

  // navigate(EMatch match,int _tag){
  //   match_route = MaterialPageRoute(builder: (context) => MatchDetail(match :  match,tag: _tag));
  //
  //   if( ads_interstitial_type == "BOTH" && should_be_displaed == 0) {
  //     if(adsProvider.getInterstitialLocal() == "ADMOB" && _interstitialReady ){
  //       adsProvider.setInterstitialLocal("FACEBOOK");
  //       _admobInterstitialAd.show();
  //       should_be_displaed = 1;
  //       adsProvider.setInterstitialClicksStep(should_be_displaed) ;
  //     }else if(adsProvider.getInterstitialLocal() == "FACEBOOK" && _isInterstitialAdLoaded){
  //       adsProvider.setInterstitialLocal("ADMOB");
  //       FacebookInterstitialAd.showInterstitialAd();
  //       should_be_displaed = 1;
  //       adsProvider.setInterstitialClicksStep(should_be_displaed);
  //     }else{
  //       if( adsProvider.getInterstitialLocal() == "ADMOB"){
  //         adsProvider.setInterstitialLocal("FACEBOOK");
  //       }else{
  //         adsProvider.setInterstitialLocal("ADMOB");
  //       }
  //       should_be_displaed = 1;
  //       adsProvider.setInterstitialClicksStep(should_be_displaed);
  //       Navigator.push(context, match_route);
  //     }
  //   }else if(_isInterstitialAdLoaded && ads_interstitial_type == "FACEBOOK" && should_be_displaed == 0){
  //     FacebookInterstitialAd.showInterstitialAd();
  //     should_be_displaed = 1;
  //     adsProvider.setInterstitialClicksStep(should_be_displaed);
  //   }else if(_interstitialReady && ads_interstitial_type == "ADMOB" && should_be_displaed == 0){
  //     _admobInterstitialAd.show();
  //     should_be_displaed = 1;
  //     adsProvider.setInterstitialClicksStep(should_be_displaed);
  //   }else{
  //     should_be_displaed = (should_be_displaed >= ads_interstitial_click)? 0:should_be_displaed+1;
  //     adsProvider.setInterstitialClicksStep(should_be_displaed);
  //     Navigator.push(context, match_route);
  //   }
  //
  //
  // }
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
          itemCount: widget.competitions.length ,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, int index) {
            return buildCompetition(index );
          }
      ),
    );
  }

  Widget buildCompetition(int index) {
    return GestureDetector(
      onTap: () {
        widget.action(widget.competitions[index]);
      },
      child: Container(
        margin: EdgeInsets.only(left: 10, right: 5, top: 10, bottom: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(
                color: Colors.black54.withOpacity(0.3),
                offset: Offset(0,0),
                blurRadius: 5
            )]
        ),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 500),
          curve: Curves.linearToEaseOut,
          decoration: BoxDecoration(
            color: (widget.competitions[index].selected == true)? Theme.of(context).accentColor :Theme.of(context).cardColor,
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
                Image.asset(widget.competitions[index].image,color: (widget.competitions[index].selected == true)
                    ? Colors.white
                    : Theme.of(context).textTheme.bodyText2.color
                ),
                SizedBox(width: 7),
                Text(
                  widget.competitions[index].name.toUpperCase()
                  ,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: (widget.competitions[index].selected == true)
                          ? Colors.white
                          : Theme.of(context).textTheme.bodyText2.color
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}







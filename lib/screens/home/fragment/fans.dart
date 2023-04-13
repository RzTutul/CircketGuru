
import 'dart:io';

import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:app/api/api_rest.dart';
import 'package:app/config/colors.dart';
import 'package:app/model/post.dart';
import 'package:app/model/status.dart';
import 'package:app/provider/ads_provider.dart';
import 'package:app/screens/ads/item_facebook_native.dart';
import 'package:app/screens/ads/item_native_admob.dart';
import 'package:app/screens/status/create_widget.dart';
import 'package:app/screens/status/image_detail.dart';
import 'package:app/screens/status/quote_detail.dart';
import 'package:app/screens/status/status_detail.dart';
import 'package:app/screens/status/status_widget.dart';
import 'package:app/screens/home/title_home_widget.dart';

import 'package:http/http.dart' as http;
import 'package:app/screens/loading.dart';
import 'dart:convert' as convert;

import 'package:app/screens/tryagain.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Fans extends StatefulWidget {
  @override
  _FansState createState() => _FansState();
}

class _FansState extends State<Fans> {

  List<Status> statusList = [];
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  bool loading =  false;
  bool refreshing =  true;
  String state =  "progress";
  int page =  0;
  List<Status> likedStatusList = [];
  ScrollController listViewController= new ScrollController();

  bool load_more = false;

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
  Route status_route = null;
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
          if(status_route != null)
            Navigator.push(context, status_route);
          _isInterstitialAdLoaded = false;
          _loadInterstitialAd();
        }
      },
    );
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
        statusList.add(Status(id:-5));
      }else if(native_ads_type =="FACEBOOK"){
        statusList.add(Status(id:-6));
      }else if(native_ads_type =="BOTH"){
        if(native_ads_current_type == "ADMOB"){
          statusList.add(Status(id:-5));
          native_ads_current_type = "FACEBOOK";
        }else{
          statusList.add(Status(id:-6));
          native_ads_current_type = "ADMOB";
        }
      }
    }
    native_ads_position++;
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

    initInterstitialAd();
    initNativeAd();
    listViewController.addListener(_scrollListener);
    refreshing =  false;
    _getList();
  }

  _scrollListener() {
    if (listViewController.offset >= (listViewController.position.maxScrollExtent) && !listViewController.position.outOfRange) {
      _loadMore();
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
            controller: listViewController,
            itemCount: statusList.length,
            itemBuilder: (context, index) {
              if(statusList[index] == null){
                return TitleHomeWidget(title : "Fans Area");
              }else if(statusList[index].id == -1){
                return CreateWidget();
              }else if (statusList[index].id == -5){
                return AdmobNativeAdItem(adUnitID: admob_native_ad_id);
              }else if (statusList[index].id == -6){
                return FacebookNativeAdItem(PLACEMENT_ID: facebook_native_ad_id);
              } else{
                return StatusWidget(status: statusList[index],liked : statusLiked,downloaded: addDownload,shared: addShare,viewed: addView,navigate: navigate);
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

  Future<List<Status>>  _getList() async{
    if(loading)
      return null;
    statusList.clear();
    page =0;
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
      response = await http.get(apiRest.statusByPage(page));
    } catch (ex) {
      statusCode = 500;
    }
    if(!loading)
      return null;
    if (statusCode == 200) {
      if (response.statusCode == 200) {
        var jsonData =  convert.jsonDecode(response.body);

        statusList.add(null);
        statusList.add(Status(id: -1));

        SharedPreferences prefs = await SharedPreferences.getInstance();

        String  likedStatusString=  await prefs.getString('status_liked');

        if(likedStatusString != null){
          likedStatusList = Status.decode(likedStatusString);
        }
        if(likedStatusList == null){
          likedStatusList= [];
        }

        for(Map i in jsonData){
          Status status = Status.fromJson(i);
          for(Status liked_status in likedStatusList){
            if(liked_status.id == status.id){
              status.liked = true;
            }
          }
          statusList.add(status);

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
    }else if(statusCode == 500){
      setState(() {
        state =  "error";
      });
    }
    loading = false;
    return statusList;
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
      response = await http.get(apiRest.statusByPage(page));
    } catch (ex) {
      statusCode = 500;
    }
    if(!loading)
      return null;
    if (statusCode == 200) {
      if (response.statusCode == 200) {
        var jsonData =  convert.jsonDecode(response.body);

        for(Map i in jsonData){
          Status status = Status.fromJson(i);
          for(Status liked_status in likedStatusList){
            if(liked_status.id == status.id){
              status.liked = true;
            }
          }
          statusList.add(status);
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

  statusLiked(Status status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String  favoriteStatussString=  await prefs.getString('status_liked');

    if(favoriteStatussString != null){
      likedStatusList = Status.decode(favoriteStatussString);
    }
    if(likedStatusList == null){
      likedStatusList= [];
    }

    Status liked_status =  null;

    for(Status current_status in likedStatusList){
      if(current_status.id == status.id){
        liked_status = current_status;
      }
    }

    if(liked_status == null){
      likedStatusList.add(status);
      setState(() {
        status.liked = true;
        status.likes+=1;
        _toggleLike(status,"add");

      });
    }else{
      likedStatusList.remove(liked_status);
      setState(() {
        status.liked = false;
        status.likes-=1;
        _toggleLike(status,"delete");
      });
    }
    String encodedData = Status.encode(likedStatusList);
    prefs.setString('status_liked',encodedData);
  }
  Future<String>  _toggleLike(Status status,String state) async{
    int id_ = status.id + 55463938;
    convert.Codec<String, String> stringToBase64 = convert.utf8.fuse(convert.base64);
    String id_base_64 = stringToBase64.encode(id_.toString());

    var statusCode = 200;
    var response;
    var jsonData;
    try {
      response = await http.post(apiRest.toggleLike(state), body: {'id': id_base_64});
      jsonData =  convert.jsonDecode(response.body);
    } catch (ex) {
      print(ex);
      statusCode =  500;
    }
  }

  addShare(Status status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('shared_status_' + status.id.toString()) != true) {
      prefs.setBool('shared_status_' + status.id.toString(), true);

      int id_ = status.id + 55463938;
      convert.Codec<String, String> stringToBase64 = convert.utf8.fuse(convert.base64);
      String id_base_64 = stringToBase64.encode(id_.toString());
      setState(() {
        status.shares = status.shares+1;
      });
      var statusCode = 200;
      var response;
      var jsonData;
      try {
        response = await http.post(apiRest.addStatusShare(), body: {'id': id_base_64});
        jsonData =  convert.jsonDecode(response.body);

      } catch (ex) {
        print(ex);
        statusCode =  500;
      }

    }
  }

  addView(Status status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('viewed_status_' + status.id.toString()) != true) {
      prefs.setBool('viewed_status_' + status.id.toString(), true);

      int id_ = status.id + 55463938;
      convert.Codec<String, String> stringToBase64 = convert.utf8.fuse(convert.base64);
      String id_base_64 = stringToBase64.encode(id_.toString());
      setState(() {
        status.views = status.views+1;
      });
      var statusCode = 200;
      var response;
      var jsonData;
      try {
        response = await http.post(apiRest.addStatusView(), body: {'id': id_base_64});
        jsonData =  convert.jsonDecode(response.body);

      } catch (ex) {
        print(ex);
        statusCode =  500;
      }

    }
  }
  addDownload(Status status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('downloaded_status_' + status.id.toString()) != true) {
      prefs.setBool('downloaded_status_' + status.id.toString(), true);

      int id_ = status.id + 55463938;
      convert.Codec<String, String> stringToBase64 = convert.utf8.fuse(convert.base64);
      String id_base_64 = stringToBase64.encode(id_.toString());
      setState(() {
        status.downloads = status.downloads+1;
      });
      var statusCode = 200;
      var response;
      var jsonData;
      try {
        response = await http.post(apiRest.addStatusDownload(), body: {'id': id_base_64});
        jsonData =  convert.jsonDecode(response.body);

      } catch (ex) {
        print(ex);
        statusCode =  500;
      }
    }
  }

  navigate(Status status,Function liked,Function shared,Function viewed,Function downloaded){
    if(status.kind ==  "quote"){
      status_route = MaterialPageRoute(builder: (context) => QuoteDetail(status: status,liked : liked,shared : shared,viewed:viewed ));
    }
    else if(status.kind ==  "image"){
      status_route = MaterialPageRoute(builder: (context) => ImageDetail(status: status,liked : liked,shared : shared,viewed : viewed,downloaded: downloaded));
    }else{
      status_route = MaterialPageRoute(builder: (context) => StatusDetail(status: status,liked : liked,shared: shared,viewed : viewed,downloaded: downloaded));
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
        Navigator.push(context, status_route);
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
      Navigator.push(context, status_route);
    }
  }
}

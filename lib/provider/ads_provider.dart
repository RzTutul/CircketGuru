


import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdsProvider{
  SharedPreferences prefs ;
  TargetPlatform platform ;

  AdsProvider(this.prefs, this.platform);
  String getAdmobAppId(){
    if(platform ==  TargetPlatform.android){
      return prefs.getString("android_admob_app_id");
    }else{
      return prefs.getString("ios_admob_app_id");
    }
  }
  String getAdmobPublisherId(){
    if(platform ==  TargetPlatform.android){
      return prefs.getString("android_admob_publisher_id");
    }else{
      return prefs.getString("ios_admob_publisher_id");
    }
  }
  String getBannerAdmobId(){
    if(platform ==  TargetPlatform.android){
      return prefs.getString("android_ads_banner_admob_id");
    }else{
      return prefs.getString("ios_ads_banner_admob_id");
    }
  }
  String getBannerFacebookId(){
    if(platform ==  TargetPlatform.android){
      return prefs.getString("android_ads_banner_facebook_id");
    }else{
      return prefs.getString("ios_ads_banner_facebook_id");
    }
  }
  String  getBannerType(){
    if(platform ==  TargetPlatform.android){
      return prefs.getString("android_ads_banner_type");
    }else{
      return  prefs.getString("ios_ads_banner_type");
    }
  }


  String getNativeAdmobId(){
    if(platform ==  TargetPlatform.android){
      return prefs.getString("android_ads_native_admob_id");
    }else{
      return prefs.getString("ios_ads_native_admob_id");
    }
  }
  String getNativeFacebookId(){
    if(platform ==  TargetPlatform.android){
      return prefs.getString("android_ads_native_facebook_id");
    }else{
      return prefs.getString("ios_ads_native_facebook_id");
    }
  }
  String  getNativeType(){
    if(platform ==  TargetPlatform.android){
      return prefs.getString("android_ads_native_type");
    }else{
      return  prefs.getString("ios_ads_native_type");
    }
  }

  int  getNativeItem(){
    if(platform ==  TargetPlatform.android){
      return prefs.getInt("android_ads_native_item");
    }else{
      return  prefs.getInt("ios_ads_native_item");
    }
  }


  String  getAdmobInterstitialId(){
    if(platform ==  TargetPlatform.android){
      return prefs.getString("android_ads_interstitial_admob_id");
    }else{
      return  prefs.getString("ios_ads_interstitial_admob_id");
    }
  }
  String  getFacebookInterstitialId(){
    if(platform ==  TargetPlatform.android){
      return prefs.getString("android_ads_interstitial_facebook_id");
    }else{
      return  prefs.getString("ios_ads_interstitial_facebook_id");
    }
  }
  String getInterstitialType(){
    if(platform ==  TargetPlatform.android){
      return prefs.getString("android_ads_interstitial_type");
    }else{
      return prefs.getString("ios_ads_interstitial_type");
    }
  }
  int getInterstitialClicks(){
    if(platform ==  TargetPlatform.android){
      return prefs.getInt("android_ads_interstitial_click");
    }else{
      return prefs.getInt("ios_ads_interstitial_click");
    }
  }

   setInterstitialLocal(String val) {
    prefs.setString("ads_interstitial_local",val);
  }
  String getInterstitialLocal() {

      return (prefs.getString("ads_interstitial_local") == null)? "FACEBOOK" : prefs.getString("ads_interstitial_local");

  }
  String getBannerLocal() {
    return (prefs.getString("ads_banner_local") == null)? "FACEBOOK" : prefs.getString("ads_banner_local");
  }
  setBannerLocal(String val) {
    prefs.setString("ads_banner_local",val);
  }
  void setInterstitialClicksStep(int ads_interstitial_click_steps) {
    prefs.setInt("ads_interstitial_click_steps",ads_interstitial_click_steps);
  }
  int getInterstitialClicksStep(){
    int c= prefs.getInt("ads_interstitial_click_steps");
    return (c == null || c ==0 )? 1:c;
  }
}
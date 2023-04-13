import 'package:facebook_audience_network/ad/ad_native.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FacebookNativeAdItem extends StatelessWidget {
  String PLACEMENT_ID;

  FacebookNativeAdItem({this.PLACEMENT_ID});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(
              color: Colors.black54.withOpacity(0.2),
              offset: Offset(0,0),
              blurRadius: 5
          )]
      ),
      padding: EdgeInsets.all(5),
      child: FacebookNativeAd(
        placementId: PLACEMENT_ID,
        adType: NativeAdType.NATIVE_AD_HORIZONTAL,
        bannerAdSize: NativeBannerAdSize.HEIGHT_120,
        width: double.infinity,
        backgroundColor: Theme.of(context).cardColor,
        titleColor:Theme.of(context).textTheme.subtitle1.color,
        descriptionColor: Theme.of(context).textTheme.subtitle2.color,
        buttonColor: Theme.of(context).accentColor,
        buttonTitleColor: Colors.white,
        expandAnimationDuraion: 300,
        keepExpandedWhileLoading: false,
        keepAlive: true,
        buttonBorderColor: Theme.of(context).textTheme.subtitle1.color,
        listener: (result, value) {
          print("Native Ad: $result --> $value");
        },
      ),
    );
  }
}
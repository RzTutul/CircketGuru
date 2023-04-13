import 'dart:math';

import 'package:action_broadcast/action_broadcast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:app/config/colors.dart';
import 'package:app/model/match.dart';
import 'package:app/screens/home/live_widget.dart';
import 'package:app/screens/matches/match_detail.dart';
import 'package:url_launcher/url_launcher.dart';


class MatchWidget extends StatelessWidget {
  Match match;
  int tag = new Random().nextInt(100);
  MatchWidget({this.match});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Route route = MaterialPageRoute(builder: (context) => MatchDetail(match :  match,tag : tag));
        Navigator.push(context, route);
      },
      child: Hero(
        tag: "hero_match_"+ match.id.toString()+"_"+tag.toString(),
        transitionOnUserGestures: true,
        child: Material(
          type: MaterialType.transparency, // likely needed
          child: Container(
            margin: EdgeInsets.only(top: 5,bottom: 5),
            height: 130,
            width: MediaQuery.of(context).size.width,
            child:Stack(
              children: <Widget>[
                Positioned(
                  bottom: 0,
                  left: 10,
                  right: 10,
                  child: Container(
                      height:110,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Theme.of(context).cardColor,
                          boxShadow: [BoxShadow(
                              color: Colors.black54.withOpacity(0.2),
                              offset: Offset(0,0),
                              blurRadius: 5
                          )]
                      )
                  ),
                ),
                Positioned(
                  left: 30,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(bottom: 15),
                        height: 75,
                        width: 75,
                        decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            border: Border.all(color: Theme.of(context).accentColor,width: 2),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [BoxShadow(
                                color: Colors.black54.withOpacity(0.2),
                                offset: Offset(0,0),
                                blurRadius: 5
                            )]
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CachedNetworkImage(
                            imageUrl: match.homeclub.image,
                            height: 59,
                            width: 59,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 30,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Container(

                        margin: EdgeInsets.only(bottom: 15),
                        height: 75,
                        width: 75,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Theme.of(context).cardColor,
                          border: Border.all(color: Theme.of(context).accentColor,width: 2),
                            boxShadow: [BoxShadow(
                                color: Colors.black54.withOpacity(0.2),
                                offset: Offset(0,0),
                                blurRadius: 5,
                            )],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child:
                            CachedNetworkImage(
                              imageUrl: match.awayclub.image,
                              height: 59,
                              width: 59,
                            )
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                    left: (MediaQuery.of(context).size.width/2)-15,
                    child: Container(
                      padding: EdgeInsets.all(5),
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Theme.of(context).cardColor,
                          boxShadow: [BoxShadow(
                              color: Colors.black54.withOpacity(0.2),
                              offset: Offset(0,0),
                              blurRadius: 5
                          )]
                      ),
                      child:   CachedNetworkImage(
                        imageUrl: match.competition.image,
                        height: 20,
                        width: 20,
                        color:  Theme.of(context).textTheme.bodyText2.color,
                      )
                    )
                ),
                Positioned(
                    left: 30,
                    right: 30,
                    bottom: 10,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                            child: Container(
                                child:  Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    match.homeclub.name,
                                    style: TextStyle(
                                        color: Theme.of(context).textTheme.bodyText2.color,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400
                                    )),
                                ),
                                height: 50,
                            )
                        ),
                        Expanded(
                            child:
                            Container(
                                child: buildDetail(context),
                            )
                        ),
                        Expanded(
                            child: Container(
                              child:
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  match.awayclub.name,
                                  maxLines: 2,
                                  textAlign: TextAlign.right,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Theme.of(context).textTheme.bodyText2.color,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400
                                  ),
                                ),
                              ),
                              height: 50,
                            )
                        )
                      ],
                    )
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  buildEnded(BuildContext context){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if(match.homeresult!= null && match.awayresult != null)
          Text(
            match.homeresult + " - "+match.awayresult,
            style: TextStyle(
                color: Theme.of(context).textTheme.bodyText1.color,
                fontSize: 16,
                fontWeight: FontWeight.w800
            ),
          ),
        if(match.homesubresult!= null && match.awaysubresult != null)
          Text(
            match.homesubresult + " - "+match.awaysubresult,
            style: TextStyle(
                color: Theme.of(context).textTheme.bodyText2.color,
                fontSize: 12,
                fontWeight: FontWeight.w800
            ),
          ),
        if(match.highlights != null)
          TextButton.icon(

            style: TextButton.styleFrom(
              padding: EdgeInsets.all(5),
              textStyle: TextStyle(
                color: Theme.of(context).accentColor,
              )
            ),
              onPressed: (){
                _launchURL(match.highlights);

              },
              icon: Icon(LineIcons.play,size: 11,color: Colors.white ),
              label: Text("Highlights",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 11
                ),)
          )
        else
          Padding(
            padding: const EdgeInsets.only(top:8.0),
            child: Text(
              match.time + match.date,
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
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if(match.homeresult!= null && match.awayresult != null)
          Text(
            match.homeresult + " - "+match.awayresult,
            style: TextStyle(
                color: Theme.of(context).textTheme.bodyText1.color,
                fontSize: 16,
                fontWeight: FontWeight.w800
            ),
          ),
        if(match.homesubresult!= null && match.awaysubresult != null)
          Text(
            match.homesubresult + " - "+match.awaysubresult,
            style: TextStyle(
                color: Theme.of(context).textTheme.bodyText2.color,
                fontSize: 12,
                fontWeight: FontWeight.w800
            ),
          ),
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
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[

        Text(
          match.time,
          style: TextStyle(
              color: Theme.of(context).accentColor,
              fontWeight: FontWeight.w900,
              fontSize: 19
          ),
        ),
        SizedBox(height: 5),
        Text(
          match.date,
          style: TextStyle(
              color: Theme.of(context).textTheme.bodyText1.color,
              fontWeight: FontWeight.w500,
              fontSize: 11
          ),
        ),
        if(match.stadium != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset("assets/images/stadium.png",color: Theme.of(context).textTheme.bodyText2.color,height: 18,width:18),
              SizedBox(width: 5),
              Flexible(
                child: Text(
                  match.stadium,
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
  buildCanceled(BuildContext context){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          "Canceled",
          style: TextStyle(
            color: Theme.of(context).accentColor,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        Text(
          match.time,
          style: TextStyle(
              color: Theme.of(context).accentColor,
              fontWeight: FontWeight.w900,
              fontSize: 15,
              decoration: TextDecoration.lineThrough
          ),
        ),
        SizedBox(height: 5),
        Text(
          match.date,
          style: TextStyle(
              color: Theme.of(context).textTheme.bodyText1.color,
              fontWeight: FontWeight.w500,
              fontSize: 11,
              decoration: TextDecoration.lineThrough
          ),
        ),
        SizedBox(height: 5),
        if(match.stadium != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/stadium.png",color: Theme.of(context).textTheme.bodyText2.color,height: 18,width:18),
              SizedBox(width: 5),
              Flexible(
                child: Text(
                  match.stadium,
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
        Text(
          "Postponed",
          style: TextStyle(
            color: Theme.of(context).accentColor,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        Text(
          match.time,
          style: TextStyle(
              color: Theme.of(context).accentColor,
              fontWeight: FontWeight.w900,
              fontSize: 15,
              decoration: TextDecoration.lineThrough
          ),
        ),
        SizedBox(height: 5),
        Text(
          match.date,
          style: TextStyle(
              color: Theme.of(context).textTheme.bodyText1.color,
              fontWeight: FontWeight.w500,
              fontSize: 11,
              decoration: TextDecoration.lineThrough
          ),
        ),
        if(match.stadium != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/stadium.png",color: Theme.of(context).textTheme.bodyText2.color,height: 18,width:18),
              SizedBox(width: 5),
              Flexible(
                child: Text(
                  match.stadium,
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

  buildDetail(BuildContext context) {
    switch(match.state){
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
  _launchURL(String url) async {

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

}

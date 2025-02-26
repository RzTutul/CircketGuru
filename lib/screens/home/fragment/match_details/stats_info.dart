import 'package:app/api/api_rest.dart';
import 'package:app/model/match_stats_response.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../../loading.dart';
import '../../../tryagain.dart';

class Stats extends StatefulWidget {
   Stats(this.matchId);
  final String matchId;


  @override
  State<Stats> createState() => _StatsState();
}

class _StatsState extends State<Stats> {
  List<Matchst> matchst;

  String state_matches = "progress";

  @override
  void initState() {
    _getMatchStats();
    super.initState();
  }


  _getMatchStats() async {
    var response;
    var statusCode = 200;
    try {
      response = await apiRest.getMatchStats(widget.matchId);
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
        matchst = MatchStatsResponse.fromJson(response.body.toString()).matchst;
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
  @override
  Widget build(BuildContext context) {
    switch (state_matches) {
      case "success":
        return matchst.length>0? new DefaultTabController(
          length: 3,
          child: new Scaffold(
            appBar: new PreferredSize(
              preferredSize: Size.fromHeight(kToolbarHeight),
              child: new Container(
                height: 50.0,
                child: new TabBar(

                  tabs: [
                    Tab(text: "${matchst[0].stat1Name}",),
                    Tab(text: "${matchst[0].stat2Name}",),
                    Tab(text: "${matchst[0].stat3Name}",),

                  ],
                ),
              ),
            ),
            body: TabBarView(
              children: [
                Container(

                  child: ListView(
                    children: [
                      Html(data:"${matchst[0].stat1Descr}"),
                    ],
                  ),
                ),
                Container(
                  child: ListView(
                    children: [
                      Html(data: "${matchst[0].stat2Descr}"),
                    ],
                  ),
                ),
                Container(
                  child: ListView(
                    children: [
                      Html(data:"${matchst[0].stat3Descr}"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ):SizedBox.shrink();
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
            _getMatchStats();
          }),
        );

  }
}}

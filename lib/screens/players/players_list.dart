
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:line_icons/line_icons.dart';
import 'package:app/api/api_rest.dart';
import 'package:app/config/colors.dart';
import 'package:app/model/player.dart';
import 'package:app/model/position.dart';
import 'package:http/http.dart' as http;
import 'package:app/model/team.dart';
import 'package:app/screens/loading.dart';
import 'dart:convert' as convert;

import 'package:app/screens/players/player_widget.dart';
import 'package:app/screens/tryagain.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlayersList extends StatefulWidget {

  Team team;
  PlayersList({this.team});

  @override
  _PlayersListState createState() => _PlayersListState();
}

class _PlayersListState extends State<PlayersList> {





  List<Position> positionsList = [];
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  bool loading =  false;
  String state =  "progress";

  String _applogo ="";

  @override
  void initState() {
    // TODO: implement initState
    _getList();
    super.initState();
    initAppInfos();
  }
  Widget buildHome() {
    switch(state){
      case "success":
        return RefreshIndicator(
          backgroundColor: Theme.of(context).primaryColor,
          key: refreshKey,
          onRefresh:_getList,
          child: ListView.builder(
              itemCount: positionsList.length,
              itemBuilder: (context, index) {
                return buildPosition(positionsList[index]);
              }
          ),
        );
        break;
      case "progress":
        return LoadingWidget();
        break;
      case "error":
        return TryAgainButton();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: false,
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color:  Theme.of(context).textTheme.bodyText1.color),
          leading: new IconButton(
            icon: new Icon(LineIcons.angleLeft),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(widget.team.title),
          elevation: 0.0
      ),
      body: Padding(
        padding:const EdgeInsets.symmetric(horizontal: 5),
        child: buildHome(),
      ),
    );
  }
  Future<List<Position>>  _getList() async{
    if(loading)
      return null;
    positionsList.clear();
    loading =  true;

    state =  "progress";

    var response;
    try {
      response = await http.get(apiRest.getPlayersByTeam(widget.team.id));
    } catch (ex) {
      loading = false;
      setState(() {
        state =  "error";
      });
    }
    if(!loading)
      return null;

    if (response.statusCode == 200) {
      var data  = await http.get(apiRest.getPlayersByTeam(widget.team.id));
      var jsonData =  convert.jsonDecode(data.body);
      for(Map i in jsonData){
        Position position = Position.fromJson(i);
        positionsList.add(position);
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
    return positionsList;
  }
  Widget buildPosition(Position position) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left:7.0,top: 10),
            child: Text(
              position.title,
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyText2.color,
                  fontWeight: FontWeight.w700,
                  fontSize: 17
              ),
            ),
          ),
          Padding(
              padding: const EdgeInsets.only(left:7.0),
              child: Container(
                margin: EdgeInsets.only(top: 5,bottom: 10),
                color:  Theme.of(context).textTheme.bodyText2.color,
                height: 4,
                width: 40,
              )),
          GridView.count(
              primary: false,
              shrinkWrap: true,
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              children:List.generate(position.players.length, (index) => PlayerWidget(player: position.players[index],bgimage:_applogo  ))
          ),
        ]);
  }
  Future initAppInfos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _applogo =  prefs.getString("app_logo");
    });
    return _applogo;
  }
}



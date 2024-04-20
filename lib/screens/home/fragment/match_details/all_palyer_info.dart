import 'dart:convert';

import 'package:app/api/api_rest.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../model/all_player_response.dart';
import '../../../loading.dart';
import '../../../tryagain.dart';

class AllPlayer extends StatefulWidget {
  const AllPlayer(this.matchId, {Key key}) : super(key: key);
  final String matchId;

  @override
  State<AllPlayer> createState() => _AllPlayerState();
}

class _AllPlayerState extends State<AllPlayer> {
  List<Playerslist> playerList = [];
  String state_matches = "progress";
   List<Map<String, dynamic>> playersListdata = [];

  @override
  void initState() {
    _getAllPlayer();
    super.initState();
  }

  _getAllPlayer() async {
    var response;
    var statusCode = 200;
    try {
      response = await apiRest.getAllPlayer(widget.matchId);
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
        playerList = AllPlayerResponse.fromJson(response.body.toString()).playerslist;
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
        Map<String, List<Playerslist>> playersByTeam = {};
        for (var player in playerList) {
          String teamName = player.teamName + " " + player.teamRuns;
          if (!playersByTeam.containsKey(teamName)) {
            playersByTeam[teamName] = [];
          }
          playersByTeam[teamName]?.add(player);
        }
        return DefaultTabController(
          length: playersByTeam.length,
          child: Scaffold(
            body: Column(
              children: [
                TabBar(
                  isScrollable: false,
                  tabs: playersByTeam.keys.map((teamName) {
                    return Tab(text: teamName);
                  }).toList(),
                ),
                Expanded(
                  child: TabBarView(
                    children: playersByTeam.entries.map((entry) {
                      String teamName = entry.key;
                      List<Playerslist> teamPlayers = entry.value;
                      return  Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                    flex: 6,
                                    child: Text(
                                      "Player",
                                      style: TextStyle(
                                          color: Colors.white, fontWeight: FontWeight.w700),
                                    )),
                                Expanded(
                                    flex: 1,
                                    child: Text(
                                      "R",
                                      style: TextStyle(
                                          color: Colors.white, fontWeight: FontWeight.w700),
                                    )),
                                Expanded(
                                    flex: 1,
                                    child: Text(
                                      "B",
                                      style: TextStyle(
                                          color: Colors.white, fontWeight: FontWeight.w700),
                                    )),
                                Expanded(
                                    flex: 1,
                                    child: Text(
                                      "4s",
                                      style: TextStyle(
                                          color: Colors.white, fontWeight: FontWeight.w700),
                                    )),
                                Expanded(
                                    flex: 1,
                                    child: Text(
                                      "6s",
                                      style: TextStyle(
                                          color: Colors.white, fontWeight: FontWeight.w700),
                                    )),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                final player = teamPlayers[index];

                                return Container(
                                    margin: EdgeInsets.only(bottom: 10, left: 10, right: 10),
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 6,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: CachedNetworkImage(
                                                    imageUrl:
                                                    "http://cricnet.co.in/ManagePlaying/PlayerImage/${player.playerImage}",
                                                    width: 50,
                                                    height: 50,
                                                    imageBuilder: (context, imageProvider) =>
                                                        Container(
                                                          width: 50,
                                                          height: 50,
                                                          decoration: BoxDecoration(
                                                            shape: BoxShape.circle,
                                                            image: DecorationImage(
                                                              image: imageProvider,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        )),
                                              ),
                                              Expanded(
                                                flex: 4,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(player.playerName,
                                                        style: TextStyle(
                                                            fontWeight: FontWeight.bold)),
                                                    Text(player.outby,
                                                        style: TextStyle(color: Colors.grey)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                            flex: 1,
                                            child: Text(player.runs.toString(),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                )
                                            )),
                                        Expanded(
                                          flex: 1,
                                          child: Text(player.balls.toString(),   style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          )),),
                                        Expanded(
                                            flex: 1,
                                            child: Text(player.four.toString(),   style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ))),
                                        Expanded(
                                            flex: 1,
                                            child: Text(player.six.toString(),   style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ))),
                                      ],
                                    ));
                              },
                              itemCount: teamPlayers.length,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
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
            _getAllPlayer();
          }),
        );
    }

  }
}

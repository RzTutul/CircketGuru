import 'dart:convert';

class AllPlayerResponse {
  List<Playerslist> playerslist;
  dynamic allMatch;
  bool success;
  String msg;

  AllPlayerResponse({
    this.playerslist,
    this.allMatch,
    this.success,
    this.msg,
  });

  factory AllPlayerResponse.fromJson(String str) => AllPlayerResponse.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory AllPlayerResponse.fromMap(Map<String, dynamic> json) => AllPlayerResponse(
    playerslist: List<Playerslist>.from(json["Playerslist"].map((x) => Playerslist.fromMap(x))),
    allMatch: json["AllMatch"],
    success: json["success"],
    msg: json["msg"],
  );

  Map<String, dynamic> toMap() => {
    "Playerslist": List<dynamic>.from(playerslist.map((x) => x.toMap())),
    "AllMatch": allMatch,
    "success": success,
    "msg": msg,
  };
}

class Playerslist {
  String teamName;
  String playerName;
  int matchId;
  String teamRuns;
  String playerImage;
  int runs;
  String teamSide;
  int balls;
  int four;
  int six;
  int seqno;
  String outby;
  int inning;
  int isnotout;

  Playerslist({
    this.teamName,
    this.playerName,
    this.matchId,
    this.teamRuns,
    this.playerImage,
    this.runs,
    this.teamSide,
    this.balls,
    this.four,
    this.six,
    this.seqno,
    this.outby,
    this.inning,
    this.isnotout,
  });

  factory Playerslist.fromJson(String str) => Playerslist.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Playerslist.fromMap(Map<String, dynamic> json) => Playerslist(
    teamName: json["TeamName"],
    playerName: json["PlayerName"],
    matchId: json["MatchId"],
    teamRuns:json["TeamRuns"],
    playerImage: json["PlayerImage"],
    runs: json["Runs"],
    teamSide:json["TeamSide"],
    balls: json["Balls"],
    four: json["four"],
    six: json["six"],
    seqno: json["seqno"],
    outby: json["outby"],
    inning: json["inning"],
    isnotout: json["isnotout"],
  );

  Map<String, dynamic> toMap() => {
    "TeamName": teamName,
    "PlayerName": playerName,
    "MatchId": matchId,
    "TeamRuns": teamRuns,
    "PlayerImage": playerImage,
    "Runs": runs,
    "TeamSide": teamSide,
    "Balls": balls,
    "four": four,
    "six": six,
    "seqno": seqno,
    "outby": outby,
    "inning": inning,
    "isnotout": isnotout,
  };
}

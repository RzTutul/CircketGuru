import 'dart:convert';

class MatchStatsResponse {
  List<Matchst> matchst;
  bool success;
  String msg;

  MatchStatsResponse({
    this.matchst,
    this.success,
    this.msg,
  });

  factory MatchStatsResponse.fromJson(String str) => MatchStatsResponse.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory MatchStatsResponse.fromMap(Map<String, dynamic> json) => MatchStatsResponse(
    matchst: List<Matchst>.from(json["Matchst"].map((x) => Matchst.fromMap(x))),
    success: json["success"],
    msg: json["msg"],
  );

  Map<String, dynamic> toMap() => {
    "Matchst": List<dynamic>.from(matchst.map((x) => x.toMap())),
    "success": success,
    "msg": msg,
  };
}

class Matchst {
  String matchname;
  String stat1Name;
  String stat2Name;
  String stat3Name;
  String stat1Descr;
  String stat2Descr;
  String stat3Descr;
  int matchId;

  Matchst({
    this.matchname,
    this.stat1Name,
    this.stat2Name,
    this.stat3Name,
    this.stat1Descr,
    this.stat2Descr,
    this.stat3Descr,
    this.matchId,
  });

  factory Matchst.fromJson(String str) => Matchst.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Matchst.fromMap(Map<String, dynamic> json) => Matchst(
    matchname: json["matchname"],
    stat1Name: json["stat1name"],
    stat2Name: json["stat2name"],
    stat3Name: json["stat3name"],
    stat1Descr: json["stat1descr"],
    stat2Descr: json["stat2descr"],
    stat3Descr: json["stat3descr"],
    matchId: json["MatchId"],
  );

  Map<String, dynamic> toMap() => {
    "matchname": matchname,
    "stat1name": stat1Name,
    "stat2name": stat2Name,
    "stat3name": stat3Name,
    "stat1descr": stat1Descr,
    "stat2descr": stat2Descr,
    "stat3descr": stat3Descr,
    "MatchId": matchId,
  };
}

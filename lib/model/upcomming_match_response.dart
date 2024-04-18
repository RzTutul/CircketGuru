import 'dart:convert';

class UpcommingResponse {
  dynamic playerslist;
  List<AllMatch> allMatch;
  bool success;
  String msg;

  UpcommingResponse({
    this.playerslist,
    this.allMatch,
    this.success,
    this.msg,
  });

  factory UpcommingResponse.fromJson(String str) => UpcommingResponse.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory UpcommingResponse.fromMap(Map<String, dynamic> json) => UpcommingResponse(
    playerslist: json["Playerslist"],
    allMatch: List<AllMatch>.from(json["AllMatch"].map((x) => AllMatch.fromMap(x))),
    success: json["success"],
    msg: json["msg"],
  );

  Map<String, dynamic> toMap() => {
    "Playerslist": playerslist,
    "AllMatch": List<dynamic>.from(allMatch.map((x) => x.toMap())),
    "success": success,
    "msg": msg,
  };
}

class AllMatch {
  String title;
  String matchtime;
  String venue;
  int matchId;
  String teamA;
  String teamB;
  String teamAImage;
  dynamic matchtype;
  String teamBImage;
  dynamic result;
  String imageUrl;

  AllMatch({
    this.title,
    this.matchtime,
    this.venue,
    this.matchId,
    this.teamA,
    this.teamB,
    this.teamAImage,
    this.matchtype,
    this.teamBImage,
    this.result,
    this.imageUrl,
  });

  factory AllMatch.fromJson(String str) => AllMatch.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory AllMatch.fromMap(Map<String, dynamic> json) => AllMatch(
    title: json["Title"],
    matchtime: json["Matchtime"],
    venue: json["Venue"],
    matchId: json["MatchId"],
    teamA: json["TeamA"],
    teamB: json["TeamB"],
    teamAImage: json["TeamAImage"],
    matchtype: json["Matchtype"],
    teamBImage: json["TeamBImage"],
    result: json["Result"],
    imageUrl: json["ImageUrl"],
  );

  Map<String, dynamic> toMap() => {
    "Title": title,
    "Matchtime": matchtime,
    "Venue": venue,
    "MatchId": matchId,
    "TeamA": teamA,
    "TeamB": teamB,
    "TeamAImage": teamAImage,
    "Matchtype": matchtype,
    "TeamBImage": teamBImage,
    "Result": result,
    "ImageUrl": imageUrl,
  };
}

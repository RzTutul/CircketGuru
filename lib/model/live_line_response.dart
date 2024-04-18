import 'dart:convert';



class MatchLiveData {
  String jsonruns;
  String jsondata;
  String title;
  String matchtime;
  String venue;
  String result;
  int isfinished;
  int ispriority;
  String teamA;
  String teamAImage;
  String teamB;
  int seriesid;
  String teamBImage;
  String imgeUrl;
  String matchType;
  String matchDate;
  int matchId;
  dynamic appversion;
  String adphone;
  String adimage;
  String admsg;

  MatchLiveData({
    this.jsonruns,
    this.jsondata,
    this.title,
    this.matchtime,
    this.venue,
    this.result,
    this.isfinished,
    this.ispriority,
    this.teamA,
    this.teamAImage,
    this.teamB,
    this.seriesid,
    this.teamBImage,
    this.imgeUrl,
    this.matchType,
    this.matchDate,
    this.matchId,
    this.appversion,
    this.adphone,
    this.adimage,
    this.admsg,
  });

  factory MatchLiveData.fromJson(String str) => MatchLiveData.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory MatchLiveData.fromMap(Map<String, dynamic> json) => MatchLiveData(
    jsonruns: json["jsonruns"],
    jsondata: json["jsondata"],
    title: json["Title"],
    matchtime: json["Matchtime"],
    venue: json["venue"],
    result: json["Result"],
    isfinished: json["isfinished"],
    ispriority: json["ispriority"],
    teamA: json["TeamA"],
    teamAImage: json["TeamAImage"],
    teamB: json["TeamB"],
    seriesid: json["seriesid"],
    teamBImage: json["TeamBImage"],
    imgeUrl: json["ImgeURL"],
    matchType: json["MatchType"],
    matchDate: json["MatchDate"],
    matchId: json["MatchId"],
    appversion: json["Appversion"],
    adphone: json["adphone"],
    adimage: json["adimage"],
    admsg: json["admsg"],
  );

  Map<String, dynamic> toMap() => {
    "jsonruns": jsonruns,
    "jsondata": jsondata,
    "Title": title,
    "Matchtime": matchtime,
    "venue": venue,
    "Result": result,
    "isfinished": isfinished,
    "ispriority": ispriority,
    "TeamA": teamA,
    "TeamAImage": teamAImage,
    "TeamB": teamB,
    "seriesid": seriesid,
    "TeamBImage": teamBImage,
    "ImgeURL": imgeUrl,
    "MatchType": matchType,
    "MatchDate": matchDate,
    "MatchId": matchId,
    "Appversion": appversion,
    "adphone": adphone,
    "adimage": adimage,
    "admsg": admsg,
  };
}

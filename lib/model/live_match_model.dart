// To parse this JSON data, do
//
//     final liveMatchResponse = liveMatchResponseFromMap(jsonString);

import 'dart:convert';

class LiveMatchResponse {
  LiveMatchResponse({
    this.apikey,
    this.data,
    this.status,
    this.info,
  });

  String apikey;
  List<LiveMatchData> data;
  String status;
  Info info;

  factory LiveMatchResponse.fromJson(String str) => LiveMatchResponse.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory LiveMatchResponse.fromMap(Map<String, dynamic> json) => LiveMatchResponse(
    apikey: json["apikey"],
    data: List<LiveMatchData>.from(json["data"].map((x) => LiveMatchData.fromMap(x))),
    status: json["status"],
    info: Info.fromMap(json["info"]),
  );

  Map<String, dynamic> toMap() => {
    "apikey": apikey,
    "data": List<dynamic>.from(data.map((x) => x.toMap())),
    "status": status,
    "info": info.toMap(),
  };
}

class LiveMatchData {
  LiveMatchData({
    this.id,
    this.name,
    this.status,
    this.venue,
    this.date,
    this.dateTimeGmt,
    this.teams,
    this.teamInfo,
    this.score,
    this.seriesId,
    this.fantasyEnabled,
    this.bbbEnabled,
    this.hasSquad,
    this.matchStarted,
    this.matchEnded,
    this.matchType,
  });

  String id;
  String name;
  String status;
  String venue;
  DateTime date;
  DateTime dateTimeGmt;
  List<String> teams;
  List<TeamInfo> teamInfo;
  List<Score> score;
  String seriesId;
  bool fantasyEnabled;
  bool bbbEnabled;
  bool hasSquad;
  bool matchStarted;
  bool matchEnded;
  MatchType matchType;

  factory LiveMatchData.fromJson(String str) => LiveMatchData.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory LiveMatchData.fromMap(Map<String, dynamic> json) => LiveMatchData(
    id: json["id"],
    name: json["name"],
    status: json["status"],
    venue: json["venue"],
    date: DateTime.parse(json["date"]),
    dateTimeGmt: DateTime.parse(json["dateTimeGMT"]),
    teams: List<String>.from(json["teams"].map((x) => x)),
    teamInfo: List<TeamInfo>.from(json["teamInfo"].map((x) => TeamInfo.fromMap(x))),
    score: List<Score>.from(json["score"].map((x) => Score.fromMap(x))),
    seriesId: json["series_id"],
    fantasyEnabled: json["fantasyEnabled"],
    bbbEnabled: json["bbbEnabled"],
    hasSquad: json["hasSquad"],
    matchStarted: json["matchStarted"],
    matchEnded: json["matchEnded"],
    matchType: matchTypeValues.map[json["matchType"]],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "name": name,
    "status": status,
    "venue": venue,
    "date": "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
    "dateTimeGMT": dateTimeGmt.toIso8601String(),
    "teams": List<dynamic>.from(teams.map((x) => x)),
    "teamInfo": List<dynamic>.from(teamInfo.map((x) => x.toMap())),
    "score": List<dynamic>.from(score.map((x) => x.toMap())),
    "series_id": seriesId,
    "fantasyEnabled": fantasyEnabled,
    "bbbEnabled": bbbEnabled,
    "hasSquad": hasSquad,
    "matchStarted": matchStarted,
    "matchEnded": matchEnded,
    "matchType": matchTypeValues.reverse[matchType],
  };
}

enum MatchType { T20, ODI }

final matchTypeValues = EnumValues({
  "odi": MatchType.ODI,
  "t20": MatchType.T20
});

class Score {
  Score({
    this.r,
    this.w,
    this.o,
    this.inning,
  });

  int r;
  int w;
  double o;
  String inning;

  factory Score.fromJson(String str) => Score.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Score.fromMap(Map<String, dynamic> json) => Score(
    r: json["r"],
    w: json["w"],
    o: json["o"].toDouble(),
    inning: json["inning"],
  );

  Map<String, dynamic> toMap() => {
    "r": r,
    "w": w,
    "o": o,
    "inning": inning,
  };
}

class TeamInfo {
  TeamInfo({
    this.name,
    this.shortname,
    this.img,
  });

  String name;
  String shortname;
  String img;

  factory TeamInfo.fromJson(String str) => TeamInfo.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory TeamInfo.fromMap(Map<String, dynamic> json) => TeamInfo(
    name: json["name"],
    shortname: json["shortname"],
    img: json["img"],
  );

  Map<String, dynamic> toMap() => {
    "name": name,
    "shortname": shortname,
    "img": img,
  };
}

class Info {
  Info({
    this.hitsToday,
    this.hitsUsed,
    this.hitsLimit,
    this.credits,
    this.server,
    this.offsetRows,
    this.totalRows,
    this.queryTime,
    this.s,
    this.cache,
  });

  int hitsToday;
  int hitsUsed;
  int hitsLimit;
  int credits;
  int server;
  int offsetRows;
  int totalRows;
  double queryTime;
  int s;
  int cache;

  factory Info.fromJson(String str) => Info.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Info.fromMap(Map<String, dynamic> json) => Info(
    hitsToday: json["hitsToday"],
    hitsUsed: json["hitsUsed"],
    hitsLimit: json["hitsLimit"],
    credits: json["credits"],
    server: json["server"],
    offsetRows: json["offsetRows"],
    totalRows: json["totalRows"],
    queryTime: json["queryTime"].toDouble(),
    s: json["s"],
    cache: json["cache"],
  );

  Map<String, dynamic> toMap() => {
    "hitsToday": hitsToday,
    "hitsUsed": hitsUsed,
    "hitsLimit": hitsLimit,
    "credits": credits,
    "server": server,
    "offsetRows": offsetRows,
    "totalRows": totalRows,
    "queryTime": queryTime,
    "s": s,
    "cache": cache,
  };
}

class EnumValues<T> {
  Map<String, T> map;
   Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}

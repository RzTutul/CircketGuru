// To parse this JSON data, do
//
//     final recentMatchResponse = recentMatchResponseFromMap(jsonString);

import 'dart:convert';

class RecentMatchResponse {
  RecentMatchResponse({
    this.typeMatches,
    this.filters,
    this.appIndex,
    this.responseLastUpdated,
  });

  List<TypeMatch> typeMatches;
  Filters filters;
  AppIndex appIndex;
  String responseLastUpdated;

  factory RecentMatchResponse.fromJson(String str) => RecentMatchResponse.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory RecentMatchResponse.fromMap(Map<String, dynamic> json) => RecentMatchResponse(
    typeMatches: List<TypeMatch>.from(json["typeMatches"].map((x) => TypeMatch.fromMap(x))),
    filters: Filters.fromMap(json["filters"]),
    appIndex: AppIndex.fromMap(json["appIndex"]),
    responseLastUpdated: json["responseLastUpdated"],
  );

  Map<String, dynamic> toMap() => {
    "typeMatches": List<dynamic>.from(typeMatches.map((x) => x.toMap())),
    "filters": filters.toMap(),
    "appIndex": appIndex.toMap(),
    "responseLastUpdated": responseLastUpdated,
  };
}

class AppIndex {
  AppIndex({
    this.seoTitle,
    this.webUrl,
  });

  String seoTitle;
  String webUrl;

  factory AppIndex.fromJson(String str) => AppIndex.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory AppIndex.fromMap(Map<String, dynamic> json) => AppIndex(
    seoTitle: json["seoTitle"],
    webUrl: json["webURL"],
  );

  Map<String, dynamic> toMap() => {
    "seoTitle": seoTitle,
    "webURL": webUrl,
  };
}

class Filters {
  Filters({
    this.matchType,
  });

  List<String> matchType;

  factory Filters.fromJson(String str) => Filters.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Filters.fromMap(Map<String, dynamic> json) => Filters(
    matchType: List<String>.from(json["matchType"].map((x) => x)),
  );

  Map<String, dynamic> toMap() => {
    "matchType": List<dynamic>.from(matchType.map((x) => x)),
  };
}

class TypeMatch {
  TypeMatch({
    this.matchType,
    this.seriesMatches,
  });

  String matchType;
  List<SeriesMatch> seriesMatches;

  factory TypeMatch.fromJson(String str) => TypeMatch.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory TypeMatch.fromMap(Map<String, dynamic> json) => TypeMatch(
    matchType: json["matchType"],
    seriesMatches: List<SeriesMatch>.from(json["seriesMatches"].map((x) => SeriesMatch.fromMap(x))),
  );

  Map<String, dynamic> toMap() => {
    "matchType": matchType,
    "seriesMatches": List<dynamic>.from(seriesMatches.map((x) => x.toMap())),
  };
}

class SeriesMatch {
  SeriesMatch({
    this.seriesAdWrapper,
    this.adDetail,
  });

  SeriesAdWrapper seriesAdWrapper;
  AdDetail adDetail;

  factory SeriesMatch.fromJson(String str) => SeriesMatch.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory SeriesMatch.fromMap(Map<String, dynamic> json) => SeriesMatch(
    seriesAdWrapper:json["seriesAdWrapper"]==null?null: SeriesAdWrapper.fromMap(json["seriesAdWrapper"]),
    adDetail:json["adDetail"]==null?null: AdDetail.fromMap(json["adDetail"]),
  );

  Map<String, dynamic> toMap() => {
    "seriesAdWrapper": seriesAdWrapper.toMap(),
    "adDetail": adDetail.toMap(),
  };
}

class AdDetail {
  AdDetail({
    this.name,
    this.layout,
    this.position,
  });

  String name;
  String layout;
  int position;

  factory AdDetail.fromJson(String str) => AdDetail.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory AdDetail.fromMap(Map<String, dynamic> json) => AdDetail(
    name: json["name"],
    layout: json["layout"],
    position: json["position"],
  );

  Map<String, dynamic> toMap() => {
    "name": name,
    "layout": layout,
    "position": position,
  };
}

class SeriesAdWrapper {
  SeriesAdWrapper({
    this.seriesId,
    this.seriesName,
    this.matches,
  });

  int seriesId;
  String seriesName;
  List<RecentMatch> matches;

  factory SeriesAdWrapper.fromJson(String str) => SeriesAdWrapper.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory SeriesAdWrapper.fromMap(Map<String, dynamic> json) => SeriesAdWrapper(
    seriesId: json["seriesId"],
    seriesName: json["seriesName"],
    matches: List<RecentMatch>.from(json["matches"].map((x) => RecentMatch.fromMap(x))),
  );

  Map<String, dynamic> toMap() => {
    "seriesId": seriesId,
    "seriesName": seriesName,
    "matches": List<dynamic>.from(matches.map((x) => x.toMap())),
  };
}

class RecentMatch {
  RecentMatch({
    this.matchInfo,
    this.matchScore,
  });

  MatchInfo matchInfo;
  MatchScore matchScore;

  factory RecentMatch.fromJson(String str) => RecentMatch.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory RecentMatch.fromMap(Map<String, dynamic> json) => RecentMatch(
    matchInfo: MatchInfo.fromMap(json["matchInfo"]),
    matchScore:json["matchScore"]==null?null: MatchScore.fromMap(json["matchScore"]),
  );

  Map<String, dynamic> toMap() => {
    "matchInfo": matchInfo.toMap(),
    "matchScore": matchScore.toMap(),
  };
}

class MatchInfo {
  MatchInfo({
    this.matchId,
    this.seriesId,
    this.seriesName,
    this.matchDesc,
    this.matchFormat,
    this.startDate,
    this.endDate,
    this.state,
    this.status,
    this.team1,
    this.team2,
    this.venueInfo,
    this.currBatTeamId,
    this.seriesStartDt,
    this.seriesEndDt,
    this.isTimeAnnounced,
    this.stateTitle,
    this.isFantasyEnabled,
  });

  int matchId;
  int seriesId;
  String seriesName;
  String matchDesc;
  MatchFormat matchFormat;
  String startDate;
  String endDate;
  String state;
  String status;
  Team team1;
  Team team2;
  VenueInfo venueInfo;
  int currBatTeamId;
  String seriesStartDt;
  String seriesEndDt;
  bool isTimeAnnounced;
  String stateTitle;
  bool isFantasyEnabled;

  factory MatchInfo.fromJson(String str) => MatchInfo.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory MatchInfo.fromMap(Map<String, dynamic> json) => MatchInfo(
    matchId: json["matchId"],
    seriesId: json["seriesId"],
    seriesName: json["seriesName"],
    matchDesc: json["matchDesc"],
    matchFormat: matchFormatValues.map[json["matchFormat"]],
    startDate: json["startDate"],
    endDate: json["endDate"],
    state: json["state"],
    status: json["status"],
    team1: Team.fromMap(json["team1"]),
    team2: Team.fromMap(json["team2"]),
    venueInfo: VenueInfo.fromMap(json["venueInfo"]),
    currBatTeamId: json["currBatTeamId"],
    seriesStartDt: json["seriesStartDt"],
    seriesEndDt: json["seriesEndDt"],
    isTimeAnnounced: json["isTimeAnnounced"],
    stateTitle: json["stateTitle"],
    isFantasyEnabled: json["isFantasyEnabled"],
  );

  Map<String, dynamic> toMap() => {
    "matchId": matchId,
    "seriesId": seriesId,
    "seriesName": seriesName,
    "matchDesc": matchDesc,
    "matchFormat": matchFormatValues.reverse[matchFormat],
    "startDate": startDate,
    "endDate": endDate,
    "state": state,
    "status": status,
    "team1": team1.toMap(),
    "team2": team2.toMap(),
    "venueInfo": venueInfo.toMap(),
    "currBatTeamId": currBatTeamId,
    "seriesStartDt": seriesStartDt,
    "seriesEndDt": seriesEndDt,
    "isTimeAnnounced": isTimeAnnounced,
    "stateTitle": stateTitle,
    "isFantasyEnabled": isFantasyEnabled,
  };
}

enum MatchFormat { T20, TEST, ODI }

final matchFormatValues = EnumValues({
  "ODI": MatchFormat.ODI,
  "T20": MatchFormat.T20,
  "TEST": MatchFormat.TEST
});

enum MatchState { IN_PROGRESS, COMPLETE, TOSS }

final stateValues = EnumValues({
  "Complete": MatchState.COMPLETE,
  "In Progress": MatchState.IN_PROGRESS,
  "Toss": MatchState.TOSS
});
class Team {
  Team({
    this.teamId,
    this.teamName,
    this.teamSName,
    this.imageId,
  });

  int teamId;
  String teamName;
  String teamSName;
  int imageId;

  factory Team.fromJson(String str) => Team.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Team.fromMap(Map<String, dynamic> json) => Team(
    teamId: json["teamId"],
    teamName: json["teamName"],
    teamSName: json["teamSName"],
    imageId: json["imageId"],
  );

  Map<String, dynamic> toMap() => {
    "teamId": teamId,
    "teamName": teamName,
    "teamSName": teamSName,
    "imageId": imageId,
  };
}

class VenueInfo {
  VenueInfo({
    this.id,
    this.ground,
    this.city,
    this.timezone,
    this.latitude,
    this.longitude,
  });

  int id;
  String ground;
  String city;
  String timezone;
  String latitude;
  String longitude;

  factory VenueInfo.fromJson(String str) => VenueInfo.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory VenueInfo.fromMap(Map<String, dynamic> json) => VenueInfo(
    id: json["id"],
    ground: json["ground"],
    city: json["city"],
    timezone: json["timezone"],
    latitude: json["latitude"],
    longitude: json["longitude"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "ground": ground,
    "city": city,
    "timezone": timezone,
    "latitude": latitude,
    "longitude": longitude,
  };
}

class MatchScore {
  MatchScore({
    this.team1Score,
    this.team2Score,
  });

  TeamScore team1Score;
  TeamScore team2Score;

  factory MatchScore.fromJson(String str) => MatchScore.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory MatchScore.fromMap(Map<String, dynamic> json) => MatchScore(
    team1Score: json["team1Score"]==null?null:TeamScore.fromMap(json["team1Score"]),
    team2Score: json["team2Score"]==null?null:TeamScore.fromMap(json["team2Score"]),
  );

  Map<String, dynamic> toMap() => {
    "team1Score": team1Score.toMap(),
    "team2Score": team2Score.toMap(),
  };
}

class TeamScore {
  TeamScore({
    this.inngs1,
    this.inngs2,
  });

  Inngs inngs1;
  Inngs inngs2;

  factory TeamScore.fromJson(String str) => TeamScore.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory TeamScore.fromMap(Map<String, dynamic> json) => TeamScore(
    inngs1: json["inngs1"]==null?null:Inngs.fromMap(json["inngs1"]),
    inngs2:json["inngs2"]==null?null: Inngs.fromMap(json["inngs2"]),
  );

  Map<String, dynamic> toMap() => {
    "inngs1": inngs1.toMap(),
    "inngs2": inngs2.toMap(),
  };
}

class Inngs {
  Inngs({
    this.inningsId,
    this.runs,
    this.wickets,
    this.overs,
    this.isDeclared,
    this.isFollowOn,
  });

  int inningsId;
  int runs;
  int wickets;
  double overs;
  bool isDeclared;
  bool isFollowOn;

  factory Inngs.fromJson(String str) => Inngs.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Inngs.fromMap(Map<String, dynamic> json) => Inngs(
    inningsId: json["inningsId"],
    runs: json["runs"],
    wickets: json["wickets"],
    overs: json["overs"].toDouble(),
    isDeclared: json["isDeclared"],
    isFollowOn: json["isFollowOn"],
  );

  Map<String, dynamic> toMap() => {
    "inningsId": inningsId,
    "runs": runs,
    "wickets": wickets,
    "overs": overs,
    "isDeclared": isDeclared,
    "isFollowOn": isFollowOn,
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

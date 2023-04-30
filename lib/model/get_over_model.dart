// To parse this JSON data, do
//
//     final getOverResponse = getOverResponseFromMap(jsonString);

import 'dart:convert';

class GetOverResponse {
  int inningsId;
  BatsmanNStriker batsmanStriker;
  BatsmanNStriker batsmanNonStriker;
  BatTeam batTeam;
  BowlerStriker bowlerStriker;
  BowlerStriker bowlerNonStriker;
  double overs;
  String recentOvsStats;
  PartnerShip partnerShip;
  double currentRunRate;
  dynamic requiredRunRate;
  String lastWicket;
  MatchScoreDetails matchScoreDetails;
  List<LatestPerformance> latestPerformance;
  PpData ppData;
  MatchUdrs matchUdrs;
  List<OverSummaryList> overSummaryList;
  String status;
  int lastWicketScore;
  int remRunsToWin;
  MatchHeader matchHeader;
  int responseLastUpdated;
  String event;

  GetOverResponse({
    this.inningsId,
    this.batsmanStriker,
    this.batsmanNonStriker,
    this.batTeam,
    this.bowlerStriker,
    this.bowlerNonStriker,
    this.overs,
    this.recentOvsStats,
    this.partnerShip,
    this.currentRunRate,
    this.requiredRunRate,
    this.lastWicket,
    this.matchScoreDetails,
    this.latestPerformance,
    this.ppData,
    this.matchUdrs,
    this.overSummaryList,
    this.status,
    this.lastWicketScore,
    this.remRunsToWin,
    this.matchHeader,
    this.responseLastUpdated,
    this.event,
  });

  factory GetOverResponse.fromJson(String str) => GetOverResponse.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory GetOverResponse.fromMap(Map<String, dynamic> json) => GetOverResponse(
    inningsId: json["inningsId"],
    batsmanStriker: BatsmanNStriker.fromMap(json["batsmanStriker"]),
    batsmanNonStriker: BatsmanNStriker.fromMap(json["batsmanNonStriker"]),
    batTeam: BatTeam.fromMap(json["batTeam"]),
    bowlerStriker: BowlerStriker.fromMap(json["bowlerStriker"]),
    bowlerNonStriker: BowlerStriker.fromMap(json["bowlerNonStriker"]),
    overs: json["overs"].toDouble(),
    recentOvsStats: json["recentOvsStats"],
    partnerShip: PartnerShip.fromMap(json["partnerShip"]),
    currentRunRate: json["currentRunRate"].toDouble(),
    requiredRunRate: json["requiredRunRate"],
    lastWicket: json["lastWicket"],
    matchScoreDetails: MatchScoreDetails.fromMap(json["matchScoreDetails"]),
    latestPerformance: List<LatestPerformance>.from(json["latestPerformance"].map((x) => LatestPerformance.fromMap(x))),
    ppData: PpData.fromMap(json["ppData"]),
    matchUdrs:json["matchUdrs"]==null?null: MatchUdrs.fromMap(json["matchUdrs"]),
    overSummaryList: List<OverSummaryList>.from(json["overSummaryList"].map((x) => OverSummaryList.fromMap(x))),
    status: json["status"],
    lastWicketScore: json["lastWicketScore"],
    remRunsToWin: json["remRunsToWin"],
    matchHeader: MatchHeader.fromMap(json["matchHeader"]),
    responseLastUpdated: json["responseLastUpdated"],
    event: json["event"],
  );

  Map<String, dynamic> toMap() => {
    "inningsId": inningsId,
    "batsmanStriker": batsmanStriker.toMap(),
    "batsmanNonStriker": batsmanNonStriker.toMap(),
    "batTeam": batTeam.toMap(),
    "bowlerStriker": bowlerStriker.toMap(),
    "bowlerNonStriker": bowlerNonStriker.toMap(),
    "overs": overs,
    "recentOvsStats": recentOvsStats,
    "partnerShip": partnerShip.toMap(),
    "currentRunRate": currentRunRate,
    "requiredRunRate": requiredRunRate,
    "lastWicket": lastWicket,
    "matchScoreDetails": matchScoreDetails.toMap(),
    "latestPerformance": List<dynamic>.from(latestPerformance.map((x) => x.toMap())),
    "ppData": ppData.toMap(),
    "matchUdrs": matchUdrs.toMap(),
    "overSummaryList": List<dynamic>.from(overSummaryList.map((x) => x.toMap())),
    "status": status,
    "lastWicketScore": lastWicketScore,
    "remRunsToWin": remRunsToWin,
    "matchHeader": matchHeader.toMap(),
    "responseLastUpdated": responseLastUpdated,
    "event": event,
  };
}

class BatTeam {
  int teamId;
  int teamScore;
  int teamWkts;

  BatTeam({
    this.teamId,
    this.teamScore,
    this.teamWkts,
  });

  factory BatTeam.fromJson(String str) => BatTeam.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory BatTeam.fromMap(Map<String, dynamic> json) => BatTeam(
    teamId: json["teamId"],
    teamScore: json["teamScore"],
    teamWkts: json["teamWkts"],
  );

  Map<String, dynamic> toMap() => {
    "teamId": teamId,
    "teamScore": teamScore,
    "teamWkts": teamWkts,
  };
}

class BatsmanNStriker {
  int batBalls;
  int batDots;
  int batFours;
  int batId;
  String batName;
  int batMins;
  int batRuns;
  int batSixes;
  double batStrikeRate;

  BatsmanNStriker({
    this.batBalls,
    this.batDots,
    this.batFours,
    this.batId,
    this.batName,
    this.batMins,
    this.batRuns,
    this.batSixes,
    this.batStrikeRate,
  });

  factory BatsmanNStriker.fromJson(String str) => BatsmanNStriker.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory BatsmanNStriker.fromMap(Map<String, dynamic> json) => BatsmanNStriker(
    batBalls: json["batBalls"],
    batDots: json["batDots"],
    batFours: json["batFours"],
    batId: json["batId"],
    batName: json["batName"],
    batMins: json["batMins"],
    batRuns: json["batRuns"],
    batSixes: json["batSixes"],
    batStrikeRate: json["batStrikeRate"].toDouble(),
  );

  Map<String, dynamic> toMap() => {
    "batBalls": batBalls,
    "batDots": batDots,
    "batFours": batFours,
    "batId": batId,
    "batName": batName,
    "batMins": batMins,
    "batRuns": batRuns,
    "batSixes": batSixes,
    "batStrikeRate": batStrikeRate,
  };
}

class BowlerStriker {
  int bowlId;
  String bowlName;
  int bowlMaidens;
  int bowlNoballs;
  double bowlOvs;
  int bowlRuns;
  int bowlWides;
  int bowlWkts;
  double bowlEcon;

  BowlerStriker({
    this.bowlId,
    this.bowlName,
    this.bowlMaidens,
    this.bowlNoballs,
    this.bowlOvs,
    this.bowlRuns,
    this.bowlWides,
    this.bowlWkts,
    this.bowlEcon,
  });

  factory BowlerStriker.fromJson(String str) => BowlerStriker.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory BowlerStriker.fromMap(Map<String, dynamic> json) => BowlerStriker(
    bowlId: json["bowlId"],
    bowlName: json["bowlName"],
    bowlMaidens: json["bowlMaidens"],
    bowlNoballs: json["bowlNoballs"],
    bowlOvs: json["bowlOvs"].toDouble(),
    bowlRuns: json["bowlRuns"],
    bowlWides: json["bowlWides"],
    bowlWkts: json["bowlWkts"],
    bowlEcon: json["bowlEcon"].toDouble(),
  );

  Map<String, dynamic> toMap() => {
    "bowlId": bowlId,
    "bowlName": bowlName,
    "bowlMaidens": bowlMaidens,
    "bowlNoballs": bowlNoballs,
    "bowlOvs": bowlOvs,
    "bowlRuns": bowlRuns,
    "bowlWides": bowlWides,
    "bowlWkts": bowlWkts,
    "bowlEcon": bowlEcon,
  };
}

class LatestPerformance {
  int runs;
  int wkts;
  String label;

  LatestPerformance({
    this.runs,
    this.wkts,
    this.label,
  });

  factory LatestPerformance.fromJson(String str) => LatestPerformance.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory LatestPerformance.fromMap(Map<String, dynamic> json) => LatestPerformance(
    runs: json["runs"],
    wkts: json["wkts"],
    label: json["label"],
  );

  Map<String, dynamic> toMap() => {
    "runs": runs,
    "wkts": wkts,
    "label": label,
  };
}

class MatchHeader {
  int matchId;
  String matchDescription;
  String matchFormat;
  String matchType;
  bool complete;
  bool domestic;
  int matchStartTimestamp;
  int matchCompleteTimestamp;
  bool dayNight;
  int year;
  String state;
  String status;
  TossResults tossResults;
  Result result;
  RevisedTarget revisedTarget;
  List<dynamic> playersOfTheMatch;
  List<dynamic> playersOfTheSeries;
  List<MatchTeamInfo> matchTeamInfo;
  bool isMatchNotCovered;
  Team team1;
  Team team2;
  String seriesDesc;
  int seriesId;
  String seriesName;
  String alertType;
  bool livestreamEnabled;

  MatchHeader({
    this.matchId,
    this.matchDescription,
    this.matchFormat,
    this.matchType,
    this.complete,
    this.domestic,
    this.matchStartTimestamp,
    this.matchCompleteTimestamp,
    this.dayNight,
    this.year,
    this.state,
    this.status,
    this.tossResults,
    this.result,
    this.revisedTarget,
    this.playersOfTheMatch,
    this.playersOfTheSeries,
    this.matchTeamInfo,
    this.isMatchNotCovered,
    this.team1,
    this.team2,
    this.seriesDesc,
    this.seriesId,
    this.seriesName,
    this.alertType,
    this.livestreamEnabled,
  });

  factory MatchHeader.fromJson(String str) => MatchHeader.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory MatchHeader.fromMap(Map<String, dynamic> json) => MatchHeader(
    matchId: json["matchId"],
    matchDescription: json["matchDescription"],
    matchFormat: json["matchFormat"],
    matchType: json["matchType"],
    complete: json["complete"],
    domestic: json["domestic"],
    matchStartTimestamp: json["matchStartTimestamp"],
    matchCompleteTimestamp: json["matchCompleteTimestamp"],
    dayNight: json["dayNight"],
    year: json["year"],
    state: json["state"],
    status: json["status"],
    tossResults: TossResults.fromMap(json["tossResults"]),
    result: Result.fromMap(json["result"]),
    revisedTarget: RevisedTarget.fromMap(json["revisedTarget"]),
    playersOfTheMatch: List<dynamic>.from(json["playersOfTheMatch"].map((x) => x)),
    playersOfTheSeries: List<dynamic>.from(json["playersOfTheSeries"].map((x) => x)),
    matchTeamInfo: List<MatchTeamInfo>.from(json["matchTeamInfo"].map((x) => MatchTeamInfo.fromMap(x))),
    isMatchNotCovered: json["isMatchNotCovered"],
    team1: Team.fromMap(json["team1"]),
    team2: Team.fromMap(json["team2"]),
    seriesDesc: json["seriesDesc"],
    seriesId: json["seriesId"],
    seriesName: json["seriesName"],
    alertType: json["alertType"],
    livestreamEnabled: json["livestreamEnabled"],
  );

  Map<String, dynamic> toMap() => {
    "matchId": matchId,
    "matchDescription": matchDescription,
    "matchFormat": matchFormat,
    "matchType": matchType,
    "complete": complete,
    "domestic": domestic,
    "matchStartTimestamp": matchStartTimestamp,
    "matchCompleteTimestamp": matchCompleteTimestamp,
    "dayNight": dayNight,
    "year": year,
    "state": state,
    "status": status,
    "tossResults": tossResults.toMap(),
    "result": result.toMap(),
    "revisedTarget": revisedTarget.toMap(),
    "playersOfTheMatch": List<dynamic>.from(playersOfTheMatch.map((x) => x)),
    "playersOfTheSeries": List<dynamic>.from(playersOfTheSeries.map((x) => x)),
    "matchTeamInfo": List<dynamic>.from(matchTeamInfo.map((x) => x.toMap())),
    "isMatchNotCovered": isMatchNotCovered,
    "team1": team1.toMap(),
    "team2": team2.toMap(),
    "seriesDesc": seriesDesc,
    "seriesId": seriesId,
    "seriesName": seriesName,
    "alertType": alertType,
    "livestreamEnabled": livestreamEnabled,
  };
}

class MatchTeamInfo {
  int battingTeamId;
  BatName battingTeamShortName;
  int bowlingTeamId;
  String bowlingTeamShortName;

  MatchTeamInfo({
    this.battingTeamId,
    this.battingTeamShortName,
    this.bowlingTeamId,
    this.bowlingTeamShortName,
  });

  factory MatchTeamInfo.fromJson(String str) => MatchTeamInfo.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory MatchTeamInfo.fromMap(Map<String, dynamic> json) => MatchTeamInfo(
    battingTeamId: json["battingTeamId"],
    battingTeamShortName: batNameValues.map[json["battingTeamShortName"]],
    bowlingTeamId: json["bowlingTeamId"],
    bowlingTeamShortName: json["bowlingTeamShortName"],
  );

  Map<String, dynamic> toMap() => {
    "battingTeamId": battingTeamId,
    "battingTeamShortName": batNameValues.reverse[battingTeamShortName],
    "bowlingTeamId": bowlingTeamId,
    "bowlingTeamShortName": bowlingTeamShortName,
  };
}

enum BatName { NZ }

final batNameValues = EnumValues({
  "NZ": BatName.NZ
});

class Result {
  String winningTeam;
  bool winByRuns;
  bool winByInnings;

  Result({
    this.winningTeam,
    this.winByRuns,
    this.winByInnings,
  });

  factory Result.fromJson(String str) => Result.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Result.fromMap(Map<String, dynamic> json) => Result(
    winningTeam: json["winningTeam"],
    winByRuns: json["winByRuns"],
    winByInnings: json["winByInnings"],
  );

  Map<String, dynamic> toMap() => {
    "winningTeam": winningTeam,
    "winByRuns": winByRuns,
    "winByInnings": winByInnings,
  };
}

class RevisedTarget {
  String reason;

  RevisedTarget({
    this.reason,
  });

  factory RevisedTarget.fromJson(String str) => RevisedTarget.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory RevisedTarget.fromMap(Map<String, dynamic> json) => RevisedTarget(
    reason: json["reason"],
  );

  Map<String, dynamic> toMap() => {
    "reason": reason,
  };
}

class Team {
  int id;
  String name;
  List<dynamic> playerDetails;
  String shortName;

  Team({
    this.id,
    this.name,
    this.playerDetails,
    this.shortName,
  });

  factory Team.fromJson(String str) => Team.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Team.fromMap(Map<String, dynamic> json) => Team(
    id: json["id"],
    name: json["name"],
    playerDetails: List<dynamic>.from(json["playerDetails"].map((x) => x)),
    shortName: json["shortName"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "name": name,
    "playerDetails": List<dynamic>.from(playerDetails.map((x) => x)),
    "shortName": shortName,
  };
}

class TossResults {
  int tossWinnerId;
  String tossWinnerName;
  String decision;

  TossResults({
    this.tossWinnerId,
    this.tossWinnerName,
    this.decision,
  });

  factory TossResults.fromJson(String str) => TossResults.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory TossResults.fromMap(Map<String, dynamic> json) => TossResults(
    tossWinnerId: json["tossWinnerId"],
    tossWinnerName: json["tossWinnerName"],
    decision: json["decision"],
  );

  Map<String, dynamic> toMap() => {
    "tossWinnerId": tossWinnerId,
    "tossWinnerName": tossWinnerName,
    "decision": decision,
  };
}

class MatchScoreDetails {
  int matchId;
  List<InningsScoreList> inningsScoreList;
  TossResults tossResults;
  List<MatchTeamInfo> matchTeamInfo;
  bool isMatchNotCovered;
  String matchFormat;
  String state;
  String customStatus;
  int highlightedTeamId;

  MatchScoreDetails({
    this.matchId,
    this.inningsScoreList,
    this.tossResults,
    this.matchTeamInfo,
    this.isMatchNotCovered,
    this.matchFormat,
    this.state,
    this.customStatus,
    this.highlightedTeamId,
  });

  factory MatchScoreDetails.fromJson(String str) => MatchScoreDetails.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory MatchScoreDetails.fromMap(Map<String, dynamic> json) => MatchScoreDetails(
    matchId: json["matchId"],
    inningsScoreList: List<InningsScoreList>.from(json["inningsScoreList"].map((x) => InningsScoreList.fromMap(x))),
    tossResults: TossResults.fromMap(json["tossResults"]),
    matchTeamInfo: List<MatchTeamInfo>.from(json["matchTeamInfo"].map((x) => MatchTeamInfo.fromMap(x))),
    isMatchNotCovered: json["isMatchNotCovered"],
    matchFormat: json["matchFormat"],
    state: json["state"],
    customStatus: json["customStatus"],
    highlightedTeamId: json["highlightedTeamId"],
  );

  Map<String, dynamic> toMap() => {
    "matchId": matchId,
    "inningsScoreList": List<dynamic>.from(inningsScoreList.map((x) => x.toMap())),
    "tossResults": tossResults.toMap(),
    "matchTeamInfo": List<dynamic>.from(matchTeamInfo.map((x) => x.toMap())),
    "isMatchNotCovered": isMatchNotCovered,
    "matchFormat": matchFormat,
    "state": state,
    "customStatus": customStatus,
    "highlightedTeamId": highlightedTeamId,
  };
}

class InningsScoreList {
  int inningsId;
  int batTeamId;
  BatName batTeamName;
  int score;
  int wickets;
  double overs;
  bool isDeclared;
  bool isFollowOn;
  int ballNbr;

  InningsScoreList({
    this.inningsId,
    this.batTeamId,
    this.batTeamName,
    this.score,
    this.wickets,
    this.overs,
    this.isDeclared,
    this.isFollowOn,
    this.ballNbr,
  });

  factory InningsScoreList.fromJson(String str) => InningsScoreList.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory InningsScoreList.fromMap(Map<String, dynamic> json) => InningsScoreList(
    inningsId: json["inningsId"],
    batTeamId: json["batTeamId"],
    batTeamName: batNameValues.map[json["batTeamName"]],
    score: json["score"],
    wickets: json["wickets"],
    overs: json["overs"].toDouble(),
    isDeclared: json["isDeclared"],
    isFollowOn: json["isFollowOn"],
    ballNbr: json["ballNbr"],
  );

  Map<String, dynamic> toMap() => {
    "inningsId": inningsId,
    "batTeamId": batTeamId,
    "batTeamName": batNameValues.reverse[batTeamName],
    "score": score,
    "wickets": wickets,
    "overs": overs,
    "isDeclared": isDeclared,
    "isFollowOn": isFollowOn,
    "ballNbr": ballNbr,
  };
}

class MatchUdrs {
  int matchId;
  int inningsId;
  DateTime timestamp;
  int team1Id;
  int team1Remaining;
  int team1Successful;
  int team1Unsuccessful;
  int team2Id;
  int team2Remaining;
  int team2Successful;
  int team2Unsuccessful;

  MatchUdrs({
    this.matchId,
    this.inningsId,
    this.timestamp,
    this.team1Id,
    this.team1Remaining,
    this.team1Successful,
    this.team1Unsuccessful,
    this.team2Id,
    this.team2Remaining,
    this.team2Successful,
    this.team2Unsuccessful,
  });

  factory MatchUdrs.fromJson(String str) => MatchUdrs.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory MatchUdrs.fromMap(Map<String, dynamic> json) => MatchUdrs(
    matchId: json["matchId"],
    inningsId: json["inningsId"],
    timestamp: DateTime.parse(json["timestamp"]),
    team1Id: json["team1Id"],
    team1Remaining: json["team1Remaining"],
    team1Successful: json["team1Successful"],
    team1Unsuccessful: json["team1Unsuccessful"],
    team2Id: json["team2Id"],
    team2Remaining: json["team2Remaining"],
    team2Successful: json["team2Successful"],
    team2Unsuccessful: json["team2Unsuccessful"],
  );

  Map<String, dynamic> toMap() => {
    "matchId": matchId,
    "inningsId": inningsId,
    "timestamp": timestamp.toIso8601String(),
    "team1Id": team1Id,
    "team1Remaining": team1Remaining,
    "team1Successful": team1Successful,
    "team1Unsuccessful": team1Unsuccessful,
    "team2Id": team2Id,
    "team2Remaining": team2Remaining,
    "team2Successful": team2Successful,
    "team2Unsuccessful": team2Unsuccessful,
  };
}

class OverSummaryList {
  int score;
  int wickets;
  int inningsId;
  String oSummary;
  int runs;
  List<int> batStrikerIds;
  List<BatStrikerName> batStrikerNames;
  int batStrikerRuns;
  int batStrikerBalls;
  List<dynamic> batNonStrikerIds;
  List<dynamic> batNonStrikerNames;
  int batNonStrikerRuns;
  int batNonStrikerBalls;
  List<int> bowlIds;
  List<String> bowlNames;
  double bowlOvers;
  int bowlMaidens;
  int bowlRuns;
  int bowlWickets;
  int timestamp;
  double overNum;
  BatName batTeamName;
  OverEvent event;

  OverSummaryList({
    this.score,
    this.wickets,
    this.inningsId,
    this.oSummary,
    this.runs,
    this.batStrikerIds,
    this.batStrikerNames,
    this.batStrikerRuns,
    this.batStrikerBalls,
    this.batNonStrikerIds,
    this.batNonStrikerNames,
    this.batNonStrikerRuns,
    this.batNonStrikerBalls,
    this.bowlIds,
    this.bowlNames,
    this.bowlOvers,
    this.bowlMaidens,
    this.bowlRuns,
    this.bowlWickets,
    this.timestamp,
    this.overNum,
    this.batTeamName,
    this.event,
  });

  factory OverSummaryList.fromJson(String str) => OverSummaryList.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory OverSummaryList.fromMap(Map<String, dynamic> json) => OverSummaryList(
    score: json["score"],
    wickets: json["wickets"],
    inningsId: json["inningsId"],
    oSummary: json["o_summary"],
    runs: json["runs"],
    batStrikerIds: List<int>.from(json["batStrikerIds"].map((x) => x)),
    batStrikerNames: List<BatStrikerName>.from(json["batStrikerNames"].map((x) => batStrikerNameValues.map[x])),
    batStrikerRuns: json["batStrikerRuns"],
    batStrikerBalls: json["batStrikerBalls"],
    batNonStrikerIds: List<dynamic>.from(json["batNonStrikerIds"].map((x) => x)),
    batNonStrikerNames: List<dynamic>.from(json["batNonStrikerNames"].map((x) => x)),
    batNonStrikerRuns: json["batNonStrikerRuns"],
    batNonStrikerBalls: json["batNonStrikerBalls"],
    bowlIds: List<int>.from(json["bowlIds"].map((x) => x)),
    bowlNames: List<String>.from(json["bowlNames"].map((x) => x)),
    bowlOvers: json["bowlOvers"].toDouble(),
    bowlMaidens: json["bowlMaidens"],
    bowlRuns: json["bowlRuns"],
    bowlWickets: json["bowlWickets"],
    timestamp: json["timestamp"],
    overNum: json["overNum"].toDouble(),
    batTeamName: batNameValues.map[json["batTeamName"]],
    event: eventValues.map[json["event"]],
  );

  Map<String, dynamic> toMap() => {
    "score": score,
    "wickets": wickets,
    "inningsId": inningsId,
    "o_summary": oSummary,
    "runs": runs,
    "batStrikerIds": List<dynamic>.from(batStrikerIds.map((x) => x)),
    "batStrikerNames": List<dynamic>.from(batStrikerNames.map((x) => batStrikerNameValues.reverse[x])),
    "batStrikerRuns": batStrikerRuns,
    "batStrikerBalls": batStrikerBalls,
    "batNonStrikerIds": List<dynamic>.from(batNonStrikerIds.map((x) => x)),
    "batNonStrikerNames": List<dynamic>.from(batNonStrikerNames.map((x) => x)),
    "batNonStrikerRuns": batNonStrikerRuns,
    "batNonStrikerBalls": batNonStrikerBalls,
    "bowlIds": List<dynamic>.from(bowlIds.map((x) => x)),
    "bowlNames": List<dynamic>.from(bowlNames.map((x) => x)),
    "bowlOvers": bowlOvers,
    "bowlMaidens": bowlMaidens,
    "bowlRuns": bowlRuns,
    "bowlWickets": bowlWickets,
    "timestamp": timestamp,
    "overNum": overNum,
    "batTeamName": batNameValues.reverse[batTeamName],
    "event": eventValues.reverse[event],
  };
}

enum BatStrikerName { MITCHELL, CHAPMAN, LATHAM }

final batStrikerNameValues = EnumValues({
  "Chapman": BatStrikerName.CHAPMAN,
  "Latham": BatStrikerName.LATHAM,
  "Mitchell": BatStrikerName.MITCHELL
});

enum OverEvent { OVER_BREAK }

final eventValues = EnumValues({
  "over-break": OverEvent.OVER_BREAK
});

class PartnerShip {
  int balls;
  int runs;

  PartnerShip({
    this.balls,
    this.runs,
  });

  factory PartnerShip.fromJson(String str) => PartnerShip.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory PartnerShip.fromMap(Map<String, dynamic> json) => PartnerShip(
    balls: json["balls"],
    runs: json["runs"],
  );

  Map<String, dynamic> toMap() => {
    "balls": balls,
    "runs": runs,
  };
}

class PpData {
  Pp1 pp1;

  PpData({
    this.pp1,
  });

  factory PpData.fromJson(String str) => PpData.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory PpData.fromMap(Map<String, dynamic> json) => PpData(
    pp1: Pp1.fromMap(json["pp_1"]),
  );

  Map<String, dynamic> toMap() => {
    "pp_1": pp1.toMap(),
  };
}

class Pp1 {
  int ppId;
  double ppOversFrom;
  dynamic ppOversTo;
  String ppType;
  int runsScored;

  Pp1({
    this.ppId,
    this.ppOversFrom,
    this.ppOversTo,
    this.ppType,
    this.runsScored,
  });

  factory Pp1.fromJson(String str) => Pp1.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Pp1.fromMap(Map<String, dynamic> json) => Pp1(
    ppId: json["ppId"],
    ppOversFrom: json["ppOversFrom"].toDouble(),
    ppOversTo: json["ppOversTo"],
    ppType: json["ppType"],
    runsScored: json["runsScored"],
  );

  Map<String, dynamic> toMap() => {
    "ppId": ppId,
    "ppOversFrom": ppOversFrom,
    "ppOversTo": ppOversTo,
    "ppType": ppType,
    "runsScored": runsScored,
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

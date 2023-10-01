import 'dart:convert';

class CommentaryResponse {
  List<CommentaryList> commentaryList;
  MatchHeader matchHeader;
  Miniscore miniscore;
  List<dynamic> commentarySnippetList;
  String page;
  bool enableNoContent;
  List<dynamic> matchVideos;
  int responseLastUpdated;

  CommentaryResponse({
    this.commentaryList,
    this.matchHeader,
    this.miniscore,
    this.commentarySnippetList,
    this.page,
    this.enableNoContent,
    this.matchVideos,
    this.responseLastUpdated,
  });

  factory CommentaryResponse.fromJson(String str) => CommentaryResponse.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory CommentaryResponse.fromMap(Map<String, dynamic> json) => CommentaryResponse(
    commentaryList: List<CommentaryList>.from(json["commentaryList"].map((x) => CommentaryList.fromMap(x))),
    matchHeader: MatchHeader.fromMap(json["matchHeader"]),
    miniscore: Miniscore.fromMap(json["miniscore"]),
    commentarySnippetList: List<dynamic>.from(json["commentarySnippetList"].map((x) => x)),
    page: json["page"],
    enableNoContent: json["enableNoContent"],
    matchVideos: List<dynamic>.from(json["matchVideos"].map((x) => x)),
    responseLastUpdated: json["responseLastUpdated"],
  );

  Map<String, dynamic> toMap() => {
    "commentaryList": List<dynamic>.from(commentaryList.map((x) => x.toMap())),
    "matchHeader": matchHeader.toMap(),
    "miniscore": miniscore.toMap(),
    "commentarySnippetList": List<dynamic>.from(commentarySnippetList.map((x) => x)),
    "page": page,
    "enableNoContent": enableNoContent,
    "matchVideos": List<dynamic>.from(matchVideos.map((x) => x)),
    "responseLastUpdated": responseLastUpdated,
  };
}

class CommentaryList {
  String commText;
  int timestamp;
  int ballNbr;
  int inningsId;
  CommentaryEvent event;
  BatTeamName batTeamName;
  CommentaryFormats commentaryFormats;
  double overNumber;
  OverSeparator overSeparator;

  CommentaryList({
    this.commText,
    this.timestamp,
    this.ballNbr,
    this.inningsId,
    this.event,
    this.batTeamName,
    this.commentaryFormats,
    this.overNumber,
    this.overSeparator,
  });

  factory CommentaryList.fromJson(String str) => CommentaryList.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory CommentaryList.fromMap(Map<String, dynamic> json) => CommentaryList(
    commText: json["commText"],
    timestamp: json["timestamp"],
    ballNbr: json["ballNbr"],
    inningsId: json["inningsId"],
    event: eventValues.map[json["event"]],
    batTeamName: batTeamNameValues.map[json["batTeamName"]],
    commentaryFormats: CommentaryFormats.fromMap(json["commentaryFormats"]),
    overNumber: json["overNumber"],
   // overSeparator: OverSeparator.fromMap(json["overSeparator"]),
  );

  Map<String, dynamic> toMap() => {
    "commText": commText,
    "timestamp": timestamp,
    "ballNbr": ballNbr,
    "inningsId": inningsId,
    "event": eventValues.reverse[event],
    "batTeamName": batTeamNameValues.reverse[batTeamName],
    "commentaryFormats": commentaryFormats.toMap(),
    "overNumber": overNumber,
    "overSeparator": overSeparator.toMap(),
  };
}

enum BatTeamName {
  UAEU19
}

final batTeamNameValues = EnumValues({
  "UAEU19": BatTeamName.UAEU19
});

class CommentaryFormats {
  Bold bold;

  CommentaryFormats({
    this.bold,
  });

  factory CommentaryFormats.fromJson(String str) => CommentaryFormats.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory CommentaryFormats.fromMap(Map<String, dynamic> json) => CommentaryFormats(
    bold: Bold.fromMap(json["bold"]),
  );

  Map<String, dynamic> toMap() => {
    "bold": bold.toMap(),
  };
}

class Bold {
  List<FormatId> formatId;
  List<String> formatValue;

  Bold({
    this.formatId,
    this.formatValue,
  });

  factory Bold.fromJson(String str) => Bold.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Bold.fromMap(Map<String, dynamic> json) => Bold(
    formatId: List<FormatId>.from(json["formatId"].map((x) => formatIdValues.map[x])),
    formatValue: List<String>.from(json["formatValue"].map((x) => x)),
  );

  Map<String, dynamic> toMap() => {
    "formatId": List<dynamic>.from(formatId.map((x) => formatIdValues.reverse[x])),
    "formatValue": List<dynamic>.from(formatValue.map((x) => x)),
  };
}

enum FormatId {
  B0,
  B1
}

final formatIdValues = EnumValues({
  "B0\u0024": FormatId.B0,
  "B1\u0024": FormatId.B1
});

enum CommentaryEvent {
  FOUR,
  NONE,
  OVER_BREAK,
  WICKET
}

final eventValues = EnumValues({
  "FOUR": CommentaryEvent.FOUR,
  "NONE": CommentaryEvent.NONE,
  "over-break": CommentaryEvent.OVER_BREAK,
  "WICKET": CommentaryEvent.WICKET
});

class OverSeparator {
  int score;
  int wickets;
  int inningsId;
  String oSummary;
  int runs;
  List<int> batStrikerIds;
  List<String> batStrikerNames;
  int batStrikerRuns;
  int batStrikerBalls;
  List<int> batNonStrikerIds;
  List<String> batNonStrikerNames;
  int batNonStrikerRuns;
  int batNonStrikerBalls;
  List<int> bowlIds;
  List<String> bowlNames;
  int bowlOvers;
  int bowlMaidens;
  int bowlRuns;
  int bowlWickets;
  int timestamp;
  double overNum;
  BatTeamName batTeamName;
  CommentaryEvent event;

  OverSeparator({
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

  factory OverSeparator.fromJson(String str) => OverSeparator.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory OverSeparator.fromMap(Map<String, dynamic> json) => OverSeparator(
    score: json["score"],
    wickets: json["wickets"],
    inningsId: json["inningsId"],
    oSummary: json["o_summary"],
    runs: json["runs"],
    batStrikerIds: List<int>.from(json["batStrikerIds"].map((x) => x)),
    batStrikerNames: List<String>.from(json["batStrikerNames"].map((x) => x)),
    batStrikerRuns: json["batStrikerRuns"],
    batStrikerBalls: json["batStrikerBalls"],
    batNonStrikerIds: List<int>.from(json["batNonStrikerIds"].map((x) => x)),
    batNonStrikerNames: List<String>.from(json["batNonStrikerNames"].map((x) => x)),
    batNonStrikerRuns: json["batNonStrikerRuns"],
    batNonStrikerBalls: json["batNonStrikerBalls"],
    bowlIds: List<int>.from(json["bowlIds"].map((x) => x)),
    bowlNames: List<String>.from(json["bowlNames"].map((x) => x)),
    bowlOvers: json["bowlOvers"],
    bowlMaidens: json["bowlMaidens"],
    bowlRuns: json["bowlRuns"],
    bowlWickets: json["bowlWickets"],
    timestamp: json["timestamp"],
    overNum: json["overNum"].toDouble(),
    batTeamName: batTeamNameValues.map[json["batTeamName"]],
    event: eventValues.map[json["event"]],
  );

  Map<String, dynamic> toMap() => {
    "score": score,
    "wickets": wickets,
    "inningsId": inningsId,
    "o_summary": oSummary,
    "runs": runs,
    "batStrikerIds": List<dynamic>.from(batStrikerIds.map((x) => x)),
    "batStrikerNames": List<dynamic>.from(batStrikerNames.map((x) => x)),
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
    "batTeamName": batTeamNameValues.reverse[batTeamName],
    "event": eventValues.reverse[event],
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
  List<PlayersOfTheMatch> playersOfTheMatch;
  List<dynamic> playersOfTheSeries;
  List<MatchTeamInfo> matchTeamInfo;
  bool isMatchNotCovered;
  Team team1;
  Team team2;
  String seriesDesc;
  int seriesId;
  String seriesName;

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
    playersOfTheMatch: List<PlayersOfTheMatch>.from(json["playersOfTheMatch"].map((x) => PlayersOfTheMatch.fromMap(x))),
    playersOfTheSeries: List<dynamic>.from(json["playersOfTheSeries"].map((x) => x)),
    matchTeamInfo: List<MatchTeamInfo>.from(json["matchTeamInfo"].map((x) => MatchTeamInfo.fromMap(x))),
    isMatchNotCovered: json["isMatchNotCovered"],
    team1: Team.fromMap(json["team1"]),
    team2: Team.fromMap(json["team2"]),
    seriesDesc: json["seriesDesc"],
    seriesId: json["seriesId"],
    seriesName: json["seriesName"],
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
    "playersOfTheMatch": List<dynamic>.from(playersOfTheMatch.map((x) => x.toMap())),
    "playersOfTheSeries": List<dynamic>.from(playersOfTheSeries.map((x) => x)),
    "matchTeamInfo": List<dynamic>.from(matchTeamInfo.map((x) => x.toMap())),
    "isMatchNotCovered": isMatchNotCovered,
    "team1": team1.toMap(),
    "team2": team2.toMap(),
    "seriesDesc": seriesDesc,
    "seriesId": seriesId,
    "seriesName": seriesName,
  };
}

class MatchTeamInfo {
  int battingTeamId;
  String battingTeamShortName;
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
    battingTeamShortName: json["battingTeamShortName"],
    bowlingTeamId: json["bowlingTeamId"],
    bowlingTeamShortName: json["bowlingTeamShortName"],
  );

  Map<String, dynamic> toMap() => {
    "battingTeamId": battingTeamId,
    "battingTeamShortName": battingTeamShortName,
    "bowlingTeamId": bowlingTeamId,
    "bowlingTeamShortName": bowlingTeamShortName,
  };
}

class PlayersOfTheMatch {
  int id;
  String name;
  String fullName;
  String nickName;
  bool captain;
  bool keeper;
  bool substitute;
  String teamName;
  int faceImageId;

  PlayersOfTheMatch({
    this.id,
    this.name,
    this.fullName,
    this.nickName,
    this.captain,
    this.keeper,
    this.substitute,
    this.teamName,
    this.faceImageId,
  });

  factory PlayersOfTheMatch.fromJson(String str) => PlayersOfTheMatch.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory PlayersOfTheMatch.fromMap(Map<String, dynamic> json) => PlayersOfTheMatch(
    id: json["id"],
    name: json["name"],
    fullName: json["fullName"],
    nickName: json["nickName"],
    captain: json["captain"],
    keeper: json["keeper"],
    substitute: json["substitute"],
    teamName: json["teamName"],
    faceImageId: json["faceImageId"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "name": name,
    "fullName": fullName,
    "nickName": nickName,
    "captain": captain,
    "keeper": keeper,
    "substitute": substitute,
    "teamName": teamName,
    "faceImageId": faceImageId,
  };
}

class Result {
  String resultType;
  String winningTeam;
  int winningteamId;
  int winningMargin;
  bool winByRuns;
  bool winByInnings;

  Result({
    this.resultType,
    this.winningTeam,
    this.winningteamId,
    this.winningMargin,
    this.winByRuns,
    this.winByInnings,
  });

  factory Result.fromJson(String str) => Result.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Result.fromMap(Map<String, dynamic> json) => Result(
    resultType: json["resultType"],
    winningTeam: json["winningTeam"],
    winningteamId: json["winningteamId"],
    winningMargin: json["winningMargin"],
    winByRuns: json["winByRuns"],
    winByInnings: json["winByInnings"],
  );

  Map<String, dynamic> toMap() => {
    "resultType": resultType,
    "winningTeam": winningTeam,
    "winningteamId": winningteamId,
    "winningMargin": winningMargin,
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

class Miniscore {
  int inningsId;
  BatsmanNStriker batsmanStriker;
  BatsmanNStriker batsmanNonStriker;
  BatTeam batTeam;
  BowlerStriker bowlerStriker;
  BowlerStriker bowlerNonStriker;
  int overs;
  int target;
  PartnerShip partnerShip;
  double currentRunRate;
  int requiredRunRate;
  String lastWicket;
  MatchScoreDetails matchScoreDetails;
  List<LatestPerformance> latestPerformance;
  PpData ppData;
  List<dynamic> overSummaryList;
  String status;
  int ballsRem;
  double runsPerBall;
  int requiredRunsPerBall;
  int lastWicketScore;
  int remRunsToWin;
  int responseLastUpdated;

  Miniscore({
    this.inningsId,
    this.batsmanStriker,
    this.batsmanNonStriker,
    this.batTeam,
    this.bowlerStriker,
    this.bowlerNonStriker,
    this.overs,
    this.target,
    this.partnerShip,
    this.currentRunRate,
    this.requiredRunRate,
    this.lastWicket,
    this.matchScoreDetails,
    this.latestPerformance,
    this.ppData,
    this.overSummaryList,
    this.status,
    this.ballsRem,
    this.runsPerBall,
    this.requiredRunsPerBall,
    this.lastWicketScore,
    this.remRunsToWin,
    this.responseLastUpdated,
  });

  factory Miniscore.fromJson(String str) => Miniscore.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Miniscore.fromMap(Map<String, dynamic> json) => Miniscore(
    inningsId: json["inningsId"],
    batsmanStriker: BatsmanNStriker.fromMap(json["batsmanStriker"]),
    batsmanNonStriker: BatsmanNStriker.fromMap(json["batsmanNonStriker"]),
    batTeam: BatTeam.fromMap(json["batTeam"]),
    bowlerStriker: BowlerStriker.fromMap(json["bowlerStriker"]),
    bowlerNonStriker: BowlerStriker.fromMap(json["bowlerNonStriker"]),
    overs: json["overs"],
    target: json["target"],
    partnerShip: PartnerShip.fromMap(json["partnerShip"]),
    currentRunRate: json["currentRunRate"].toDouble(),
    requiredRunRate: json["requiredRunRate"],
    lastWicket: json["lastWicket"],
    matchScoreDetails: MatchScoreDetails.fromMap(json["matchScoreDetails"]),
    latestPerformance: List<LatestPerformance>.from(json["latestPerformance"].map((x) => LatestPerformance.fromMap(x))),
    ppData: PpData.fromMap(json["ppData"]),
    overSummaryList: List<dynamic>.from(json["overSummaryList"].map((x) => x)),
    status: json["status"],
    ballsRem: json["ballsRem"],
    runsPerBall: json["runsPerBall"].toDouble(),
    requiredRunsPerBall: json["requiredRunsPerBall"],
    lastWicketScore: json["lastWicketScore"],
    remRunsToWin: json["remRunsToWin"],
    responseLastUpdated: json["responseLastUpdated"],
  );

  Map<String, dynamic> toMap() => {
    "inningsId": inningsId,
    "batsmanStriker": batsmanStriker.toMap(),
    "batsmanNonStriker": batsmanNonStriker.toMap(),
    "batTeam": batTeam.toMap(),
    "bowlerStriker": bowlerStriker.toMap(),
    "bowlerNonStriker": bowlerNonStriker.toMap(),
    "overs": overs,
    "target": target,
    "partnerShip": partnerShip.toMap(),
    "currentRunRate": currentRunRate,
    "requiredRunRate": requiredRunRate,
    "lastWicket": lastWicket,
    "matchScoreDetails": matchScoreDetails.toMap(),
    "latestPerformance": List<dynamic>.from(latestPerformance.map((x) => x.toMap())),
    "ppData": ppData.toMap(),
    "overSummaryList": List<dynamic>.from(overSummaryList.map((x) => x)),
    "status": status,
    "ballsRem": ballsRem,
    "runsPerBall": runsPerBall,
    "requiredRunsPerBall": requiredRunsPerBall,
    "lastWicketScore": lastWicketScore,
    "remRunsToWin": remRunsToWin,
    "responseLastUpdated": responseLastUpdated,
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
  int bowlDots;
  int bowlBalls;
  double runsPerBall;

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
    this.bowlDots,
    this.bowlBalls,
    this.runsPerBall,
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
    bowlDots: json["bowlDots"],
    bowlBalls: json["bowlBalls"],
    runsPerBall: json["runsPerBall"].toDouble(),
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
    "bowlDots": bowlDots,
    "bowlBalls": bowlBalls,
    "runsPerBall": runsPerBall,
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
  String batTeamName;
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
    batTeamName: json["batTeamName"],
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
    "batTeamName": batTeamName,
    "score": score,
    "wickets": wickets,
    "overs": overs,
    "isDeclared": isDeclared,
    "isFollowOn": isFollowOn,
    "ballNbr": ballNbr,
  };
}

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
  PpData();

  factory PpData.fromJson(String str) => PpData.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory PpData.fromMap(Map<String, dynamic> json) => PpData(
  );

  Map<String, dynamic> toMap() => {
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

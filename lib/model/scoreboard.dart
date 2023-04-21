// To parse this JSON data, do
//
//     final scoreBoardResponse = scoreBoardResponseFromMap(jsonString);

import 'dart:convert';

class ScoreBoardResponse {
  ScoreBoardResponse({
    this.scoreCard,
    this.matchHeader,
    this.isMatchComplete,
    this.status,
    this.videos,
    this.responseLastUpdated,
  });

  List<ScoreCard> scoreCard;
  MatchHeader matchHeader;
  bool isMatchComplete;
  String status;
  List<dynamic> videos;
  int responseLastUpdated;

  factory ScoreBoardResponse.fromJson(String str) => ScoreBoardResponse.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ScoreBoardResponse.fromMap(Map<String, dynamic> json) => ScoreBoardResponse(
    scoreCard: List<ScoreCard>.from(json["scoreCard"].map((x) => ScoreCard.fromMap(x))),
    matchHeader: MatchHeader.fromMap(json["matchHeader"]),
    isMatchComplete: json["isMatchComplete"],
    status: json["status"],
    videos: List<dynamic>.from(json["videos"].map((x) => x)),
    responseLastUpdated: json["responseLastUpdated"],
  );

  Map<String, dynamic> toMap() => {
    "scoreCard": List<dynamic>.from(scoreCard.map((x) => x.toMap())),
    "matchHeader": matchHeader.toMap(),
    "isMatchComplete": isMatchComplete,
    "status": status,
    "videos": List<dynamic>.from(videos.map((x) => x)),
    "responseLastUpdated": responseLastUpdated,
  };
}

class MatchHeader {
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
    this.dayNumber,
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
  int dayNumber;
  String state;
  String status;
  RevisedTarget tossResults;
  Result result;
  RevisedTarget revisedTarget;
  List<PlayersOfThe> playersOfTheMatch;
  List<PlayersOfThe> playersOfTheSeries;
  List<MatchTeamInfo> matchTeamInfo;
  bool isMatchNotCovered;
  Team team1;
  Team team2;
  String seriesDesc;
  int seriesId;
  String seriesName;

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
    dayNumber: json["dayNumber"],
    state: json["state"],
    status: json["status"],
    tossResults: RevisedTarget.fromMap(json["tossResults"]),
    result: Result.fromMap(json["result"]),
    revisedTarget: RevisedTarget.fromMap(json["revisedTarget"]),
    playersOfTheMatch: List<PlayersOfThe>.from(json["playersOfTheMatch"].map((x) => PlayersOfThe.fromMap(x))),
    playersOfTheSeries: List<PlayersOfThe>.from(json["playersOfTheSeries"].map((x) => PlayersOfThe.fromMap(x))),
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
    "dayNumber": dayNumber,
    "state": state,
    "status": status,
    "tossResults": tossResults.toMap(),
    "result": result.toMap(),
    "revisedTarget": revisedTarget.toMap(),
    "playersOfTheMatch": List<dynamic>.from(playersOfTheMatch.map((x) => x.toMap())),
    "playersOfTheSeries": List<dynamic>.from(playersOfTheSeries.map((x) => x.toMap())),
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
  MatchTeamInfo({
    this.battingTeamId,
    this.battingTeamShortName,
    this.bowlingTeamId,
    this.bowlingTeamShortName,
  });

  int battingTeamId;
  String battingTeamShortName;
  int bowlingTeamId;
  String bowlingTeamShortName;

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

class PlayersOfThe {
  PlayersOfThe({
    this.id,
    this.name,
    this.fullName,
    this.nickName,
    this.captain,
    this.role,
    this.keeper,
    this.substitute,
    this.teamId,
    this.battingStyle,
    this.bowlingStyle,
    this.teamName,
    this.faceImageId,
  });

  int id;
  String name;
  String fullName;
  String nickName;
  bool captain;
  String role;
  bool keeper;
  bool substitute;
  int teamId;
  String battingStyle;
  String bowlingStyle;
  String teamName;
  int faceImageId;

  factory PlayersOfThe.fromJson(String str) => PlayersOfThe.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory PlayersOfThe.fromMap(Map<String, dynamic> json) => PlayersOfThe(
    id: json["id"],
    name: json["name"],
    fullName: json["fullName"],
    nickName: json["nickName"],
    captain: json["captain"],
    role: json["role"],
    keeper: json["keeper"],
    substitute: json["substitute"],
    teamId: json["teamId"],
    battingStyle: json["battingStyle"],
    bowlingStyle: json["bowlingStyle"],
    teamName: json["teamName"],
    faceImageId: json["faceImageId"],
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "name": name,
    "fullName": fullName,
    "nickName": nickName,
    "captain": captain,
    "role": role,
    "keeper": keeper,
    "substitute": substitute,
    "teamId": teamId,
    "battingStyle": battingStyle,
    "bowlingStyle": bowlingStyle,
    "teamName": teamName,
    "faceImageId": faceImageId,
  };
}

class Result {
  Result({
    this.resultType,
    this.winningTeam,
    this.winningteamId,
    this.winningMargin,
    this.winByRuns,
    this.winByInnings,
  });

  String resultType;
  String winningTeam;
  int winningteamId;
  int winningMargin;
  bool winByRuns;
  bool winByInnings;

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
  RevisedTarget();

  factory RevisedTarget.fromJson(String str) => RevisedTarget.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory RevisedTarget.fromMap(Map<String, dynamic> json) => RevisedTarget(
  );

  Map<String, dynamic> toMap() => {
  };
}

class Team {
  Team({
    this.id,
    this.name,
    this.playerDetails,
    this.shortName,
  });

  int id;
  String name;
  List<dynamic> playerDetails;
  String shortName;

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

class ScoreCard {
  ScoreCard({
    this.matchId,
    this.inningsId,
    this.timeScore,
    this.batTeamDetails,
    this.bowlTeamDetails,
    this.scoreDetails,
    this.extrasData,
    this.ppData,
    this.wicketsData,
    this.partnershipsData,
  });

  int matchId;
  int inningsId;
  int timeScore;
  BatTeamDetails batTeamDetails;
  BowlTeamDetails bowlTeamDetails;
  ScoreDetails scoreDetails;
  ExtrasData extrasData;
  RevisedTarget ppData;
  Map<String, WicketsDatum> wicketsData;
  Map<String, PartnershipsDatum> partnershipsData;

  factory ScoreCard.fromJson(String str) => ScoreCard.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ScoreCard.fromMap(Map<String, dynamic> json) => ScoreCard(
    matchId: json["matchId"],
    inningsId: json["inningsId"],
    timeScore: json["timeScore"],
    batTeamDetails: BatTeamDetails.fromMap(json["batTeamDetails"]),
    bowlTeamDetails: BowlTeamDetails.fromMap(json["bowlTeamDetails"]),
    scoreDetails: ScoreDetails.fromMap(json["scoreDetails"]),
    extrasData: ExtrasData.fromMap(json["extrasData"]),
    ppData: RevisedTarget.fromMap(json["ppData"]),
    wicketsData: Map.from(json["wicketsData"]).map((k, v) => MapEntry<String, WicketsDatum>(k, WicketsDatum.fromMap(v))),
    partnershipsData: Map.from(json["partnershipsData"]).map((k, v) => MapEntry<String, PartnershipsDatum>(k, PartnershipsDatum.fromMap(v))),
  );

  Map<String, dynamic> toMap() => {
    "matchId": matchId,
    "inningsId": inningsId,
    "timeScore": timeScore,
    "batTeamDetails": batTeamDetails.toMap(),
    "bowlTeamDetails": bowlTeamDetails.toMap(),
    "scoreDetails": scoreDetails.toMap(),
    "extrasData": extrasData.toMap(),
    "ppData": ppData.toMap(),
    "wicketsData": Map.from(wicketsData).map((k, v) => MapEntry<String, dynamic>(k, v.toMap())),
    "partnershipsData": Map.from(partnershipsData).map((k, v) => MapEntry<String, dynamic>(k, v.toMap())),
  };
}

class BatTeamDetails {
  BatTeamDetails({
    this.batTeamId,
    this.batTeamName,
    this.batTeamShortName,
    this.batsmenData,
  });

  int batTeamId;
  String batTeamName;
  String batTeamShortName;
  Map<String, BatsmenDatum> batsmenData;

  factory BatTeamDetails.fromJson(String str) => BatTeamDetails.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory BatTeamDetails.fromMap(Map<String, dynamic> json) => BatTeamDetails(
    batTeamId: json["batTeamId"],
    batTeamName: json["batTeamName"],
    batTeamShortName: json["batTeamShortName"],
    batsmenData: Map.from(json["batsmenData"]).map((k, v) => MapEntry<String, BatsmenDatum>(k, BatsmenDatum.fromMap(v))),
  );

  Map<String, dynamic> toMap() => {
    "batTeamId": batTeamId,
    "batTeamName": batTeamName,
    "batTeamShortName": batTeamShortName,
    "batsmenData": Map.from(batsmenData).map((k, v) => MapEntry<String, dynamic>(k, v.toMap())),
  };
}

class BatsmenDatum {
  BatsmenDatum({
    this.batId,
    this.batName,
    this.batShortName,
    this.isCaptain,
    this.isKeeper,
    this.runs,
    this.balls,
    this.dots,
    this.fours,
    this.sixes,
    this.mins,
    this.strikeRate,
    this.outDesc,
    this.bowlerId,
    this.fielderId1,
    this.fielderId2,
    this.fielderId3,
    this.ones,
    this.twos,
    this.threes,
    this.fives,
    this.boundaries,
    this.sixers,
    this.wicketCode,
  });

  int batId;
  String batName;
  String batShortName;
  bool isCaptain;
  bool isKeeper;
  int runs;
  int balls;
  int dots;
  int fours;
  int sixes;
  int mins;
  double strikeRate;
  String outDesc;
  int bowlerId;
  int fielderId1;
  int fielderId2;
  int fielderId3;
  int ones;
  int twos;
  int threes;
  int fives;
  int boundaries;
  int sixers;
  String wicketCode;

  factory BatsmenDatum.fromJson(String str) => BatsmenDatum.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory BatsmenDatum.fromMap(Map<String, dynamic> json) => BatsmenDatum(
    batId: json["batId"],
    batName: json["batName"],
    batShortName: json["batShortName"],
    isCaptain: json["isCaptain"],
    isKeeper: json["isKeeper"],
    runs: json["runs"],
    balls: json["balls"],
    dots: json["dots"],
    fours: json["fours"],
    sixes: json["sixes"],
    mins: json["mins"],
    strikeRate: json["strikeRate"].toDouble(),
    outDesc: json["outDesc"],
    bowlerId: json["bowlerId"],
    fielderId1: json["fielderId1"],
    fielderId2: json["fielderId2"],
    fielderId3: json["fielderId3"],
    ones: json["ones"],
    twos: json["twos"],
    threes: json["threes"],
    fives: json["fives"],
    boundaries: json["boundaries"],
    sixers: json["sixers"],
    wicketCode: json["wicketCode"],
  );

  Map<String, dynamic> toMap() => {
    "batId": batId,
    "batName": batName,
    "batShortName": batShortName,
    "isCaptain": isCaptain,
    "isKeeper": isKeeper,
    "runs": runs,
    "balls": balls,
    "dots": dots,
    "fours": fours,
    "sixes": sixes,
    "mins": mins,
    "strikeRate": strikeRate,
    "outDesc": outDesc,
    "bowlerId": bowlerId,
    "fielderId1": fielderId1,
    "fielderId2": fielderId2,
    "fielderId3": fielderId3,
    "ones": ones,
    "twos": twos,
    "threes": threes,
    "fives": fives,
    "boundaries": boundaries,
    "sixers": sixers,
    "wicketCode": wicketCode,
  };
}

class BowlTeamDetails {
  BowlTeamDetails({
    this.bowlTeamId,
    this.bowlTeamName,
    this.bowlTeamShortName,
    this.bowlersData,
  });

  int bowlTeamId;
  String bowlTeamName;
  String bowlTeamShortName;
  Map<String, Bowl> bowlersData;

  factory BowlTeamDetails.fromJson(String str) => BowlTeamDetails.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory BowlTeamDetails.fromMap(Map<String, dynamic> json) => BowlTeamDetails(
    bowlTeamId: json["bowlTeamId"],
    bowlTeamName: json["bowlTeamName"],
    bowlTeamShortName: json["bowlTeamShortName"],
    bowlersData: Map.from(json["bowlersData"]).map((k, v) => MapEntry<String, Bowl>(k, Bowl.fromMap(v))),

  );

  Map<String, dynamic> toMap() => {
    "bowlTeamId": bowlTeamId,
    "bowlTeamName": bowlTeamName,
    "bowlTeamShortName": bowlTeamShortName,
    "bowlersData": Map.from(bowlersData).map((k, v) => MapEntry<String, dynamic>(k, v.toMap())),

  };
}

/*
class BowlersData {
  BowlersData({
    this.bowl1,
    this.bowl4,
    this.bowl6,
    this.bowl5,
    this.bowl3,
    this.bowl2,
  });

  Bowl bowl1;
  Bowl bowl4;
  Bowl bowl6;
  Bowl bowl5;
  Bowl bowl3;
  Bowl bowl2;

  factory BowlersData.fromJson(String str) => BowlersData.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory BowlersData.fromMap(Map<String, dynamic> json) => BowlersData(
    bowl1: Bowl.fromMap(json["bowl_1"]),
    bowl4: Bowl.fromMap(json["bowl_4"]),
    bowl6: Bowl.fromMap(json["bowl_6"]),
    bowl5: Bowl.fromMap(json["bowl_5"]),
    bowl3: Bowl.fromMap(json["bowl_3"]),
    bowl2: Bowl.fromMap(json["bowl_2"]),
  );

  Map<String, dynamic> toMap() => {
    "bowl_1": bowl1.toMap(),
    "bowl_4": bowl4.toMap(),
    "bowl_6": bowl6.toMap(),
    "bowl_5": bowl5.toMap(),
    "bowl_3": bowl3.toMap(),
    "bowl_2": bowl2.toMap(),
  };
}
*/

class Bowl {
  Bowl({
    this.bowlerId,
    this.bowlName,
    this.bowlShortName,
    this.isCaptain,
    this.isKeeper,
    this.overs,
    this.maidens,
    this.runs,
    this.wickets,
    this.economy,
    this.noBalls,
    this.wides,
    this.dots,
    this.balls,
    this.runsPerBall,
  });

  int bowlerId;
  String bowlName;
  String bowlShortName;
  bool isCaptain;
  bool isKeeper;
  double overs;
  int maidens;
  int runs;
  int wickets;
  double economy;
  int noBalls;
  int wides;
  int dots;
  int balls;
  double runsPerBall;

  factory Bowl.fromJson(String str) => Bowl.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Bowl.fromMap(Map<String, dynamic> json) => Bowl(
    bowlerId: json["bowlerId"],
    bowlName: json["bowlName"],
    bowlShortName: json["bowlShortName"],
    isCaptain: json["isCaptain"],
    isKeeper: json["isKeeper"],
    overs: json["overs"].toDouble(),
    maidens: json["maidens"],
    runs: json["runs"],
    wickets: json["wickets"],
    economy: json["economy"].toDouble(),
    noBalls: json["no_balls"],
    wides: json["wides"],
    dots: json["dots"],
    balls: json["balls"],
    runsPerBall: json["runsPerBall"].toDouble(),
  );

  Map<String, dynamic> toMap() => {
    "bowlerId": bowlerId,
    "bowlName": bowlName,
    "bowlShortName": bowlShortName,
    "isCaptain": isCaptain,
    "isKeeper": isKeeper,
    "overs": overs,
    "maidens": maidens,
    "runs": runs,
    "wickets": wickets,
    "economy": economy,
    "no_balls": noBalls,
    "wides": wides,
    "dots": dots,
    "balls": balls,
    "runsPerBall": runsPerBall,
  };
}

class ExtrasData {
  ExtrasData({
    this.noBalls,
    this.total,
    this.byes,
    this.penalty,
    this.wides,
    this.legByes,
  });

  int noBalls;
  int total;
  int byes;
  int penalty;
  int wides;
  int legByes;

  factory ExtrasData.fromJson(String str) => ExtrasData.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ExtrasData.fromMap(Map<String, dynamic> json) => ExtrasData(
    noBalls: json["noBalls"],
    total: json["total"],
    byes: json["byes"],
    penalty: json["penalty"],
    wides: json["wides"],
    legByes: json["legByes"],
  );

  Map<String, dynamic> toMap() => {
    "noBalls": noBalls,
    "total": total,
    "byes": byes,
    "penalty": penalty,
    "wides": wides,
    "legByes": legByes,
  };
}

class PartnershipsDatum {
  PartnershipsDatum({
    this.bat1Id,
    this.bat1Name,
    this.bat1Runs,
    this.bat1Fours,
    this.bat1Sixes,
    this.bat2Id,
    this.bat2Name,
    this.bat2Runs,
    this.bat2Fours,
    this.bat2Sixes,
    this.totalRuns,
    this.totalBalls,
    this.bat1Balls,
    this.bat2Balls,
    this.bat1Ones,
    this.bat1Twos,
    this.bat1Threes,
    this.bat1Fives,
    this.bat1Boundaries,
    this.bat1Sixers,
    this.bat2Ones,
    this.bat2Twos,
    this.bat2Threes,
    this.bat2Fives,
    this.bat2Boundaries,
    this.bat2Sixers,
  });

  int bat1Id;
  String bat1Name;
  int bat1Runs;
  int bat1Fours;
  int bat1Sixes;
  int bat2Id;
  String bat2Name;
  int bat2Runs;
  int bat2Fours;
  int bat2Sixes;
  int totalRuns;
  int totalBalls;
  int bat1Balls;
  int bat2Balls;
  int bat1Ones;
  int bat1Twos;
  int bat1Threes;
  int bat1Fives;
  int bat1Boundaries;
  int bat1Sixers;
  int bat2Ones;
  int bat2Twos;
  int bat2Threes;
  int bat2Fives;
  int bat2Boundaries;
  int bat2Sixers;

  factory PartnershipsDatum.fromJson(String str) => PartnershipsDatum.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory PartnershipsDatum.fromMap(Map<String, dynamic> json) => PartnershipsDatum(
    bat1Id: json["bat1Id"],
    bat1Name: json["bat1Name"],
    bat1Runs: json["bat1Runs"],
    bat1Fours: json["bat1fours"],
    bat1Sixes: json["bat1sixes"],
    bat2Id: json["bat2Id"],
    bat2Name: json["bat2Name"],
    bat2Runs: json["bat2Runs"],
    bat2Fours: json["bat2fours"],
    bat2Sixes: json["bat2sixes"],
    totalRuns: json["totalRuns"],
    totalBalls: json["totalBalls"],
    bat1Balls: json["bat1balls"],
    bat2Balls: json["bat2balls"],
    bat1Ones: json["bat1Ones"],
    bat1Twos: json["bat1Twos"],
    bat1Threes: json["bat1Threes"],
    bat1Fives: json["bat1Fives"],
    bat1Boundaries: json["bat1Boundaries"],
    bat1Sixers: json["bat1Sixers"],
    bat2Ones: json["bat2Ones"],
    bat2Twos: json["bat2Twos"],
    bat2Threes: json["bat2Threes"],
    bat2Fives: json["bat2Fives"],
    bat2Boundaries: json["bat2Boundaries"],
    bat2Sixers: json["bat2Sixers"],
  );

  Map<String, dynamic> toMap() => {
    "bat1Id": bat1Id,
    "bat1Name": bat1Name,
    "bat1Runs": bat1Runs,
    "bat1fours": bat1Fours,
    "bat1sixes": bat1Sixes,
    "bat2Id": bat2Id,
    "bat2Name": bat2Name,
    "bat2Runs": bat2Runs,
    "bat2fours": bat2Fours,
    "bat2sixes": bat2Sixes,
    "totalRuns": totalRuns,
    "totalBalls": totalBalls,
    "bat1balls": bat1Balls,
    "bat2balls": bat2Balls,
    "bat1Ones": bat1Ones,
    "bat1Twos": bat1Twos,
    "bat1Threes": bat1Threes,
    "bat1Fives": bat1Fives,
    "bat1Boundaries": bat1Boundaries,
    "bat1Sixers": bat1Sixers,
    "bat2Ones": bat2Ones,
    "bat2Twos": bat2Twos,
    "bat2Threes": bat2Threes,
    "bat2Fives": bat2Fives,
    "bat2Boundaries": bat2Boundaries,
    "bat2Sixers": bat2Sixers,
  };
}

class ScoreDetails {
  ScoreDetails({
    this.ballNbr,
    this.isDeclared,
    this.isFollowOn,
    this.overs,
    this.revisedOvers,
    this.runRate,
    this.runs,
    this.wickets,
    this.runsPerBall,
  });

  int ballNbr;
  bool isDeclared;
  bool isFollowOn;
  double overs;
  dynamic revisedOvers;
  double runRate;
  int runs;
  int wickets;
  double runsPerBall;

  factory ScoreDetails.fromJson(String str) => ScoreDetails.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ScoreDetails.fromMap(Map<String, dynamic> json) => ScoreDetails(
    ballNbr: json["ballNbr"],
    isDeclared: json["isDeclared"],
    isFollowOn: json["isFollowOn"],
    overs: json["overs"].toDouble(),
    revisedOvers: json["revisedOvers"],
    runRate: json["runRate"].toDouble(),
    runs: json["runs"],
    wickets: json["wickets"],
    runsPerBall: json["runsPerBall"].toDouble(),
  );

  Map<String, dynamic> toMap() => {
    "ballNbr": ballNbr,
    "isDeclared": isDeclared,
    "isFollowOn": isFollowOn,
    "overs": overs,
    "revisedOvers": revisedOvers,
    "runRate": runRate,
    "runs": runs,
    "wickets": wickets,
    "runsPerBall": runsPerBall,
  };
}

class WicketsDatum {
  WicketsDatum({
    this.batId,
    this.batName,
    this.wktNbr,
    this.wktOver,
    this.wktRuns,
    this.ballNbr,
  });

  int batId;
  String batName;
  int wktNbr;
  double wktOver;
  int wktRuns;
  int ballNbr;

  factory WicketsDatum.fromJson(String str) => WicketsDatum.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory WicketsDatum.fromMap(Map<String, dynamic> json) => WicketsDatum(
    batId: json["batId"],
    batName: json["batName"],
    wktNbr: json["wktNbr"],
    wktOver: json["wktOver"].toDouble(),
    wktRuns: json["wktRuns"],
    ballNbr: json["ballNbr"],
  );

  Map<String, dynamic> toMap() => {
    "batId": batId,
    "batName": batName,
    "wktNbr": wktNbr,
    "wktOver": wktOver,
    "wktRuns": wktRuns,
    "ballNbr": ballNbr,
  };
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app/api/api_config.dart';
import 'package:app/model/post.dart';

import 'package:app/model/staff.dart';
import 'package:app/model/status.dart';


class apiRest{
  static Uri getHomeItems(){
    return configUrl("home/all/");
  }
  static Uri getClubItems(){
    return configUrl("team/all/");
  }
  static Uri getPlayersByTeam(int id){
    return configUrl("players/by/team/"+id.toString()+"/");
  }
  static Uri getArticlesByTeam(int id){
    return configUrl("articles/by/team/"+id.toString()+"/");
  }
  static Uri getTrophiesByTeam(int id){
    return configUrl("trophies/by/team/"+id.toString()+"/");
  }

  static Uri getStaffsByTeam(int id){
    return configUrl("staffs/by/team/"+id.toString()+"/");
  }

  static Uri configUrl(String url){
    var uri = Uri.https(apiConfig.api_url.replaceAll("/api/", "").replaceAll("https://", "").replaceAll("http://", ""), '/api/'+url+apiConfig.api_token+"/"+apiConfig.item_purchase_code +"/", {"s":"https"});
    
    return uri;
  }

  static registerUser() {
    return configUrl("user/register/");
  }

  static submitAnswer() {
    return configUrl("question/vote/");
  }

  static getCommentsBy(Post post, Status status) {
    String id = (post == null)? status.id.toString() : post.id.toString();
    String type = (post == null)? "status" : "post";
    return configUrl("comments/by/"+type+"/"+id+"/");
  }

  static submitComment(Post post, Status status) {
    String type = (post == null)? "status" : "post";
    return configUrl("comment/"+type+"/add/");
  }

  static submitQuote() {
    return configUrl("quote/upload/");
  }
  static submitImage() {
    return configUrl("image/upload/");
  }

  static Uri submitVideo() {
    return configUrl("video/upload/");
  }
  static Uri statusByPage(int page){
    return configUrl("status/all/"+page.toString()+"/created/");
  }

  static toggleLike(String state) {
    return configUrl("status/"+state+"/like/");

  }
  static getPostById(String id) {
    return configUrl("post/by/id/"+id+"/");
  }
  static competitionsTables() {
    return configUrl("competition/tables/");
  }
  static tableByCompetition(String id) {
    return configUrl("tables/by/competition/"+id+"/");
  }

  static addPostShare() {
    return configUrl("post/add/share/");
  }

  static addPostView() {
    return configUrl("post/add/view/");
  }

  static addStatusShare() {
    return configUrl("status/add/share/");
  }

  static addStatusView() {
    return configUrl("status/add/view/");
  }
  static addStatusDownload() {
    return configUrl("status/add/download/");
  }

  static competitionsList() {
    return configUrl("competition/all/");
  }



  static getAppConfig() {
    return configUrl("app/config/");

  }
  static matchesByCompetition(int id,int page) {
    return configUrl("match/by/competition/"+id.toString()+"/"+page.toString()+"/");
  }
  static matchesByClubs(int home,int away) {
    return configUrl("match/by/clubs/"+home.toString()+"/"+away.toString()+"/");
  }

  static matchStatistics(int id) {
    return configUrl("match/statistics/by/"+id.toString()+"/");
  }

  static matchEvents(int id) {
    return configUrl("match/events/by/"+id.toString()+"/");

  }

  static postByPage(int page) {
    return configUrl("post/all/"+page.toString()+"/");
  }

  static Uri editProfile() {
    return configUrl("user/edit/");
  }

  static getStatusById(String id) {
    return configUrl("status/by/id/"+id+"/");
  }

  static getMatchById(String id) {
    return configUrl("match/by/id/"+id+"/");
  }
   static  getEScoreMatch(String matchType) async{
     final url = Uri.https('cricbuzz-cricket.p.rapidapi.com', '/matches/v1/${matchType}');
     final headers = {
       'X-RapidAPI-Key': 'b02f18ba79msh5aeb7cc8654aa62p1a3ec8jsnd35b04eea9f5',
       'X-RapidAPI-Host': 'cricbuzz-cricket.p.rapidapi.com',
       'useQueryString': 'true'
     };
     final response = await http.get(url, headers: headers);
     if (response.statusCode == 200) {
       final responseBody = jsonDecode(response.body);
       print(responseBody);
     } else {
       print('Request failed with status: ${response.statusCode}.');
     }

     return response;
  }


 static  getLiveMatchData(String matchType) async{
     final response = await http.get(Uri.parse("http://cricpro.cricnet.co.in/api/values/${matchType}"));
    print(response.body);
     return response;
  }
   static  getMatchDetails(String matchID) async{
     final response = await http.post(Uri.parse("http://cricpro.cricnet.co.in/api/values/LiveLine_Match"),body: {
       "MatchId":matchID
     });
    print(response.body);
     return response;
  }






     static  getScoreBoard(int matchID) async{
     final url = Uri.https('cricbuzz-cricket.p.rapidapi.com', '/mcenter/v1/${matchID}/hscard');
     final headers = {
       'X-RapidAPI-Key': '28534cb2afmshcf773b843ad2311p17ce28jsn11c3678679bb',
       'X-RapidAPI-Host': 'cricbuzz-cricket.p.rapidapi.com',
       'useQueryString': 'true'
     };
     final response = await http.get(url, headers: headers);
     if (response.statusCode == 200) {
       final responseBody = jsonDecode(response.body);
       print(responseBody);
     } else {
       print('Request failed with status: ${response.statusCode}.');
     }
     return response;
  }
 static  geMatchOver(int matchID) async{
     final url = Uri.https('cricbuzz-cricket.p.rapidapi.com', '/mcenter/v1/${matchID}/overs');
     final headers = {
       'X-RapidAPI-Key': '28534cb2afmshcf773b843ad2311p17ce28jsn11c3678679bb',
       'X-RapidAPI-Host': 'cricbuzz-cricket.p.rapidapi.com',
       'useQueryString': 'true'
     };
     final response = await http.get(url, headers: headers);
     if (response.statusCode == 200) {
       final responseBody = jsonDecode(response.body);
       print(responseBody);
     } else {
       print('Request failed with status: ${response.statusCode}.');
     }
     return response;
  }

 static  getCommentary(int matchID) async{
     final url = Uri.https('cricbuzz-cricket.p.rapidapi.com', '/mcenter/v1/${matchID}/comm');
     final headers = {
       'X-RapidAPI-Key': '28534cb2afmshcf773b843ad2311p17ce28jsn11c3678679bb',
       'X-RapidAPI-Host': 'cricbuzz-cricket.p.rapidapi.com',
       'useQueryString': 'true'
     };
     final response = await http.get(url, headers: headers);
     if (response.statusCode == 200) {
       final responseBody = jsonDecode(response.body);
       print(responseBody);
     } else {
       print('Request failed with status: ${response.statusCode}.');
     }
     return response;
  }



   static Uri getLiveMatch() {
    return Uri.parse("https://api.cricapi.com/v1/currentMatches?apikey=ba0e71f6-aff7-4466-839a-1ab9a09f20db&offset=0");
  }





  static Uri sendMessage() {
    return configUrl("support/add/");
  }
}
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

  static Uri sendMessage() {
    return configUrl("support/add/");
  }
}
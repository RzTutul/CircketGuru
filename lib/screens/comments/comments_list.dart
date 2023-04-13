
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart' as ft;
import 'package:line_icons/line_icons.dart';
import 'package:app/api/api_rest.dart';
import 'package:app/config/colors.dart';
import 'package:app/model/comment.dart';
import 'package:app/model/post.dart';
import 'package:app/model/status.dart';
import 'package:app/screens/comments/comment_widget.dart';
import 'package:app/screens/empty.dart';

import 'package:app/screens/loading.dart';
import 'package:app/screens/tryagain.dart';
import 'package:http/http.dart' as http;
import 'package:app/screens/user/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert' as convert;


import 'package:need_resume/need_resume.dart';

import 'package:crypto/crypto.dart';


class CommentsList extends StatefulWidget {

  Post post;
  Status status;


  CommentsList({this.post,this.status});

  @override
  _CommentsListState createState() => _CommentsListState();
}

class _CommentsListState extends ResumableState<CommentsList> {
  var logged = false;
  List<Comment> commentsList = [];
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  bool loading =  false;
  bool submitLoading =  false;
  String state =  "progress";
  bool refreshing =  true;
  TextEditingController commentController = new TextEditingController();
  ScrollController listViewController= new ScrollController();


  final key = new GlobalKey<ScaffoldState>();

  Image image = Image.asset("assets/images/profile.jpg");

  @override
  void onResume() {
    // Implement your code inside here
    setState(() {
      getLogged();
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    refreshing = false;
    _getList();
    getLogged();
    super.initState();

  }



  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: "comment_hero_"+((widget.post !=  null)? widget.post.id.toString():widget.status.id.toString()),
      child: Scaffold(
        key: key,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,

        appBar: AppBar(
          centerTitle: false,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            iconTheme: IconThemeData(color: Theme.of(context).textTheme.bodyText1.color),
            leading: new IconButton(
              icon: new Icon(LineIcons.angleLeft),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(((widget.post !=  null)? widget.post.comments:widget.status.comments).toString() + " Comments",style: TextStyle(color: Theme.of(context).textTheme.bodyText1.color)),
            elevation: 0,
            actions: [
              Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    onTap: () {},
                    child: Icon(
                        LineIcons.comments
                    ),
                  )
              ),
            ],
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Positioned(
                  bottom:(widget.post!=null)? ((widget.post.comment == true)? 60:  0) :  ((widget.status.comment == true)? 60:  0),
                  left: 0,
                  right: 0,
                  top: 0,
                  child: Container(
                      child: buildHome(),
                    decoration: BoxDecoration(
                      border: new Border(top: new BorderSide(color: Theme.of(context).textTheme.bodyText2.color.withOpacity(0.2), width: 0.5)),
                    ),
                  )
              ),
              Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child:Visibility(
                      visible:(widget.post != null )? widget.post.comment: widget.status.comment,
                      child: buildInput()
                  )
              )
            ],
          ),
        ),
      ),
    );
  }
  Widget buildInput() {
    return Container(
      padding: EdgeInsets.all(5),
      decoration:  BoxDecoration(
        border:  Border(top: new BorderSide(color: Theme.of(context).textTheme.bodyText2.color.withOpacity(0.2), width: 0.5)),
        color:  Theme.of(context).scaffoldBackgroundColor,

      ),
      child: Container(
        height: 50,
        decoration:  BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(50)
        ),
        child: Container(
          child: Row(
            children: <Widget>[
              // Button send image
              Container(
                  padding: EdgeInsets.all(10),
                  child: ClipOval(
                    child: Container(
                      child: image,
                    ),
                  )
              ),
              // Edit text
              Flexible(
                child: Container(
                  child: TextField(
                    controller: commentController,
                    style: TextStyle(color: Theme.of(context).textTheme.bodyText1.color, fontSize: 15.0),
                    decoration: InputDecoration.collapsed(
                      hintText: 'Type your message...',
                      hintStyle: TextStyle(color: Theme.of(context).textTheme.bodyText2.color),
                    ),
                  ),
                ),
              ),
              // Button send message
              Material(
                child:  (submitLoading)?
                Container(
                  height: 50,
                  width: 50,
                  padding: EdgeInsets.all(10),
                  child: CircularProgressIndicator(

                  ),
                )
                    :
                ClipOval(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Icon(
                          LineIcons.paperPlaneAlt, size: 20.0,
                          color:Theme.of(context).textTheme.bodyText1.color,
                        ),
                      ),
                      onTap: (){
                        _submitComment();
                      },
                    ),
                  ),
                ),
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(50),
              ),
            ],
          ),
          width: double.infinity,
          height: 50.0,
        ),
      ),
    );
  }

  Future<List<Comment>>  _getList() async{
    if(loading)
      return null;
    commentsList.clear();
    loading =  true;

    if(refreshing ==  false){
      setState(() {
        state =  "progress";
      });
      refreshing = true;
    }

    var response;
    var jsonData;
    var statusCode;
    try {
      response = await http.get(apiRest.getCommentsBy(widget.post,widget.status));
      jsonData =  convert.jsonDecode(response.body);
      statusCode = response.statusCode;
    } catch (ex) {
      statusCode == 500;
    }
    if(!loading)
      return null;

    if (statusCode == 200) {
      for(Map i in jsonData){
        Comment comment = Comment.fromJson(i);
        commentsList.add(comment);
      }
      setState(() {
        state =  "success";


        if(commentsList.length>0)
        Timer(
          Duration(milliseconds: 500),() {
            try{
              listViewController.animateTo(
                listViewController.position.maxScrollExtent,
                duration: Duration(milliseconds: 500),
                curve: Curves.fastOutSlowIn);
          }catch(ex){

          }
        });
      });
    } else {
      setState(() {
        state =  "error";
      });
    }
    loading = false;
    return commentsList;
  }
  Widget buildHome() {
    switch(state){
      case "success":
        return RefreshIndicator(
          backgroundColor: Theme.of(context).primaryColor,
          key: refreshKey,
          onRefresh:_getList,
          child:
          (commentsList.length ==  0)?
         EmptyWidget(context)
              :
          ListView.builder(
              controller: listViewController,
              itemCount: commentsList.length,
              itemBuilder: (context, index) {
                return CommentWidget(comment:commentsList[index]);
              }
          )
          ,
        );
        break;
      case "progress":
        return LoadingWidget();
        break;
      case "error":
        return TryAgainButton(action:(){
          refreshing = false;
          _getList();
        });
        break;
    }
  }
  Future<String>  _submitComment() async{
    if(commentController.text.isEmpty)
      return "";
    if(logged){

      setState(() {
        submitLoading = true;
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();

     int id_user = await prefs.getInt("ID_USER");
     String key_user = await prefs.getString("TOKEN_USER");
     String userimage = await prefs.getString("IMAGE_USER");
     String username = await prefs.getString("NAME_USER");

      String comment = commentController.text;
      convert.Codec<String, String> stringToBase64 = convert.utf8.fuse(convert.base64);
      String comment_base_64 = stringToBase64.encode(comment);

      var statusCode = 200;
      var jsonData;
      var response;
      try {
        response = await http.post(apiRest.submitComment(widget.post,widget.status), body: {"key":key_user,"user":id_user.toString(),"id": (widget.post !=  null)? widget.post.id.toString() : widget.status.id.toString(),'comment': comment_base_64});
        statusCode =  response.statusCode;
        jsonData =  convert.jsonDecode(response.body);

      } catch (ex) {
        statusCode =  500;
      }
      if(statusCode == 200 ){
        if(jsonData["code"] == 200){
          ft.Fluttertoast.showToast(
            msg:jsonData["message"],
            gravity: ft.ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
          Comment new_comment =  new Comment(content:comment_base_64,created: "Now",clear: comment,userid: id_user,userimage: userimage, username:username );
          setState(() {
            commentsList.add(new_comment);
            if(widget.status != null)
              widget.status.comments+=1;

            if(widget.post != null)
              widget.post.comments+=1;

            Timer(
                Duration(milliseconds: 500),() {
                 try{
              listViewController.animateTo(
                  listViewController.position.maxScrollExtent,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.fastOutSlowIn);
                 }catch(ex){

                 }
            });
          });
          commentController.text = "";




        }else{
          ft.Fluttertoast.showToast(
            msg: "Operation has been cancelled !",
            gravity: ft.ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      }else{
        ft.Fluttertoast.showToast(
            msg: "Operation has been cancelled !",
            gravity: ft.ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
        );
      }
      setState(() {
        submitLoading = false;
      });
    }else{
      push(context,
          PageRouteBuilder(
              pageBuilder: (BuildContext context,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation) {
                return Login();
              },
              transitionsBuilder: (context, animation,
                  secondaryAnimation, child) {
                var begin = Offset(0.0, 1.0);
                var end = Offset.zero;
                var tween = Tween(begin: begin, end: end);
                var offsetAnimation = animation.drive(tween);
                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
              transitionDuration: Duration(milliseconds: 300),
              opaque: false
          )
      );
    }
  }
  Future<String> getLogged() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    logged = await prefs.getBool("LOGGED_USER");

    if(logged == true) {
      image = Image.network(await prefs.getString("IMAGE_USER"));
    }else{
      logged = false;
      image = Image.asset("assets/images/profile.jpg");
    }
  }
}
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
//import 'package:gallery_saver/gallery_saver.dart';
import 'package:line_icons/line_icons.dart';
import 'package:app/api/api_rest.dart';
import 'package:app/config/colors.dart';
import 'package:app/model/status.dart';
import 'package:app/provider/ads_provider.dart';
import 'package:app/screens/comments/comments_list.dart';
import 'package:app/screens/other/report.dart';
import 'package:need_resume/need_resume.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

class StatusDetail extends StatefulWidget {
  Status status;
  Function liked;

  Function shared;
  Function viewed;
  Function downloaded;
  bool back;

  StatusDetail({this.status,this.liked, this.shared, this.viewed,this.downloaded,this.back = true});

  @override
  _StatusDetailState createState() => _StatusDetailState();

}

class _StatusDetailState extends ResumableState<StatusDetail> {
  List<String> menuList = ["Save to phone","Share external","Report photo"];
  List<IconData> menuIcons =[LineIcons.download,LineIcons.share,LineIcons.flag];
  List<Status> likedStatusList = [];

  File _image_thumbnail;
  StreamController<bool> _playController = StreamController.broadcast();
  int x=16;
  int y=9;
  String state;
  bool configured = false;



  TargetPlatform _platform;
  VideoPlayerController _videoPlayerController1;
  ChewieController _chewieController;


  Future<void> _future;

  Future<void> initVideoPlayer() async {
    await _videoPlayerController1.initialize();
    setState(() {
      print(_videoPlayerController1.value.aspectRatio);
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController1,
        aspectRatio:  _videoPlayerController1.value.aspectRatio,
        autoPlay: true,
        looping: true,
        autoInitialize: true
      );
    });
  }


  @override
  void deactivate() {
    // Pauses video while navigating to next page.
    _videoPlayerController1.pause();
    super.deactivate();
  }


  @override
  void onPause() {
    // Implement your code inside here
    _videoPlayerController1.pause();
    Wakelock.disable();

  }
  @override
  void dispose() {
    _videoPlayerController1.dispose();
    _chewieController.dispose();
    Wakelock.disable();

    super.dispose();
  }
  @override
  void onReady() {
    Wakelock.enable();

  }

  @override
  void onResume() {
    Wakelock.enable();
    _videoPlayerController1.play();

  }


  @override
  void initState() {
    super.initState();

    _videoPlayerController1 = VideoPlayerController.network(widget.status.original);
    _future = initVideoPlayer();

    if(widget.back == false)
      initLiked();

    if(widget.back == false)
      addView(widget.status);
    else
      widget.viewed(widget.status);
  }


  Widget _buildPlaceholder() {
    return StreamBuilder<bool>(
      stream: _playController.stream,
      builder: (context, snapshot) {
        bool showPlaceholder = snapshot.data ?? true;
        return AnimatedOpacity(
          duration: Duration(milliseconds: 10),
          opacity: showPlaceholder ? 1.0 : 0.0,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: Image.network(
                  widget.status.image,
                  fit: BoxFit.contain,
                ),
              ),
              Positioned(
                left: 0,
                  right: 0,
                  top: 0,
                  bottom: 0,

                  child: Center(child: new CircularProgressIndicator())
              )
            ],
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        platform:TargetPlatform.android,
      ),
      home: WillPopScope(
        onWillPop: () {
          (widget.back == true)? Navigator.of(context).pop():Navigator.pushReplacementNamed(context, "/home");
        },
        child: Material(
          color: Colors.transparent,
          child: Scaffold(
            backgroundColor:Colors.black,
            appBar: AppBar(
                elevation: 0,
                centerTitle: false,
                backgroundColor: Colors.transparent,
                iconTheme: IconThemeData(color: Colors.white),
                leading: new IconButton(
                  icon: new Icon(LineIcons.angleLeft),
                  onPressed: () => (widget.back == true)? Navigator.of(context).pop():Navigator.pushReplacementNamed(context, "/home"),
                ),
                actions: <Widget>[
                  PopupMenuButton<String>(
                    onSelected: (String index){
                          switch(index){
                            case "0":
                              _saveToPhone();
                              break;
                            case "1":
                              _shareVideo();
                              break;
                            case "2":
                              _reportVideo();
                              break;
                          }
                    },
                    color:  Color(0xFF191b20),
                    itemBuilder: (BuildContext context) {
                      return {0, 1,2}.map((int choice) {
                        return PopupMenuItem<String>(
                          value: choice.toString(),
                          child: Row(
                            children: [
                              Icon(menuIcons[choice],color:  Colors.white,size: 16),
                              SizedBox(width: 5),
                              Text(menuList[choice],style: TextStyle(color:  Colors.white)),
                            ],
                          ),
                        );
                      }).toList();
                    },
                  ),
                ],

            ),
            body:
            SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Hero(
                      tag: "image_hero_"+widget.status.id.toString(),
                      child:Center(
                        child: _videoPlayerController1.value.isInitialized
                            ? Theme(
                                data: Theme.of(context).copyWith(
                                  dialogBackgroundColor: Colors.black.withOpacity(0.5),
                                  iconTheme: IconThemeData(color: Colors.white),
                                ),
                              child: DefaultTextStyle(
                                style: TextStyle(color: Colors.white),
                                child: Chewie(
                                  controller: _chewieController,
                                ),
                              ),
                            )
                            : _buildPlaceholder(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10,right: 10,top: 10),
                    child: Text(
                      widget.status.username,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color:  Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  SizedBox(height:5),
                  Padding(
                    padding: EdgeInsets.only(left: 10,right: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(
                          LineIcons.clockAlt,
                          color:  Colors.grey,
                          size: 11,
                        ),
                        SizedBox(width:2),
                        Text(
                          widget.status.created,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color:  Theme.of(context).textTheme.bodyText2.color,
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height:10),
                  Padding(
                    padding: EdgeInsets.only(left: 10,right: 10,bottom: 10),
                    child: Text(
                      widget.status.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color:  Colors.white60,
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: Colors.grey))
                    ),
                    height: 50,
                    child:  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Expanded(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: (){
                                setState(() {
                                  if(widget.back == false)
                                    statusLiked(widget.status);
                                  else
                                    widget.liked(widget.status);
                                });
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 17,horizontal: 5),
                                    child: Icon(
                                      (widget.status.liked == true)?Icons.thumb_up:Icons.thumb_up_outlined,
                                      color:Colors.white70,
                                      size: 16,
                                    ),
                                  ),
                                  Text(
                                    widget.status.likes.toString()+ " Likes",
                                    style: TextStyle(
                                        color:Colors.white70,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child:
                          (state!=null)?
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                                child: SizedBox(child: CircularProgressIndicator(strokeWidth: 2),height: 20,width: 20),
                              ),
                              Text(
                                state,
                                style: TextStyle(
                                    color: Theme.of(context).textTheme.bodyText2.color,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12
                                ),
                              )
                            ],
                          )
                              :
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: (){
                                _shareVideo();
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 17,horizontal: 5),
                                    child: Icon(
                                      LineIcons.share,
                                      color:Colors.white70,
                                      size: 16,
                                    ),
                                  ),
                                  Text(
                                    widget.status.shares.toString()+" Shares",
                                    style: TextStyle(
                                        color:Colors.white70,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: (){
                                Route route = MaterialPageRoute(builder: (context) => CommentsList(status:widget.status));
                                Navigator.push(context, route);
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 17,horizontal: 5),
                                    child: Icon(
                                      LineIcons.commentsAlt,
                                      color:Colors.white70,
                                      size: 16,
                                    ),
                                  ),
                                  Text(
                                    widget.status.comments.toString()+" Comments",
                                    style: TextStyle(
                                        color:Colors.white70,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _shareVideo() async {
    setState(() {
      state = "Sharing ...";
    });
    var appDocDir = await getTemporaryDirectory();
    String savePath = appDocDir.path + "/"+widget.status.id.toString()+"_temp."+widget.status.extension;
    await Dio().download(widget.status.original, savePath);
    await Share.shareFiles([savePath], text: widget.status.description +" video");
    setState(() {
      state =null;
      if(widget.back == false)
        addShare(widget.status);
      else
        widget.shared(widget.status);
    });

  }
  void _saveToPhone() async {
    bool permission = false;


    if (Platform.isAndroid) {
      if (await Permission.storage.request().isGranted) {
        permission= true;
      }
    } else if (Platform.isIOS) {
      if (await Permission.photos.request().isGranted) {
        permission= true;

      }
    }

    if(permission == true) {

    setState(() {
      state = "Downloading ...";
    });
    String path = widget.status.original ;

    var appDocDir = await getTemporaryDirectory();
    String savePath = appDocDir.path +widget.status.id.toString() +"/video.mp4";
    await Dio().download(path, savePath);
    final result = await ImageGallerySaver.saveFile(savePath);
      setState(() {
        state = null;
        Fluttertoast.showToast(
          msg:"Your video has been downloaded successfully !",
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.blueAccent,
          textColor: Colors.white,
        );
        if(widget.back == false)
          addDownload(widget.status);
        else
          widget.downloaded(widget.status);
      });
    }else{
      Fluttertoast.showToast(
        msg: "Permission required !",
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.deepOrange,
        textColor: Colors.white,
      );
    }
  }

  statusLiked(Status status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String  favoriteStatussString=  await prefs.getString('status_liked');

    if(favoriteStatussString != null){
      likedStatusList = Status.decode(favoriteStatussString);
    }
    if(likedStatusList == null){
      likedStatusList= [];
    }

    Status liked_status =  null;

    for(Status current_status in likedStatusList){
      if(current_status.id == status.id){
        liked_status = current_status;
      }
    }

    if(liked_status == null){
      likedStatusList.add(status);
      setState(() {
        status.liked = true;
        status.likes+=1;
        _toggleLike(status,"add");

      });
    }else{
      likedStatusList.remove(liked_status);
      setState(() {
        status.liked = false;
        status.likes-=1;
        _toggleLike(status,"delete");
      });
    }
    String encodedData = Status.encode(likedStatusList);
    prefs.setString('status_liked',encodedData);
  }
  Future<String>  _toggleLike(Status status,String state) async{
    int id_ = status.id + 55463938;
    convert.Codec<String, String> stringToBase64 = convert.utf8.fuse(convert.base64);
    String id_base_64 = stringToBase64.encode(id_.toString());

    var statusCode = 200;
    var response;
    var jsonData;
    try {
      response = await http.post(apiRest.toggleLike(state), body: {'id': id_base_64});
      jsonData =  convert.jsonDecode(response.body);
    } catch (ex) {
      print(ex);
      statusCode =  500;
    }
  }

  addShare(Status status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('shared_status_' + status.id.toString()) != true) {
      prefs.setBool('shared_status_' + status.id.toString(), true);

      int id_ = status.id + 55463938;
      convert.Codec<String, String> stringToBase64 = convert.utf8.fuse(convert.base64);
      String id_base_64 = stringToBase64.encode(id_.toString());
      setState(() {
        status.shares = status.shares+1;
      });
      var statusCode = 200;
      var response;
      var jsonData;
      try {
        response = await http.post(apiRest.addStatusShare(), body: {'id': id_base_64});
        jsonData =  convert.jsonDecode(response.body);

      } catch (ex) {
        print(ex);
        statusCode =  500;
      }

    }
  }

  addView(Status status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('viewed_status_' + status.id.toString()) != true) {
      prefs.setBool('viewed_status_' + status.id.toString(), true);

      int id_ = status.id + 55463938;
      convert.Codec<String, String> stringToBase64 = convert.utf8.fuse(convert.base64);
      String id_base_64 = stringToBase64.encode(id_.toString());
      setState(() {
        status.views = status.views+1;
      });
      var statusCode = 200;
      var response;
      var jsonData;
      try {
        response = await http.post(apiRest.addStatusView(), body: {'id': id_base_64});
        jsonData =  convert.jsonDecode(response.body);

      } catch (ex) {
        print(ex);
        statusCode =  500;
      }

    }
  }
  addDownload(Status status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('downloaded_status_' + status.id.toString()) != true) {
      prefs.setBool('downloaded_status_' + status.id.toString(), true);

      int id_ = status.id + 55463938;
      convert.Codec<String, String> stringToBase64 = convert.utf8.fuse(convert.base64);
      String id_base_64 = stringToBase64.encode(id_.toString());
      setState(() {
        status.downloads = status.downloads+1;
      });
      var statusCode = 200;
      var response;
      var jsonData;
      try {
        response = await http.post(apiRest.addStatusDownload(), body: {'id': id_base_64});
        jsonData =  convert.jsonDecode(response.body);

      } catch (ex) {
        print(ex);
        statusCode =  500;
      }

    }
  }

  void initLiked() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String  likedStatusString=  await prefs.getString('status_liked');

    if(likedStatusString != null){
      likedStatusList = Status.decode(likedStatusString);
    }
    if(likedStatusList == null){
      likedStatusList= [];
    }

    for(Status liked_status in likedStatusList){
      if(liked_status.id == widget.status.id){
        setState(() {
          widget.status.liked = true;
        });
      }
    }
  }
  void _reportVideo() {
    Route route = MaterialPageRoute(builder: (context) => Report(message:"Report video :"+widget.status.description,image:  Image.network(widget.status.image,fit: BoxFit.cover),title: "Report "+widget.status.description,status: widget.status.id));
    Navigator.push(context, route);
  }


}

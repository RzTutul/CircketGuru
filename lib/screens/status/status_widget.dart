import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:line_icons/line_icons.dart';
import 'package:app/api/api_rest.dart';
import 'package:app/config/colors.dart';
import 'package:app/model/status.dart';
import 'package:app/screens/comments/comments_list.dart';
import 'package:app/screens/other/report.dart';
import 'package:app/screens/status/image_detail.dart';
import 'package:app/screens/status/quote_detail.dart';
import 'package:app/screens/status/status_detail.dart';
import 'package:share/share.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class StatusWidget extends StatefulWidget {
  Status status ;
  Function liked ;

  Function shared;
  Function viewed;
  Function downloaded;
  Function navigate;

  StatusWidget({this.status,this.liked, this.shared, this.viewed,this.downloaded,this.navigate});

  @override
  _StatusWidgetState createState() => _StatusWidgetState();
}

class _StatusWidgetState extends State<StatusWidget> {
  final GlobalKey _menuKey = new GlobalKey();

  String state = null;
  List<String> menuList = ["Report photo"];
  List<IconData> menuIcons =[LineIcons.flag];
  @override
  Widget build(BuildContext context) {



    return Container(
      margin: EdgeInsets.only(left: 10,right: 10,bottom: 5,top: 5),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(
              color: Colors.black54.withOpacity(0.2),
              offset: Offset(0,0),
              blurRadius: 5
          )]
      ),
      child:Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              width: MediaQuery.of(context).size.width,
              child:Stack(
                children: [
                  Positioned(
                    right: 0,
                    top: 2,
                    child: myPopMenu(),
                  ),
                  Positioned(
                      child: Container(
                        margin: EdgeInsets.only(left: 10,right: 10,top: 10,bottom: 10),
                        height: 35,
                        width: 35,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.blue,width: 2),
                          borderRadius: BorderRadius.circular(50)
                        ),
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: widget.status.userimage,
                            placeholder: (context, url) => CircularProgressIndicator(),
                            errorWidget: (context, url, error) => Icon(Icons.error),
                          ),
                        ),
                      )
                  ),
                  Positioned(
                      left: 30,
                      top: 30,
                      child: Visibility(
                        visible: widget.status.trusted,
                        child: Container(
                            padding: EdgeInsets.all(0.5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)
                            ),
                            child: Icon(Icons.check_circle,size: 15,color: Colors.blue),
                        ),
                      )
                  ),
                  Positioned(
                      right: 45,
                      left: 45,

                      child: Container(
                        margin: EdgeInsets.only(top: 5,left: 10),
                        height: 45,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.status.username,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Theme.of(context).textTheme.bodyText1.color,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height:2),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  LineIcons.clockAlt,
                                  color: Theme.of(context).textTheme.bodyText2.color,
                                  size: 11,
                                ),
                                SizedBox(width:2),
                                Text(
                                  widget.status.created,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Theme.of(context).textTheme.bodyText2.color,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                  ),

                ],
              ),
          ),
          Visibility(
            visible:(widget.status.kind != "quote" && !widget.status.description.isEmpty) ,
            child: Divider(
              color: Colors.grey.withOpacity(0.2),
            ),
          ),
          Visibility(
            visible:(widget.status.kind != "quote" && !widget.status.description.isEmpty) ,
            child: Padding(
              padding: const EdgeInsets.only(left: 8,right: 8,bottom: 8),
              child: Text(
                widget.status.description,
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyText2.color,
                  fontSize: 12
                ),
              ),
            ),
          ),
          (widget.status.kind == "quote")?
          GestureDetector(
            onTap: (){

              widget.navigate(widget.status,widget.liked,widget.shared, widget.viewed,widget.downloaded);

            },
            child: Hero(
              tag: "quote_hero_"+widget.status.id.toString(),
              child: Container(
                  child: RepaintBoundary(
                    key: _globalKey,
                    child: Container(
                      decoration: BoxDecoration(
                          color: Color(int.parse("0xff"+widget.status.color)),
                          borderRadius:BorderRadius.circular(10)
                      ),
                      child: ConstrainedBox(
                        constraints: new BoxConstraints(
                          minHeight: 200.0,
                        ),
                        child: Center(
                          child: Material(
                            color: Colors.transparent,
                            child: Text(
                                utf8.decode(base64Url.decode(widget.status.quote)),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.white
                                ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 20,vertical: 45),
                decoration: BoxDecoration(
                  color:Color(int.parse("0xff"+widget.status.color))
                ),
              ),
            ),
          )
              :
          GestureDetector(
            onTap: (){
              widget.navigate(widget.status,widget.liked,widget.shared, widget.viewed,widget.downloaded);
            },
            child: Hero(
              tag: "image_hero_"+widget.status.id.toString(),
              child: Container(
                child: Stack(
                  children: <Widget>[
                    ClipRRect(
                      child: ConstrainedBox(
                        constraints: new BoxConstraints(
                          maxHeight: 360,
                          minHeight: 200,
                        ),
                        child: CachedNetworkImage(
                          width: double.infinity,
                          imageUrl: widget.status.image,
                          placeholder: (context, url) => Image.asset("assets/images/placeholder.png",fit: BoxFit.cover),
                          errorWidget: (context, url, error) => Icon(Icons.error),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        color: Colors.black45,
                        height: 40,
                        width: 40,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Icon(
                            (widget.status.kind ==  "image")? LineIcons.camera:LineIcons.video,
                            color: Colors.white,
                            size: 15,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: (){
                            widget.liked(widget.status);
                        },
                        child:  Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 5),
                              child: Icon(
                                (widget.status.liked == true)?Icons.thumb_up:Icons.thumb_up_outlined,
                                color:Theme.of(context).textTheme.bodyText2.color,
                                size: 16,
                              ),
                            ),
                            Text(
                              widget.status.likes.toString()+" Likes",
                              style: TextStyle(
                                  color:Theme.of(context).textTheme.bodyText2.color,
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
                              if(widget.status.kind == "video"){
                                _shareVideo();
                              }
                              if(widget.status.kind == "image"){
                                _shareImage();
                              }
                              if(widget.status.kind == "quote"){
                                _capturePng();
                              }

                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 5),
                              child: Icon(
                                LineIcons.share,
                                color:Theme.of(context).textTheme.bodyText2.color,
                                size: 16,
                              ),
                            ),
                            Text(
                              widget.status.shares.toString()+" Shares",
                              style: TextStyle(
                                  color:Theme.of(context).textTheme.bodyText2.color,
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
                        child: Hero(
                          tag: "comment_hero_"+widget.status.id.toString(),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 5),
                                child: Icon(
                                  LineIcons.commentsAlt,
                                  color:Theme.of(context).textTheme.bodyText2.color,
                                  size: 16,
                                ),
                              ),
                              Material(
                                color: Colors.transparent,
                                child: Text(
                                  widget.status.comments.toString()+" Comments",
                                  style: TextStyle(
                                      color:Theme.of(context).textTheme.bodyText2.color,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ],
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
      widget.shared(widget.status);
    });

  }
  _shareImage() async {
    setState(() {
      state = "Sharing ...";
    });
    var appDocDir = await getTemporaryDirectory();
    String savePath = appDocDir.path + "/"+widget.status.id.toString()+"_temp."+widget.status.extension;
    await Dio().download(widget.status.original, savePath);
    await Share.shareFiles([savePath], text: widget.status.description +" image");
    setState(() {
      state = null;
      widget.shared(widget.status);
    });

  }

  bool inside = false;
  Uint8List imageInMemory;
  GlobalKey _globalKey = new GlobalKey();

  Future<void> _capturePng() async {
    try {
      print('inside');
      inside = true;
      RenderRepaintBoundary boundary =
      _globalKey.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();
      String bs64 = base64Encode(pngBytes);
      print(pngBytes);
      print(bs64);
      File.fromRawPath(pngBytes);

      final appDir = await getTemporaryDirectory();
      File file = File('${appDir.path}/sth.jpg');
      await file.writeAsBytes(pngBytes);
      await Share.shareFiles([file.path], text: utf8.decode(base64Url.decode(widget.status.quote)));
     setState(() {
       widget.shared(widget.status);
     });
    } catch (e) {
      print(e);
    }
  }
  void _reportQuote() {
    Route route = MaterialPageRoute(builder: (context) => Report(message:"Report "+widget.status.kind+" :"+widget.status.description,image: (widget.status.kind  == "quote")?Icon(Icons.format_quote,size: 100):Image.network(widget.status.image,fit: BoxFit.cover),title: "Report "+widget.status.description,status: widget.status.id));
    Navigator.push(context, route);
  }
  Widget myPopMenu() {
    return PopupMenuButton(
      icon: Icon(LineIcons.verticalEllipsis,size: 20),
        onSelected: (value) {
          _reportQuote();
        },
        itemBuilder: (context) => [
          PopupMenuItem(
              height: 40,
              value: 1,
              child: Row(
                children: <Widget>[
                  Icon(LineIcons.flag),
                  Text('Report')
                ],
              )),

        ]);
  }

}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:app/config/colors.dart';
import 'package:app/model/comment.dart';
import 'package:app/screens/other/report.dart';

class CommentWidget extends StatefulWidget {
  Comment comment ;

  CommentWidget({this.comment});

  @override
  State<CommentWidget> createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          child:Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: ClipOval(
                    child: Container(
                      child: CachedNetworkImage(
                        imageUrl: widget.comment.userimage,
                        placeholder: (context, url) => CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                        height: 30,
                        width: 30,
                      ),
                    ),
                  )
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10,vertical: 15),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Theme.of(context).cardColor,
                      boxShadow: [BoxShadow(
                          color: Theme.of(context).cardColor,
                          offset: Offset(0,0),
                          blurRadius: 1
                      )]
                  ),
                  child:Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          // Button send image
                          // Edit text
                          Flexible(
                            child: Container(
                              width: double.infinity,
                              child: Text(
                                widget.comment.username,
                                style: TextStyle(color: Theme.of(context).textTheme.bodyText1.color, fontSize: 15,fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                          Container(
                            child: Icon(
                              LineIcons.clockAlt,
                              color: Theme.of(context).textTheme.bodyText2.color,
                              size: 15,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(right: 25,left: 5),
                            child: Text(
                              widget.comment.created,
                              style: TextStyle(color: Theme.of(context).textTheme.bodyText2.color, fontSize: 11),
                            ),
                          ),

                          // Button send message
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 10),
                        child: Text(
                          (widget.comment.enabled == true)? widget.comment.clear : "Comment has been hidden !",
                          style: TextStyle(color: Theme.of(context).textTheme.bodyText2.color.withOpacity((widget.comment.enabled == true)? 1:0.2), fontSize: 12),
                        ),

                      )
                    ],
                  ),
                ),
              )
            ],
          ),
          margin: const EdgeInsets.all(7),

        ),
        Positioned(
          right: 0,
          top: 5,
          child: myPopMenu(),
        ),
      ],
    );

  }

  void _reportQuote() {
    Route route = MaterialPageRoute(builder: (context) => Report(message:"Report comment :"+widget.comment.clear+" , comment id : "+widget.comment.id.toString(),image: Icon(Icons.comment,size: 100),title: "Report "+widget.comment.clear,status: null));
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
                  Text('Report comment')
                ],
              )),
        ]);
  }
}

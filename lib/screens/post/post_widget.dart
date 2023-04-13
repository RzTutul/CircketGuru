import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/src/ad_containers.dart';
import 'package:line_icons/line_icons.dart';
import 'package:app/config/colors.dart';
import 'package:app/model/post.dart';
import 'package:app/screens/post/post_detail.dart';
import 'package:app/screens/post/video_detail.dart';
import 'package:app/screens/post/youtube_detail.dart';
class PostWidget extends StatefulWidget {
  Post post ;
  Function favorite ;
  Function navigate ;
  PostWidget({this.post,this.favorite, this.navigate });

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        widget.navigate(widget.post,widget.favorite);
      },
      child: Container(
        margin: EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(
                color: Colors.black54.withOpacity(0.2),
                offset: Offset(0,0),
                blurRadius: 5
            )]
        ),
        child:

            Column(
              children: [
                Stack(
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight: Radius.circular(10)),
                      child: CachedNetworkImage(
                        width: double.infinity,
                        imageUrl: widget.post.image,
                        placeholder: (context, url) => Image.asset("assets/images/placeholder.png",fit: BoxFit.cover,height: 170),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                        fit: BoxFit.cover,
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
                            (widget.post.type == "video")?LineIcons.video:((widget.post.type == "post")?LineIcons.file:LineIcons.youtubeSquare),
                            color: Colors.white,
                            size: 15,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                Container(
                  child: Padding(
                    padding: const EdgeInsets.only(left:10.0,right: 10,top: 10,bottom: 5),
                    child: Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              widget.post.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Theme.of(context).textTheme.bodyText1.color,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          ClipOval(
                            child: Container(
                              height: 40,
                              width: 40,
                              child: Material(
                                borderRadius: BorderRadius.circular(50),
                                color: Colors.transparent,
                                child: IconButton(
                                  onPressed: (){
                                    widget.favorite(widget.post);
                                  },
                                  icon: Icon(
                                    (widget.post.favorite == true)?LineIcons.heartAlt:LineIcons.heart,
                                    size: 25,
                                    color:  Theme.of(context).textTheme.bodyText1.color,
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Divider(
                  color: Theme.of(context).textTheme.bodyText1.color.withOpacity(0.2),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10,right: 10,bottom: 15,top: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(right:5.0),
                            child: Icon(
                              LineIcons.share,
                              color:Theme.of(context).textTheme.bodyText1.color,
                              size: 16,
                            ),
                          ),
                          Text(
                            widget.post.shares.toString() + " Shares",
                            style: TextStyle(
                                color:Theme.of(context).textTheme.bodyText1.color,
                                fontWeight: FontWeight.w600,
                                fontSize: 12
                            ),
                          )
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(right:5.0),
                            child: Icon(
                              LineIcons.eye,
                              color:Theme.of(context).textTheme.bodyText1.color,
                              size: 16,
                            ),
                          ),
                          Text(
                            widget.post.views.toString() + " Views",
                            style: TextStyle(
                                color:Theme.of(context).textTheme.bodyText1.color,
                                fontWeight: FontWeight.w600,
                                fontSize: 12
                            ),
                          )
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(right:5.0),
                            child: Icon(
                              LineIcons.commentAlt,
                              color:Theme.of(context).textTheme.bodyText1.color,
                              size: 16,
                            ),
                          ),
                          Text(
                            widget.post.comments.toString()+" Comments",
                            style: TextStyle(
                                color:Theme.of(context).textTheme.bodyText1.color,
                                fontWeight: FontWeight.w600,
                                fontSize: 12
                            ),
                          )
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(right:5.0),
                            child: Icon(
                              LineIcons.clockAlt,
                              color:Theme.of(context).textTheme.bodyText1.color,
                              size: 16,
                            ),
                          ),
                          Text(
                            widget.post.created,
                            style: TextStyle(
                                color:Theme.of(context).textTheme.bodyText1.color,
                                fontWeight: FontWeight.w600,
                                fontSize: 12
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
      ),
    );
  }
}

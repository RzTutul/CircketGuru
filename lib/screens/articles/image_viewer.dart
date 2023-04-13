import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:photo_view/photo_view.dart';

class ImageViewer extends StatefulWidget {
  String url;

  ImageViewer({this.url});

  @override
  _ImageViewerState createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: IconThemeData(color: Colors.white),
            leading: new IconButton(
              icon: new Icon(LineIcons.angleLeft),
              onPressed: () => Navigator.of(context).pop(),
            )
        ),
        body: Container(child: PhotoView(imageProvider: CachedNetworkImageProvider(widget.url.replaceAll("/uploads/cache/media_thumb/", "/").replaceAll("/media/cache/resolve/media_thumb/", "/"))))
    );
  }
}

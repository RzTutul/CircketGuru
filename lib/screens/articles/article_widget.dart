import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:app/config/colors.dart';
import 'package:app/model/article.dart';
import 'package:app/screens/articles/article_detail.dart';

class ArticleWidget extends StatelessWidget {
  Article article;
  Function navigate;
  int index;


  ArticleWidget({this.article,this.index,this.navigate});

  @override
  Widget build(BuildContext context) {

    return Container(
      height: 220,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
        child: GestureDetector(
          onTap: (){
            navigate(article);
          },
          child: Stack(
            children: <Widget>[
              Positioned(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(article.image),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned(
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color:(index % 2 == 0)? Colors.black.withOpacity(0.45):Theme.of(context).accentColor.withOpacity(0.45),
                      boxShadow: [BoxShadow(
                          color: Colors.black54.withOpacity(0.2),
                          offset: Offset(0,0),
                          blurRadius: 5
                      )]
                  ),
                ),
              ),

              Positioned(
                left: 0,
                right: 0,
                bottom: 10,
                child: Container(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          article.title,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white
                          ),
                        ),
                        SizedBox(height: 5),
                        Container(height: 5,width: 50,color: Colors.white,)
                      ],
                    )
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

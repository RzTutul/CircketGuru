import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:app/config/colors.dart';
import 'package:app/screens/articles/articles_list.dart';
import 'package:app/screens/players/players_list.dart';
import 'package:app/screens/staffs/staffs_list.dart';
import 'package:app/screens/trophies/trophies_list.dart';

class ClubItemWidget extends StatelessWidget {
  var team;
  Function navigate;


  ClubItemWidget({this.team,this.navigate});

  @override
  Widget build(BuildContext context) {

    return Container(
      height: 220,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
        child: GestureDetector(
          onTap: (){
              navigate(team);

          },
          child: Stack(
            children: <Widget>[
              Positioned(
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(team.image),
                        fit: BoxFit.cover,
                      ),
                  ),
                ),
              ),
              Positioned(
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color:(team.position % 2 == 0)? Colors.black.withOpacity(0.45):Theme.of(context).accentColor.withOpacity(0.45),
                      boxShadow: [BoxShadow(
                          color: Colors.black54.withOpacity(0.2),
                          offset: Offset(0,0),
                          blurRadius: 5
                      )]
                  ),
                ),
              ),

              Positioned(
                left: 70,
                bottom: 15,

                child: Container(
                  height: 55,
                    padding: EdgeInsets.all(7),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          team.title,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white
                          ),
                        ),
                        SizedBox(height: 0),
                        Text(
                          team.subtitle,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              color: Colors.white60
                          ),
                        ),
                      ],
                    )
                ),
              ),
              Positioned(
                bottom: 17,
                left: 15,
                child: Container(
                  color:(team.position % 2 == 0)? Theme.of(context).accentColor.withOpacity(0.9):Colors.black.withOpacity(0.45).withOpacity(0.9),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Center(child: Image.network(team.icon,height:   40,width: 40)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:app/config/colors.dart';
import 'package:app/model/player.dart';
import 'package:app/screens/players/player_detail.dart';

class PlayerMiniWidget extends StatelessWidget {
  Player player;
  String bgimage;

  PlayerMiniWidget({this.player,@required this.bgimage});

  @override
  Widget build(BuildContext context) {
    return   GestureDetector(
      onTap: (){
        Route route = MaterialPageRoute(builder: (context) => PlayerDetail(player: player));
        Navigator.push(context, route);
      },
      child: Container(
        margin: const EdgeInsets.all(5),
        width: 130,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).accentColor,
            boxShadow: [BoxShadow(
                color: Theme.of(context).accentColor.withOpacity(0.7),
                offset: Offset(0,0),
                blurRadius: 5
            )]
        ),
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: Stack(
            children: [
              Positioned(
                  child: Opacity(child: CachedNetworkImage(
                    height: 400,
                    imageUrl:bgimage,
                    errorWidget: (context, url, error) => Icon(Icons.error),
                    fit: BoxFit.fitHeight,
                  ),opacity: 0.1),
                  top: 10,
                  right: 10,
                  bottom: 10,
                  left: 10
              ),

              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Hero(
                  tag: "player_"+player.id.toString(),
                  child: Container(

                    child: Center(child: CachedNetworkImage(imageUrl:player.image,height:   140,width: 110, fit: BoxFit.fitHeight)),
                  ),
                ),
              ),

              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: Container(
                    height: 70,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Theme.of(context).accentColor, Theme.of(context).accentColor.withOpacity(0.3),Colors.transparent],

                        )
                    )
                ),
              ),

              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child:
                Container(
                    height: 30,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10),bottomRight: Radius.circular(10)),
                      color: Theme.of(context).accentColor,
                    )
                ),
              ),

              Positioned(
                right: 7,
                bottom: 7,
                child: Container(
                  height: 30,
                  width: 30,
                  child: Center(
                    child: Text(
                      player.number,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 20
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 5,
                top: 5,
                child: Container(
                  height: 20,
                  width: 20,
                  child: ClipOval(
                    child: Container(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: [Colors.white38, Colors.white38]
                          )
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(1.5),
                        child: ClipOval(
                          child: Container(
                            child: Image.network(
                                player.country_image,fit: BoxFit.cover
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                  bottom: 7,
                  left: 7,
                  right: 0,
                  child:
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(player.fname.toUpperCase(),
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11
                        ),
                      ),
                      Text(player.lname.toUpperCase(),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 11
                        ),
                      )
                    ],
                  )
              ),

            ],
          ),
        ),
      ),
    );
  }
}

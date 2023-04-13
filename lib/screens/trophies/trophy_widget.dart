import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:app/config/colors.dart';
import 'package:app/model/trophy.dart';
import 'package:app/screens/trophies/trophy_detail.dart';

class TrophyWidget extends StatelessWidget {

  Trophy trophy;

  TrophyWidget({this.trophy});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Route route = MaterialPageRoute(builder: (context) => TrophyDetail(trophy:trophy));
        Navigator.push(context, route);
      },
      child: Container(
        margin: EdgeInsets.only(top: 10,right: 10,left: 10),
        height: 170,
        width: (MediaQuery.of(context).size.width - 20),
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 0,
              left: 150,
              height: 40,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 0,horizontal: 0),
                child: Center(
                  child: Text(
                    trophy.title,
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyText1.color,
                        fontWeight: FontWeight.w800,
                        fontSize: 15
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              height: 130,
              width: MediaQuery.of(context).size.width - 20,
              child: Container(
                child: Stack(
                  children: [
                    ClipRRect(borderRadius: BorderRadius.circular(7),child: CachedNetworkImage(imageUrl: trophy.image,fit: BoxFit.cover,width: MediaQuery.of(context).size.width - 20)),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 125,
                      child: Container(
                        padding: EdgeInsets.only(left: 150),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color:Colors.black.withOpacity(0.45),
                        ),
                        child: Center(
                          child: Text(
                            trophy.description,
                            maxLines: 6,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Theme.of(context).textTheme.bodyText2.color,width: 3),
                ),
              ),
            ),
            Positioned(
              left: 10,
              bottom: 10,
              height: 160,
              width: 130,
              child: Container(
                padding: EdgeInsets.all(10),
                child: Stack(
                  children: [
                    Positioned(
                        height: 30,
                        width: 110,
                        child: Center(
                            child: Text(
                              trophy.number,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 26
                              ),
                            )
                        )
                    ),
                    Positioned(
                      top: 40,
                      width: 110,
                      height: 100,
                      child: Center(
                        child:  CachedNetworkImage(
                           imageUrl:  trophy.icon,
                            height: 100,
                            width: 110,
                            color: Colors.white
                        ),
                      ),
                    )
                  ],
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  color:Theme.of(context).accentColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

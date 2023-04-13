
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:app/config/colors.dart';
import 'package:app/model/player.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';


class PlayerDetail extends StatefulWidget {


  Player player;


  PlayerDetail({this.player});

  @override
  _PlayerDetailState createState() => _PlayerDetailState();
}

class _PlayerDetailState extends State<PlayerDetail> {


  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
            centerTitle: false,
            backgroundColor: Colors.transparent,
            iconTheme: IconThemeData(color: Theme.of(context).accentColor),
            leading: new IconButton(
              icon: new Icon(LineIcons.angleLeft),
              onPressed: () => Navigator.of(context).pop(),
            ),
            elevation: 0.0
        ),
        body: SafeArea(
          child: SlidingUpPanel(
            minHeight: 225,
            maxHeight: 370,
            color: Colors.transparent,
            panelBuilder: (ScrollController sc) => _scrollingList(sc),
            body: Stack(
                children: [
                  Positioned(
                      top: 0,
                      left: 30,
                      right: 30,
                      child:Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.player.fname.toUpperCase(),
                            style: TextStyle(
                              color: Theme.of(context).accentColor,
                              fontSize: 28,
                              fontWeight: FontWeight.w200,
                            ),
                          ),
                          Text(widget.player.lname.toUpperCase(),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).accentColor,
                                fontSize: 28
                            ),
                          )
                        ],
                      )
                  ),
                  Positioned(
                      top: 40,
                      left: 30,
                      right: 30,
                      child:Opacity(
                        opacity: 0.5,
                        child: Text(widget.player.number,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).accentColor,
                              fontSize: 250
                          ),
                        ),
                      )
                  ),
                  Positioned(
                      bottom: 250,
                      left: 30,
                      right: 30,
                      child: Hero(
                        tag: "player_"+widget.player.id.toString(),
                        child: Image.network(
                            widget.player.image,fit: BoxFit.fitHeight
                        ),
                      )
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.4),Theme.of(context).primaryColor.withOpacity(0.1), Theme.of(context).primaryColor.withOpacity(0)],
                            )
                        )
                    ),
                  ),
                ],
              ),
          ),
        ),
      );
  }

  Widget _scrollingList(ScrollController sc){
   return Container(
     height: 100,
     margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Theme.of(context).accentColor,
          boxShadow: [BoxShadow(
              color: Theme.of(context).accentColor,
              offset: Offset(0,0),
              blurRadius: 1
          )]
      ),
      child: Stack(
        children: [

          Positioned(
            left: 0,
            right: 0,
            child: Container(
              color: Colors.transparent,
              padding: EdgeInsets.only(top: 10,bottom: 20),
              child: Center(
                child: Container(
                    height: 7,
                    width: 70,
                    decoration: new BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: new BorderRadius.circular(5)
                    )
                ),
              ),
            )
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Opacity(
              opacity: 0.2,
              child: Text(widget.player.number.toUpperCase(),
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).textTheme.bodyText2.color,
                    fontSize: 150
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(30),
            child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      border: Border(
                        top: BorderSide(width: 3, color: Colors.white),
                        left: BorderSide(width:3,  color: Colors.white),
                        right: BorderSide(width: 3,  color:  Colors.white),
                        bottom: BorderSide(width: 3,  color:  Colors.white),
                      ),
                    ),
                    child:
                    ClipOval(
                      child: Container(
                        child: Image.network(
                            widget.player.country_image,fit: BoxFit.cover
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 20),
                    height: 50,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                         widget.player.fname + " "+ widget.player.lname,
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Colors.white
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Country : "+widget.player.country,
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.7)

                        ),
                        ),
                      ],
                    ),
                  ),

                ],
              ),
              Divider(
                color: Colors.white.withOpacity(0.2),
              ),
              buildSocials(),

              Container(
                margin: EdgeInsets.only(right: 5,left: 5),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 60,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Position",
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: Colors.white
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            widget.player.position,
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.7)
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 60,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Age",
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: Colors.white
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            widget.player.age,
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.7)
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 60,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Height",
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: Colors.white
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            widget.player.height,
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.7)
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 60,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Weight",
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: Colors.white
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            widget.player.weight,
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.7)
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Divider(
                color: Colors.white.withOpacity(0.2),
              ),
              Expanded(
                child: Container(
                  child: ListView.builder(
                      itemCount: widget.player.statistics.length,
                      scrollDirection: Axis.horizontal,

                      itemBuilder: (context, index) {
                        return  buildItem(widget.player.statistics[index].name,widget.player.statistics[index].value);
                      }),
                ),
              )
            ],
          ),
          )
        ],

      ),
    );
  }

  Widget buildItem(String name,String value) {
    return Container(
      margin: EdgeInsets.only(right: 5,left: 5),
      padding: EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
          border: Border(
            top: BorderSide(width: 0.5, color: Colors.white),
            left: BorderSide(width:0.5,  color: Colors.white),
            right: BorderSide(width: 0.5,  color:  Colors.white),
            bottom: BorderSide(width: 0.5,  color:  Colors.white),
          ),
          borderRadius: BorderRadius.circular(15)
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            name,
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Colors.white.withOpacity(0.8)
            ),
          ),
          SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 22,
                color: Colors.white
            ),
          ),
        ],
      ),
    );
  }


  Widget buildSocial(String type,String username) {
    IconData  iconData = LineIcons.instagram;
    switch(type){
      case "instagram":
        iconData =  LineIcons.instagram;
        break;
      case "twitter":
        iconData =  LineIcons.twitter;
        break;
      case "facebook":
        iconData =  LineIcons.facebook;

        break;
      case "website":
        iconData =  LineIcons.globe;
        break;
      case "youtube":
        iconData =  LineIcons.youtubeSquare;
        break;
    }
    return Container(
      decoration: BoxDecoration(
          border: Border(
            top: BorderSide(width: 0.5, color: Colors.white),
            left: BorderSide(width:0.5,  color: Colors.white),
            right: BorderSide(width: 0.5,  color:  Colors.white),
            bottom: BorderSide(width: 0.5,  color:  Colors.white),
          ),
          borderRadius: BorderRadius.circular(10)
      ),
      margin: EdgeInsets.only(right: 5,left: 5),
      child: Material(
        borderRadius:  BorderRadius.circular(10),
        color: Colors.transparent,
        child: InkWell(
          borderRadius:  BorderRadius.circular(10),
          onTap: (){
            _launchURL(username);
          },
          child: Container(
            height: 40,
            padding: EdgeInsets.symmetric(horizontal: 15,vertical: 5),
            child: Icon(
                  iconData,
                  color: Colors.white,
              )

          ),
        ),
      ),
    );
  }
  _launchURL(String url) async {

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  buildSocials() {
    return Visibility(
      visible: (widget.player.socials == null)? false : (widget.player.socials.length == 0)?  false: true  ,
      child: Container(
        padding: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(width: 0.2,  color:  Colors.white.withOpacity(0.3)),
          ),
        ),
        height: 50,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _buildSocialRows()
        ),
      ),
    );
  }

  _buildSocialRows() {
    List<Widget> rowsSocial = [];
    for (var social in widget.player.socials) {
      rowsSocial.add(Expanded(child: buildSocial(social.name,social.value)));
    }
    return rowsSocial;
  }


}

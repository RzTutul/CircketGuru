



import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gdpr_dialog/gdpr_dialog.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:line_icons/line_icons.dart';
import 'package:app/api/api_config.dart';
import 'package:app/provider/ads_provider.dart';

import 'package:app/provider/theme_provider.dart';
import 'package:app/screens/home/fragment/club.dart';
import 'package:app/screens/home/fragment/default.dart';
import 'package:app/screens/home/fragment/fans.dart';
import 'package:app/screens/home/fragment/matches.dart';
import 'package:app/screens/home/fragment/ranking.dart';

import 'package:app/screens/post/favorites_list.dart';
import 'package:app/screens/other/settings.dart';
import 'package:app/screens/splash/splash.dart';
import 'package:app/screens/user/login.dart';
import 'package:app/screens/user/profile.dart';
import 'package:need_resume/need_resume.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert' as convert;
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {


  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends ResumableState<Home> {


  Map  data;


  int selectedIndex = 0;
  bool openMenu = false;
  PageController controller = PageController();

  List<GButton> tabs = [];

  bool logged = false;
  String name = "Login to your account !";
  String email = "Sign up/in now for free !";
  Image image = Image.asset("assets/images/profile.jpg");



  List<Widget> fragments =[
    Default(),
    Matches(),
    Ranking(),
    Club(),
    Fans(),
  ];

  @override
  void initState() {
    // TODO: implement initState


    super.initState();
    getLogged();
    showGDPR();
  }




  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<ThemeProvider>(context);
    return
      WillPopScope(
        onWillPop: () {
          if(openMenu){
            setState(() {
              openMenu = false;
            });
            return Future.value(false);
          }else{
           return Future.value(true);
          }
        },
        child: Stack(
          children: [

            Container(
              color:  Theme.of(context).scaffoldBackgroundColor,
              child: Stack(
                children: <Widget>[
                  Positioned(
                    width: MediaQuery.of(context).size.width,
                    right: -(MediaQuery.of(context).size.width/3),
                    top: 85,
                    height: 400,
                    child:Container(
                      width: MediaQuery.of(context).size.width,
                      child:  FutureBuilder(
                        future: initAppInfos(),
                        builder: (context, snapshot) {
                          if(snapshot.hasData)
                              return Opacity(child: CachedNetworkImage(
                                height: 400,
                                imageUrl: snapshot.data,
                                errorWidget: (context, url, error) => Icon(Icons.error),
                                fit: BoxFit.fitHeight,
                              ),opacity: 0.09);
                          else
                            return Text("");
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    top: 0,
                    child: Scaffold(
                      backgroundColor: Colors.transparent,
                      bottomNavigationBar:
                      Container(
                        decoration: BoxDecoration(color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(0),
                            boxShadow: [BoxShadow(
                                color: Colors.black54.withOpacity(0.3),
                                offset: Offset(0,0),
                                blurRadius: 5
                            )]
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                          child: SafeArea(
                            child: GNav(
                                gap: 3,
                                color: Theme.of(context).textTheme.bodyText2.color,
                                activeColor:Theme.of(context).accentColor,
                                iconSize: 17,
                                textStyle: TextStyle(
                                  fontSize: 11,
                                  color:Theme.of(context).textTheme.bodyText1.color,fontWeight: FontWeight.w600
                                ),
                                tabBackgroundColor: Theme.of(context).accentColor.withOpacity(0.1),
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                                duration: Duration(milliseconds: 200),
                                tabs: [
                                  GButton(

                                    icon: LineIcons.home,
                                    text: 'Home',
                                    borderRadius: BorderRadius.circular(8),
                                    textStyle: TextStyle(
                                      color: Theme.of(context).accentColor,
                                    ),

                                  ),




                                  GButton(
                                    icon: LineIcons.calendar,
                                    text: 'Matches',
                                    textStyle: TextStyle(
                                      color: Theme.of(context).accentColor,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),



                                  GButton(
                                    icon: LineIcons.table,
                                    text: 'Ranking',
                                    borderRadius: BorderRadius.circular(8),
                                    textStyle: TextStyle(
                                      color: Theme.of(context).accentColor,
                                    ),

                                  ),
                                  GButton(
                                    icon: LineIcons.alternateShield,
                                    text: 'Team',
                                    borderRadius: BorderRadius.circular(8),
                                    textStyle: TextStyle(
                                      color: Theme.of(context).accentColor,
                                    ),

                                  ),
                                  GButton(
                                    icon: LineIcons.users,
                                    text: 'Fans',
                                    borderRadius: BorderRadius.circular(8),
                                    textStyle: TextStyle(
                                      color: Theme.of(context).accentColor,
                                    ),

                                  ),
                                ],
                                selectedIndex: selectedIndex,
                                onTabChange: (index) {

                                  setState(() {
                                    selectedIndex = index;
                                  });
                                  controller.jumpToPage(index);
                                }),
                          ),
                        ),

                      ),

                      appBar: AppBar(
                        centerTitle: false,
                        backgroundColor:  Colors.transparent,
                        elevation: 0.0,
                        bottomOpacity: 0.0,

                        title:  Row(
                          children: [
                            GestureDetector(child: Icon(Icons.sort,size: 30),onTap: (){
                              setState(() {
                                openMenu =  true;
                              });
                            },),
                            SizedBox(width: 10),
                          ],
                        ),
                        actions: <Widget>[
                         // LiveWidget(),
                          buildProfileImahe(context),
                          Stack(
                            children: [
                              Positioned(
                                  child:
                                  Center(
                                    child: GestureDetector(
                                  onTap:() {
                                    themeChange.darkTheme =!themeChange.darkTheme;
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(right: 10),
                                    height: 28,
                                    width: 55,
                                    decoration: BoxDecoration(
                                        color: Theme.of(context).textTheme.bodyText2.color,
                                        borderRadius: BorderRadius.circular(20)
                                    ),
                                    child: Stack(
                                      children: [
                                        AnimatedPositioned(
                                            duration: Duration(milliseconds: 250),
                                            left: (themeChange.darkTheme)? 1:28,
                                            top: 1,
                                            bottom: 1,
                                            child: Container(
                                              height: 26,
                                              width: 26,
                                              child: Icon(
                                                (themeChange.darkTheme)?Icons.wb_sunny:Icons.nights_stay_rounded,
                                                size: 16,
                                              ),
                                              decoration: BoxDecoration(
                                                  color:  Theme.of(context).primaryColor,
                                                  borderRadius: BorderRadius.circular(20)
                                              ),
                                            )
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                  )
                              )
                            ],
                          ),

                        ],
                      ),
                      body:PageView.builder(
                        onPageChanged: (page) {
                          setState(() {
                            selectedIndex = page;
                          });
                        },
                        controller: controller,
                        itemBuilder: (context, position) {
                          return fragments[position];
                        },
                        itemCount: 5, // Can be null
                      ),

                    ),
                  )
                ],
              ),
            ),
            AnimatedPositioned(
                top: (openMenu  ==  true)? 0 : (-(MediaQuery.of(context).size.height)),
                child: Container(
                  padding: EdgeInsets.only(left: 25,right: 25,top: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).accentColor,
                  ),
                  height: MediaQuery.of(context).size.height,
                  width:  MediaQuery.of(context).size.width,
                  child: Scaffold(
                    backgroundColor: Colors.transparent,
                    body: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          buildProfileItem(),
                          buildMenuItem( "HOME PAGE",Colors.blue,LineIcons.home,(){
                              setState(() {
                                selectedIndex =  0;
                                openMenu =  false;
                              });
                              controller.jumpToPage(selectedIndex);
                          }),
                          buildMenuItem( "FAVORITES",Colors.lime,LineIcons.heartAlt,(){
                            Route route = MaterialPageRoute(builder: (context) => FavoriteList());
                            push(context, route);
                          }),
                          buildMenuItem("MY PROFILE",Colors.green,LineIcons.user,goToProfil),
                          buildMenuItem("SETTINGS",Colors.indigoAccent,LineIcons.cog,(){
                            Route route = MaterialPageRoute(builder: (context) => Settings());
                            push(context, route);
                          }),
                          buildMenuItem("RATE APP",Colors.orangeAccent,LineIcons.starHalfAlt,rateApp),
                          buildMenuItem("LOG OUT",Colors.deepOrange,LineIcons.alternateSignOut,logout),

                          ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: Material(
                              color: Theme.of(context).backgroundColor, // button color
                              child: InkWell(
                                splashColor: Colors.transparent, //
                                onTap: (){
                                    setState(() {
                                      openMenu =  false;
                                    });
                                },
                                child: Container(
                                  height: 50,
                                  width: 50,
                                  padding: EdgeInsets.all(15),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Icon(LineIcons.angleUp,color: Theme.of(context).accentColor,size: 18),
                                    ],
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
                duration: Duration(milliseconds: 250)
            ),
          ],
        ),
      );

  }
  buildMenuItem(String title,Color color,IconData icon,Function action){
    return  ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          splashColor: Colors.transparent, //
          onTap:action,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.all(15),
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon,color: Colors.white),

              ),
              Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                    ),
                  )
              ),
              Icon(
                LineIcons.angleRight,
                size: 18,
                color: Colors.white,
              ),
              SizedBox(width: 10)
            ],
          ),
        ),
      ),
    );
  }
  logout() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.remove("ID_USER");
    prefs.remove("SALT_USER");
    prefs.remove("TOKEN_USER");
    prefs.remove("NAME_USER");
    prefs.remove("TYPE_USER");
    prefs.remove("USERNAME_USER");
    prefs.remove("IMAGE_USER");
    prefs.remove("EMAIL_USER");
    prefs.remove("DATE_USER");
    prefs.remove("GENDER_USER");
    prefs.remove("LOGGED_USER");

    Fluttertoast.showToast(
      msg: "You have logout in successfully !",
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
    setState(() {
      getLogged();
      openMenu= false;
    });
  }
  Future<String> getLogged() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();


    logged = await prefs.getBool("LOGGED_USER");

    if(logged == true) {
      image = Image.network(await prefs.getString("IMAGE_USER"));
      name = await prefs.getString("NAME_USER");
      email = await prefs.getString("EMAIL_USER");
    }else{
      logged = false;
      image = Image.asset("assets/images/profile.jpg");
    }
  }

  @override
  void onReady() {
    // Implement your code inside here
    setState(() {
      getLogged();
    });
  }

  @override
  void onResume() {
    // Implement your code inside here
    setState(() {
      getLogged();
    });

  }

  buildProfileImahe(BuildContext context) {
    return   Container(
      child: Padding(
        padding: const EdgeInsets.only(right:10.0,top: 12,bottom: 12),
        child: GestureDetector(
          onTap:goToProfil,
          child: CircleAvatar(
            radius: 18,
            child: ClipOval(
              child: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [Colors.blue, Colors.blue]
                    )
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: ClipOval(
                    child: Container(
                      child: image,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );;
  }
  goToProfil(){
    openMenu = false;
    if(logged !=  true) {
      push(context,
          PageRouteBuilder(
              pageBuilder: (BuildContext context,
                  Animation<double> animation,
                  Animation<double> secondaryAnimation) {
                return Login();
              },
              transitionsBuilder: (context, animation,
                  secondaryAnimation, child) {
                var begin = Offset(0.0, 1.0);
                var end = Offset.zero;
                var tween = Tween(begin: begin, end: end);
                var offsetAnimation = animation.drive(tween);
                return SlideTransition(
                  position: offsetAnimation,
                  child: child,
                );
              },
              transitionDuration: Duration(milliseconds: 300),
              opaque: false
          )
      );
    }else{
      Route route = MaterialPageRoute(builder: (context) => Profile());
      push(context, route);
    }

  }

  buildProfileItem() {
   return GestureDetector(
     onTap: goToProfil,
     child: Container(
          height: 100,
          margin: EdgeInsets.symmetric(vertical: 15),
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 25,
                child: ClipOval(
                  child: Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [Colors.blue, Colors.blue]
                        )
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: ClipOval(
                        child: Container(
                          child: image,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(name,
                        style: TextStyle(
                            color: Theme.of(context).textTheme.subtitle1.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 16
                        )),
                    SizedBox(height: 3),
                    Text((email != null)?email:name.toLowerCase(),
                        style: TextStyle(
                            color: Theme.of(context).textTheme.subtitle2.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 13
                        )
                    )
                  ],
                ),
              ),
              Icon(
                LineIcons.angleRight,
                size: 18,
                color:Theme.of(context).textTheme.subtitle1.color,
              ),
            ],
          ),
          decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(
                  color: Colors.black54.withOpacity(0.2),
                  offset: Offset(0,0),
                  blurRadius: 5
              )]
          ),
        ),
   );

  }
  Future onSelectNotification(String payload) async {

      Map parsed = convert.json.decode(payload);
      if(parsed["type"] == "link"){
        _launchURL(parsed["data"]);
      }else if (parsed["type"] == "post"){
        Route route = MaterialPageRoute(builder: (context) => Splash(post:parsed["data"]));
        Navigator.pushReplacement(context, route);
      }else if (parsed["type"] == "status"){
        Route route = MaterialPageRoute(builder: (context) => Splash(status:parsed["data"]));
        Navigator.pushReplacement(context, route);
      }
  }
  _launchURL(String url) async {

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  rateApp() async{
    final InAppReview inAppReview = InAppReview.instance;

    if (await inAppReview.isAvailable()) {
        inAppReview.requestReview();
    }
  }

  Future initAppInfos() async {
    var _applogo;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _applogo =  prefs.getString("app_logo");
    return _applogo;
  }

  void showGDPR() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    AdsProvider adsProvider =  AdsProvider(prefs,(Platform.isAndroid)?TargetPlatform.android:TargetPlatform.iOS);
    GdprDialog.instance
    .showDialog()
    //.showDialog(adsProvider.getAdmobPublisherId().toString(), apiConfig.api_url.replaceAll("/api/", "/privacy_policy.html"))
        .then((onValue) {});
  }
}


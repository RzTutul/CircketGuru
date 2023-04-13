import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:app/config/colors.dart';
import 'package:app/model/post.dart';
import 'package:app/screens/status/create_image.dart';
import 'package:app/screens/status/create_quote.dart';
import 'package:app/screens/status/create_video.dart';
import 'package:need_resume/need_resume.dart';
import 'package:shared_preferences/shared_preferences.dart';
class CreateWidget extends StatefulWidget {
  Post post ;
  CreateWidget({this.post});

  @override
  _CreateWidgetState createState() => _CreateWidgetState();
}

class _CreateWidgetState extends ResumableState<CreateWidget> {
  Image image = Image.asset("assets/images/profile.jpg");
  var logged = false;

  String app_name ="";

  @override
  void onResume() {
    // Implement your code inside here
    setState(() {
      getLogged();
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    getLogged();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 10,right: 10,bottom: 5),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(
              color: Colors.black54.withOpacity(0.2),
              offset: Offset(0,0),
              blurRadius: 5
          )]
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(left: 5,top: 5,right: 5),
            child: Stack(
              children: [
                Positioned(
                    child: Container(
                      height: 45,
                      width: 45,
                      padding: EdgeInsets.all(5),
                      child:
                      CircleAvatar(
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
                              padding: const EdgeInsets.all(2.0),
                              child: ClipOval(
                                child: Container(
                                  child: image,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                ),
                Positioned(
                    left: 45,
                    right: 0,
                    top: 10,
                    child: Container(
                      height: 45,
                      child:  Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Share your status with "+app_name.toLowerCase()+" fans",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyText2.color,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    )
                ),
              ],
            ),
          ),
          Divider(
            color: Colors.grey.withOpacity(0.2),
          ),
          Padding(
            padding: EdgeInsets.only(left: 10,bottom: 5,right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  flex: 2, // 20%
                  child:  ButtonTheme(
                    height: 30,
                    padding: EdgeInsets.all(5),
                    child: TextButton.icon(

                      onPressed: (){
                        Route route = MaterialPageRoute(builder: (context) => CreateImage());
                        push(context, route);
                      },
                      icon: Icon(
                        LineIcons.image,
                        color: Colors.white,
                        size: 16,
                      ),
                      label: Text(
                        "Image",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12
                        ),
                      ),

                      style: TextButton.styleFrom(
                          backgroundColor: Colors.indigo,

                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2, // 20%

                  child:  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: ButtonTheme(
                      height: 30,
                      padding: EdgeInsets.all(5),
                      child: TextButton.icon(
                        onPressed: (){
                          Route route = MaterialPageRoute(builder: (context) => CreateVideo());
                          push(context, route);
                        },
                        icon: Icon(
                          LineIcons.video,
                          color: Colors.white,
                          size: 16,
                        ),
                        label: Text(
                          "Video",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12
                          ),
                        ),

                        style: TextButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2, // 20%
                  child: ButtonTheme(
                    height: 30,
                    child: TextButton.icon(
                      onPressed: (){
                        Route route = MaterialPageRoute(builder: (context) => CreateQuote());
                        push(context, route);
                      },
                      icon: Icon(
                          LineIcons.quoteLeft,
                          color: Colors.white,
                          size: 16,
                      ),
                      label: Text(
                          "Quote",
                          style: TextStyle(
                            color: Colors.white,
                              fontSize: 12
                          ),
                      ),
                      style: TextButton.styleFrom(
                          backgroundColor:  Colors.blueAccent,
                      ),
                    ),
                  )
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Future<String> getLogged() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    logged = await prefs.getBool("LOGGED_USER");
    String _app_name = await prefs.getString("app_name");
    setState(() {
      app_name = _app_name;
    });

    if(logged == true) {
      image = Image.network(await prefs.getString("IMAGE_USER"));
    }else{
      logged = false;
      image = Image.asset("assets/images/profile.jpg");
    }
  }
}

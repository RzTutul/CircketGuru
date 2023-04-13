import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:line_icons/line_icons.dart';
import 'package:app/api/api_rest.dart';
import 'package:app/config/colors.dart';
import 'package:app/model/staff.dart';
import 'package:app/screens/user/login.dart';
import 'package:need_resume/need_resume.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert' as convert;


class CreateQuote extends StatefulWidget {
  Staff staff;


  CreateQuote({this.staff});

  @override
  _CreateQuoteState createState() => _CreateQuoteState();
}

class _CreateQuoteState extends ResumableState<CreateQuote>   with SingleTickerProviderStateMixin{

  TextEditingController  textEditingController =  new TextEditingController();
  bool submitLoading =  false;
  var logged = false;
  Image image = Image.asset("assets/images/profile.jpg");


  bool bgColorPickerVisibility = false;
  int selectedBgColor = 0;
  var colors = [
  Colors.blue,
  Colors.green,
  Colors.pink,
  Colors.amber,
  Colors.brown,
  Colors.deepPurple,
  Colors.redAccent,
  Colors.teal,
  Colors.orange,
  Colors.blueGrey,
  Colors.indigo,
  Colors.red,
  Colors.lime,
  Colors.purple,
  Colors.black,
  ];


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
    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      color: colors[selectedBgColor],
      child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            centerTitle: false,
            elevation: 0,
            backgroundColor: Colors.transparent,
            iconTheme: IconThemeData(color: Colors.white),
            leading: new IconButton(
              icon: new Icon(LineIcons.angleLeft),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
                TextButton.icon(
                  label:Text("SEND",style: TextStyle(color: Colors.white)),
                  icon: new Icon(LineIcons.check,color: Colors.white),
                    onPressed:() {
                      _submitQuote();
                    },
                )
            ],
          ),
          body: SafeArea(
            child: Stack(
              children: [
                Positioned(
                    left: 10,
                    right: 10,
                    bottom: 0,
                    top: 0,
                    child: Container(
                      child: Center(
                        child: TextField(
                          controller: textEditingController,
                          buildCounter: (context, {currentLength, isFocused, maxLength}) {},
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 35.0,
                          ),
                          maxLines: null,
                          maxLength: 200,
                          textAlign: TextAlign.center,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration.collapsed(
                            fillColor: Colors.white,
                            hintText: 'Type your status...',
                            hintStyle: TextStyle(color: Colors.white60),
                          ),
                        ),
                      ),
                    )
                ),
                Positioned(
                    bottom: 10,
                    left: 10,
                    right: 0,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        GestureDetector(
                          onTap: (){
                            setState(() {
                              bgColorPickerVisibility=!bgColorPickerVisibility;
                            });
                          },
                          child: Container(
                            height: 35,
                            width: 35,
                            child: Icon((bgColorPickerVisibility)? LineIcons.caretLeft:LineIcons.slackHashtag,color: Colors.white),
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    begin: Alignment.topRight,
                                    end: Alignment.bottomLeft,
                                    colors: [
                                      Colors.yellow,
                                      Colors.red,
                                      Colors.indigo,
                                      Colors.teal
                                    ]),
                                borderRadius: BorderRadius.circular(7),
                               border: Border.all(color: Colors.white,width: 3),

                             ),
                          ),
                        ),
                        AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          height: 35,
                          width: (bgColorPickerVisibility)?MediaQuery.of(context).size.width-60:0,
                          margin: EdgeInsets.only(left: 10),
                          child: ListView.builder(
                            primary: true,
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: colors.length,
                            itemBuilder: (context, index){
                              return
                                GestureDetector(
                                  onTap: (){
                                    setState(() {
                                      selectedBgColor = index;
                                    });
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(right: 10),
                                    height: 35,
                                    width: 35,
                                    decoration: BoxDecoration(
                                        color: colors[index],
                                        border: Border.all(color: Colors.white,width: (selectedBgColor == index)?3:0),
                                        borderRadius: BorderRadius.circular(7)
                                    ),
                                  ),
                                );
                            },
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
  Future<String>  _submitQuote() async{
    var myColor = colors[selectedBgColor];
    var hex = '#${myColor.value.toRadixString(16)}';
    var color =  hex.replaceAll("#ff", "");
    print(hex);
    if(textEditingController.text.isEmpty)
      return "";
    if(logged){

      setState(() {
        submitLoading = true;
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();

      int id_user = await prefs.getInt("ID_USER");
      String key_user = await prefs.getString("TOKEN_USER");

      String quote = textEditingController.text;
      convert.Codec<String, String> stringToBase64 = convert.utf8.fuse(convert.base64);
      String quote_base = stringToBase64.encode(quote);

      var statusCode = 200;
      var jsonData;
      var response;
      try {
        response = await http.post(apiRest.submitQuote(), body: {"key":key_user,"user":id_user.toString(),'quote': quote_base,"color":color});
        jsonData =  convert.jsonDecode(response.body);

      } catch (ex) {
        statusCode =  500;
      }
      if(statusCode == 200){
        if(jsonData["code"] == 200){
          Fluttertoast.showToast(
            msg:"Your Quote has been uploaded successfully!",
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
          Navigator.pop(context);
        }else{
          Fluttertoast.showToast(
            msg:"Operation has been cancelled !",
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      }else{
        Fluttertoast.showToast(
          msg:"Operation has been cancelled !",
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
      setState(() {
        submitLoading = false;
      });
    }else{
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
    }
  }



  Future<String> getLogged() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    logged = await prefs.getBool("LOGGED_USER");

    if(logged == true) {
      image = Image.network(await prefs.getString("IMAGE_USER"));
    }else{
      logged = false;
      image = Image.asset("assets/images/profile.jpg");
    }
  }
}

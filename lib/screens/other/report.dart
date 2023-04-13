

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import 'package:app/api/api_rest.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert' as convert;

class Report extends StatefulWidget {

  Widget image ;
  String title ;
  String message ;
  int status;


  Report({this.image, this.title,this.status,this.message});

  @override
  _ReportState createState() => _ReportState();
}

class _ReportState extends State<Report> {
  bool logged = false;

  DateTime selectedDate = DateTime.now();
  TextEditingController nameController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  TextEditingController messageController = new TextEditingController();
  bool submitLoading =  false;


  bool _nameValide = true;
  bool _messageValide = true;
  bool _emailValide = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      messageController.text = widget.message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: false,
        title: Text(widget.title),
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).textTheme.bodyText1.color),
        leading: new IconButton(
          icon: new Icon(LineIcons.angleLeft),
          onPressed: () =>  Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        width: double.infinity,
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.all(2.0),
          children: [
            SizedBox( height: 70),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Positioned(
                      child: SizedBox(
                        height: 120,
                        width: 120,
                        child: ClipOval(
                            child: widget.image
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox( height: 50),
            Container(
              height: 50,
              margin: EdgeInsets.symmetric(horizontal: 25,vertical: 7),
              padding: EdgeInsets.all(15),
              decoration:  BoxDecoration(
                  color: (_nameValide)?Theme.of(context).cardColor:Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [BoxShadow(
                      color: Colors.black54.withOpacity(0.2),
                      offset: Offset(0,0),
                      blurRadius: 5
                  )]
              ),
              child: TextField(
                controller: nameController,
                style: TextStyle(color: Theme.of(context).textTheme.bodyText1.color, fontSize: 15.0),
                decoration: InputDecoration.collapsed(
                  hintText: 'Full name',
                  hintStyle: TextStyle(color: Theme.of(context).textTheme.bodyText2.color),
                ),
              ),
            ),
            Container(
              height: 50,
              margin: EdgeInsets.symmetric(horizontal: 25,vertical: 7),
              padding: EdgeInsets.all(15),
              decoration:  BoxDecoration(
                  color: (_emailValide)?Theme.of(context).cardColor:Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [BoxShadow(
                      color: Colors.black54.withOpacity(0.2),
                      offset: Offset(0,0),
                      blurRadius: 5
                  )]
              ),
              child: TextField(
                controller: emailController,
                style: TextStyle(color: Theme.of(context).textTheme.bodyText1.color, fontSize: 15.0),
                decoration: InputDecoration.collapsed(
                  hintText: 'E-mail',
                  hintStyle: TextStyle(color: Theme.of(context).textTheme.bodyText2.color),
                ),
              ),
            ),

            Container(
              height: 120,
              margin: EdgeInsets.symmetric(horizontal: 25,vertical: 7),
              padding: EdgeInsets.all(15),
              decoration:  BoxDecoration(
                  color: (_messageValide)?Theme.of(context).cardColor:Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(
                      color: Colors.black54.withOpacity(0.2),
                      offset: Offset(0,0),
                      blurRadius: 5
                  )]
              ),
              child: Row(
                children: [
                  Flexible(
                    child: TextField(
                      minLines: 5,
                      maxLines: 6,
                      controller: messageController,
                      style: TextStyle(color: Theme.of(context).textTheme.bodyText1.color, fontSize: 15.0),
                      decoration: InputDecoration.collapsed(
                          hintText: 'Your message',
                        hintStyle: TextStyle(color: Theme.of(context).textTheme.bodyText2.color),
                      ),
                    ),
                  ),
                ],
              ),
            ),


            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25,vertical: 7),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Material(
                  color: Theme.of(context).accentColor, // button color
                  child: InkWell(
                    splashColor: Colors.white, //
                    onTap: (){
                        sendMessaege();
                    },
                    child: Container(
                      height: 50,
                      padding: EdgeInsets.all(15),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(LineIcons.paperPlaneAlt,color: Colors.white,size: 18),
                          SizedBox(width: 5),
                          Text(
                            'SEND MESSAGE',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 13
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void sendMessaege() async{
    if(nameController.text.length<4){
      setState(() {
        _nameValide = false;

      });
      return null;
    }else{
      setState(() {
        _nameValide = true;
      });
    }
    if(emailController.text.length<4){
      setState(() {
        _emailValide = false;
      });
      return null;
    }else{
      setState(() {
        _emailValide = true;
      });
    }
    if(isEmail(emailController.text) != true){
      setState(() {
        _emailValide = false;
      });
      return null;
    }else{
      setState(() {
        _emailValide = true;
      });
    }
    if(messageController.text.length<4){
      setState(() {
        _messageValide = false;

      });
      return null;
    }else{
      setState(() {
        _messageValide = true;
      });
    }


      setState(() {
        submitLoading = true;
      });

      String name = nameController.text;
      String message = messageController.text;
      String email = emailController.text;

      var statusCode = 200;
      try {

        var request = new http.MultipartRequest("POST", apiRest.sendMessage());


        request.fields['name'] = name;
        request.fields['email'] = email;
        request.fields['message'] = message;
        request.fields['status'] = widget.status.toString();


        var response = await request.send();
        final respStr = await response.stream.bytesToString();
        var jsonData =  convert.jsonDecode(respStr);
        print(jsonData);
        statusCode =  response.statusCode;

      } catch (ex) {
        statusCode =  500;
      }
      if(statusCode == 200){
        Fluttertoast.showToast(
          msg:"Your message has been sent successfully!",
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
      setState(() {
        submitLoading = false;
      });


  }
  isEmail(String text) {
    bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(text);
    return emailValid;
  }

}

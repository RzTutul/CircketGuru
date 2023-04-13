import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_icons/line_icons.dart';
import 'package:app/api/api_rest.dart';
import 'package:app/config/colors.dart';
import 'package:app/model/staff.dart';
import 'package:app/screens/user/login.dart';
import 'package:need_resume/need_resume.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert' as convert;

class CreateImage extends StatefulWidget {
  Staff staff;


  CreateImage({this.staff});

  @override
  _CreateImageState createState() => _CreateImageState();
}

class _CreateImageState extends ResumableState<CreateImage> {

  File _image;
  ImagePicker picker = ImagePicker();


  TextEditingController  textEditingController =  new TextEditingController();
  bool submitLoading =  false;
  var logged = false;
  Image image = Image.asset("assets/images/profile.jpg");


  _pickImageFromGallery() async {
    ImagePicker imagePicker = ImagePicker();
    XFile ximage = await imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 100);
    File image = new File(ximage.path);
    setState(() {
      _image = image;
    });
  }

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
    return Scaffold(

      body: SafeArea(
          child:Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.only(left: 15,right: 15,top: 60,bottom: 20),
                child:Row(
                  children: [
                    IconButton(
                      icon: new Icon(Icons.arrow_back_ios, color: Theme.of(context).textTheme.bodyText1.color),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Text(
                      "Create Image",
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyText1.color,
                          fontWeight: FontWeight.w600,
                          fontSize: 24
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: Container(
                  height: 50,
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Center(
                    child: TextField(
                      enabled: !submitLoading,
                      controller: textEditingController,
                      cursorColor: Colors.white,
                      style: TextStyle(color: Colors.white, fontSize: 15.0),
                      decoration: InputDecoration.collapsed(
                        hintText: 'Write a Image description ... ',
                        hintStyle: TextStyle(color: Colors.white60),
                      ),
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).accentColor,
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
              Expanded(
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 50,
                        top: 0,
                        child:
                        (_image != null)?
                        Stack(
                          children: [
                            Positioned(
                              top:0,
                              bottom: 0,
                              right: 0,
                              left: 0,
                              child: Container(
                                  margin: EdgeInsets.all(10),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.file(_image,fit: BoxFit.cover)
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber,
                                    borderRadius: BorderRadius.circular(20),
                                  )
                              ),
                            ),
                            Positioned(
                              right: 20,
                              top: 20,
                              child: Visibility(
                                visible: !submitLoading,
                                child: Container(
                                    child: ClipOval(
                                      child: Material(
                                        color: Colors.amber, // button color
                                        child: InkWell(
                                          splashColor: Colors.white, // inkwell color
                                          child: SizedBox(width: 50, height: 50, child: Icon(LineIcons.windowClose,color: Colors.white)),
                                          onTap: () {
                                            setState(() {
                                              _image =  null;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                    decoration:  BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        boxShadow: [BoxShadow(
                                            color: Colors.amber,
                                            offset: Offset(0,0),
                                            blurRadius: 50
                                        )]
                                    )
                                ),
                              ),
                            ),
                          ],
                        )
                            :
                        Container(
                          margin: EdgeInsets.all(10),
                          padding: EdgeInsets.all(50),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                "Click button bellow to select image ...",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black
                                ),
                              ),
                              SizedBox(height: 20),
                              Icon(LineIcons.angleDown,color: Colors.black)
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 15,
                        child: Center(
                          child: Container(
                              child:
                              (_image == null)?

                              ClipOval(
                                child: Material(
                                    color: Theme.of(context).accentColor, // button color
                                    child:
                                    InkWell(
                                      splashColor: Colors.white, // inkwell color
                                      child: SizedBox(width: 70, height: 70, child: Icon(LineIcons.image,color: Colors.white)),
                                      onTap: () {
                                        _pickImageFromGallery();
                                      },
                                    )
                                ),
                              ):
                              (submitLoading)?
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child: SizedBox( height: 60,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              height: 60,
                                              width: 60,
                                              padding: EdgeInsets.all(10),
                                              child: CircularProgressIndicator(
                                                backgroundColor: Colors.white,
                                              ),
                                            ),
                                            SizedBox(width: 15),
                                            Text(
                                              "Uploading ...",
                                              style: TextStyle(
                                                  color: Colors.white
                                              ),
                                            ),
                                            SizedBox(width: 20),
                                          ],
                                        )
                                    ),
                                  )
                                      :
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child: Material(
                                        color: Theme.of(context).accentColor, // button color
                                        child: InkWell(
                                          splashColor: Colors.white, // inkwell color
                                          child:
                                          SizedBox( height: 60,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  SizedBox(width: 15),
                                                  Icon(LineIcons.upload,color: Colors.white),
                                                  SizedBox(width: 15),
                                                  Text(
                                                    "UPLOAD IMAGE",
                                                    style: TextStyle(
                                                        color: Colors.white
                                                    ),
                                                  ),
                                                  SizedBox(width: 15),
                                                ],
                                              )
                                          ),
                                          onTap: _submitImage,
                                        )
                                    ),
                                  )
                              ,
                              decoration:  BoxDecoration(
                                  color: Theme.of(context).accentColor,
                                  borderRadius: BorderRadius.circular(50),
                                  boxShadow: [BoxShadow(
                                      color: Theme.of(context).accentColor,
                                      offset: Offset(0,0),
                                      blurRadius: 50
                                  )]
                              )
                          ),
                        ),
                      )
                    ],
                  )
              )
            ],
          )
      ),
    );
  }

  Future<String>  _submitImage() async{
    if(logged){

      setState(() {
        submitLoading = true;
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();

      int id_user = await prefs.getInt("ID_USER");
      String key_user = await prefs.getString("TOKEN_USER");


      String description = textEditingController.text;

      var statusCode = 200;
      try {

        var request = new http.MultipartRequest("POST", apiRest.submitImage());
        print("apcall");

        request.fields['key'] = key_user;
        request.fields['user'] = id_user.toString();
        request.fields['description'] = description;

        print("apcall");
        print(request.toString());

        http.MultipartFile multipartFile = await http.MultipartFile.fromPath(
            'uploaded_file', _image.path);


        request.files.add(multipartFile);
       var response = await request.send();
        statusCode =  response.statusCode;
        print("apcall");
        print(response.toString());
        print(response.statusCode);

      } catch (ex) {
        print(ex.toString());
        statusCode =  500;
      }
      if(statusCode == 200){
        Fluttertoast.showToast(
          msg:"Your Image has been uploaded successfully!",
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

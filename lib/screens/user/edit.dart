

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

class Edit extends StatefulWidget {
  @override
  _EditState createState() => _EditState();
}

class _EditState extends State<Edit> {
  File _image;
  bool logged = false;
  Image image = Image.asset("assets/images/profile.jpg",fit: BoxFit.cover);
  DateTime selectedDate = DateTime.now();
  TextEditingController nameController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  TextEditingController dateController = new TextEditingController();
  bool submitLoading =  false;

  String selected_gender = "Gender";
  static const _genders = [
    'Female',
    'Male'
  ];

  bool _nameValide = true;
  bool _dateValide = true;
  bool _emailValide = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLogged();
  }
  _pickImageFromGallery() async {
    ImagePicker imagePicker = new ImagePicker();
    XFile ximage = await imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 100);
    File image = File(ximage.path);
    setState(() {
      _image = image;
      this.image = Image.file(_image,fit: BoxFit.cover);

    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: false,
        title: Text(""),
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).textTheme.bodyText1.color),
        leading: new IconButton(
          icon: new Icon(LineIcons.alignLeft),
          onPressed: () =>  Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        width: double.infinity,
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.all(2.0),
          children: [
            SizedBox( height: 100),
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
                            child: image
                        ),
                      ),
                    ),
                    Positioned(
                        bottom: 0,
                        right: 0,
                        child:Container(
                          height: 30,
                          width: 30,
                          decoration: ShapeDecoration(
                            color: Colors.green,
                            shape: CircleBorder(),
                          ),
                          child: IconButton(
                            iconSize: 15,
                            icon: Icon(LineIcons.image),
                            color: Colors.white,
                            onPressed: () {
                              _pickImageFromGallery();
                            },
                          ),
                        )
                    )
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
              height: 50,
              margin: EdgeInsets.symmetric(horizontal: 25,vertical: 7),
              padding: EdgeInsets.all(15),
              decoration:  BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [BoxShadow(
                      color: Colors.black54.withOpacity(0.2),
                      offset: Offset(0,0),
                      blurRadius: 5
                  )]
              ),
              child: DropdownButton(
                  isExpanded: true,

                  items: _genders.map((item) {
                    return DropdownMenuItem(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                  hint: Text(
                    selected_gender,
                    style: TextStyle(
                        color: Theme.of(context).textTheme.subtitle1.color
                    ),
                  ),
                  underline: SizedBox(),
                  onChanged: (selectedItem) => setState((){
                    selected_gender = selectedItem;
                  },
                  )),
            ),
            GestureDetector(
              onTap: (){
                _selectDate(context);
              },
              child: Container(
                height: 50,
                margin: EdgeInsets.symmetric(horizontal: 25,vertical: 7),
                padding: EdgeInsets.all(15),
                decoration:  BoxDecoration(
                    color: (_dateValide)?Theme.of(context).cardColor:Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(50),
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
                        controller: dateController,
                        enabled: false,
                        style: TextStyle(color: Theme.of(context).textTheme.bodyText1.color, fontSize: 15.0),
                        decoration: InputDecoration.collapsed(
                          hintText: 'Date of birth',
                          hintStyle: TextStyle(color: Theme.of(context).textTheme.bodyText2.color),
                        ),
                      ),
                    ),
                    Icon(LineIcons.calendar)
                  ],
                ),
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
                      _editProfile();
                    },
                    child: Container(
                      height: 50,
                      padding: EdgeInsets.all(15),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(LineIcons.save,color: Colors.white,size: 18),
                          SizedBox(width: 5),
                          Text(
                            'SAVE',
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
  _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate, // Refer step 1
      firstDate: DateTime(1900),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        dateController.text = selectedDate.year.toString() +"-" + selectedDate.month.toString() + "-" + selectedDate.day.toString()  ;
      });
  }
  Future<String> getLogged() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    logged = await prefs.getBool("LOGGED_USER");

    if(logged == true) {

      image = Image.network(await prefs.getString("IMAGE_USER"));
      nameController.text = await prefs.getString("NAME_USER");
      emailController.text = await prefs.getString("EMAIL_USER");
      String gender = await prefs.getString("GENDER_USER");
      selected_gender = (gender== "" || gender == null)? "Gender":gender;

      String date = await prefs.getString("DATE_USER");
      date =  (date== "" || date == null)? "1901-01-01":date;
      dateController.text  =  date;
      final f = new DateFormat('yyyy-mm-dd');

      selectedDate =   f.parse(date);

      setState(() {

      });
    }else{
      logged = false;
      image = Image.asset("assets/images/profile.jpg",fit: BoxFit.cover);
    }
  }

  Future<String>  _editProfile() async{
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

    if(dateController.text.length<4){
      setState(() {
        _dateValide = false;

      });
      return null;
    }else{
      setState(() {
        _dateValide = true;

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
    if(logged){
      setState(() {
        submitLoading = true;
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();

      int id_user = await prefs.getInt("ID_USER");
      String key_user = await prefs.getString("TOKEN_USER");

      String name = nameController.text;
      String date = dateController.text;
      String gender = selected_gender;
      String email = emailController.text;
      var map = new Map<String, dynamic>();

      var statusCode = 200;
      try {

        var request = new http.MultipartRequest("POST", apiRest.editProfile());

        request.fields['key'] = key_user;
        request.fields['user'] = id_user.toString();
        request.fields['name'] = name;
        request.fields['date'] = date;
        request.fields['gender'] = gender;
        request.fields['email'] = email;
        if(_image != null) {
          http.MultipartFile multipartFile = await http.MultipartFile.fromPath(
              'uploaded_file', _image.path);
          request.files.add(multipartFile);
        }
        var response = await request.send();
        final respStr = await response.stream.bytesToString();
        var jsonData =  convert.jsonDecode(respStr);

        String name_user="x";
        String email_user="";
        String gender_user="Gender";
        String date_user="0000/00/00";
        String image_user="x";

        for(Map i in jsonData["values"]){
          if(i["name"] == "name") {
            name_user = i["value"];
          }

          if(i["name"] == "email") {
            email_user =  i["value"];
          }
          if(i["name"] == "url") {
            image_user  = i["value"] ;
          }
          if(i["name"] == "date") {
            date_user = i["value"];
          }
          if(i["name"] == "gender") {
            gender_user = i["value"];
          }
        }


          SharedPreferences prefs = await SharedPreferences.getInstance();

          prefs.setString("NAME_USER", name_user);
          if(image_user != "x")
            prefs.setString("IMAGE_USER", image_user);
          prefs.setString("EMAIL_USER", email_user);
          prefs.setString("DATE_USER", date_user);
          prefs.setString("GENDER_USER", gender_user);


        statusCode =  response.statusCode;

      } catch (ex) {
        statusCode =  500;

      }
      if(statusCode == 200){
        Fluttertoast.showToast(
          msg:"Your profile has been updated successfully!",
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        SharedPreferences prefs = await SharedPreferences.getInstance();


        prefs.setString("NAME_USER", name);
        prefs.setString("EMAIL_USER", email);
        prefs.setString("DATE_USER", date);
        prefs.setString("GENDER_USER", gender);
        setState(() {

        });
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
      Fluttertoast.showToast(
        msg:"Operation has been cancelled !",
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  isEmail(String text) {
    bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(text);
    return emailValid;
  }
}

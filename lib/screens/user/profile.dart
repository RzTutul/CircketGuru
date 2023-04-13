import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import 'package:app/screens/user/edit.dart';
import 'package:need_resume/need_resume.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends ResumableState<Profile> {

  bool logged = false;
  Image image = Image.asset("assets/images/profile.jpg");
  DateTime selectedDate = DateTime.now();
  TextEditingController nameController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  TextEditingController dateController = new TextEditingController();
  TextEditingController genderController = new TextEditingController();
  String selected_gender = "Gender";
  static const _genders = [
    'Female',
    'Male'
  ];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLogged();
  }
  @override
  void onResume() {
    // Implement your code inside here
    getLogged();
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
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [BoxShadow(
                      color: Colors.black54.withOpacity(0.2),
                      offset: Offset(0,0),
                      blurRadius: 5
                  )]
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: TextField(
                      enabled: false,
                      controller: nameController,
                      style: TextStyle(color: Theme.of(context).textTheme.bodyText1.color, fontSize: 15.0),
                      decoration: InputDecoration.collapsed(
                        hintText: 'Full name',
                        hintStyle: TextStyle(color: Theme.of(context).textTheme.bodyText2.color),
                      ),
                    ),
                  ),
                  Text("Full name",
                    style: TextStyle(
                        fontSize: 11
                    ),
                  )

                ],
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,

                children: [
                  Flexible(
                    child: TextField(
                      enabled: false,
                      controller: emailController,
                      style: TextStyle(color: Theme.of(context).textTheme.bodyText1.color, fontSize: 15.0),
                      decoration: InputDecoration.collapsed(
                        hintText: 'E-mail',
                        hintStyle: TextStyle(color: Theme.of(context).textTheme.bodyText2.color),
                      ),
                    ),
                  ),
                  Text("E-mail",
                    style: TextStyle(
                        fontSize: 11
                    ),)
                ],
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: TextField(
                      controller: genderController,
                      enabled: false,
                      style: TextStyle(color: Theme.of(context).textTheme.bodyText1.color, fontSize: 15.0),
                      decoration: InputDecoration.collapsed(
                        hintText: 'Gender',
                        hintStyle: TextStyle(color: Theme.of(context).textTheme.bodyText2.color),
                      ),
                    ),
                  ),
                  Text("Gender",
                    style: TextStyle(
                      fontSize: 11
                    ),
                  )
                ],
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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25,vertical: 7),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Material(
                  color: Theme.of(context).accentColor, // button color
                  child: InkWell(
                    splashColor: Colors.white, //
                    onTap: (){
                      Route route = MaterialPageRoute(builder: (context) => Edit());
                      push(context, route);
                    },
                    child: Container(
                      height: 50,
                      padding: EdgeInsets.all(15),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(LineIcons.edit,color: Colors.white,size: 18),
                          SizedBox(width: 5),
                          Text(
                              'Edit profile',
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
      final f = new DateFormat('yyyy-mm-dd');

      dateController.text  =  date;
      selectedDate =   f.parse(date);
      genderController.text = selected_gender;
      setState(() {

      });
    }else{
      logged = false;
      image = Image.asset("assets/images/profile.jpg");
    }
  }
}

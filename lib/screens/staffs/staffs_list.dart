
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:line_icons/line_icons.dart';
import 'package:app/api/api_rest.dart';
import 'package:app/config/colors.dart';
import 'package:app/model/staff.dart';
import 'package:app/model/team.dart';
import 'package:app/screens/loading.dart';
import 'package:app/screens/staffs/staff_widget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class StaffsList extends StatefulWidget {

  Team team;

  StaffsList({this.team});

  @override
  _StaffsListState createState() => _StaffsListState();
}

class _StaffsListState extends State<StaffsList> {
  List<Staff> staffsList = [];
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  bool loading =  false;
  String state =  "progress";
  bool buttonLoading =  false;
  bool refreshing =  true;

  @override
  void initState() {
    // TODO: implement initState
    _getList();
    super.initState();

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
          centerTitle: false,
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: Theme.of(context).textTheme.bodyText1.color),
          leading: new IconButton(
            icon: new Icon(LineIcons.angleLeft),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(widget.team.title,style: TextStyle(color: Theme.of(context).textTheme.bodyText1.color)),
          elevation: 0.0
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
                left: 5,
                right: 5,
                bottom: 0,
                top: 0,
                child:  buildHome()
            ),
            Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Visibility(
                    visible: buttonLoading ,
                    child:
                    Center(
                      child:
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color:Theme.of(context).primaryColor,
                            boxShadow: [BoxShadow(
                                color: Theme.of(context).primaryColor,
                                offset: Offset(0,0),
                                blurRadius: 10
                            )]
                        ),
                        height: 40,
                        width: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    )
                )
            )
          ],
        ),
      ),
    );
  }

  Future<List<Staff>>  _getList() async{
    if(loading)
      return null;
    staffsList.clear();
    loading =  true;

    if(refreshing == false){
      setState(() {
        state =  "progress";
      });
      refreshing = true;
    }

    var response;
    try {
      response = await http.get(apiRest.getStaffsByTeam(widget.team.id));
    } catch (ex) {
      loading = false;
      setState(() {
        state =  "error";
      });
    }
    if(!loading)
      return null;

    if (response.statusCode == 200) {
      var data  = await http.get(apiRest.getStaffsByTeam(widget.team.id));
      var jsonData =  convert.jsonDecode(data.body);
      for(Map i in jsonData){
        Staff position = Staff.fromJson(i);
        staffsList.add(position);
      }
      setState(() {
        state =  "success";
      });
    } else {
      setState(() {
        state =  "error";
      });
    }
    loading = false;
    return staffsList;
  }




  Widget buildHome() {
    switch(state){
      case "success":
        return RefreshIndicator(
          backgroundColor: Theme.of(context).primaryColor,
          key: refreshKey,
          onRefresh:_getList,
          child: GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            children: List.generate(staffsList.length, (index) => StaffWidget(staff: staffsList[index])),
          ),
        );
        break;
      case "progress":
        return LoadingWidget();
      break;
      case "error":
        return Center(
          child: TextButton(
            onPressed: (){
              print("try again");
            },
            child: Text("TryAgain"),
          ) ,
        );
        break;
    }
  }
}




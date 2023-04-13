import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:line_icons/line_icons.dart';
import 'package:app/api/api_rest.dart';
import 'package:app/config/colors.dart';
import 'package:app/model/answer.dart';
import 'package:app/model/question.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;


class SondageWidget extends StatefulWidget {

  Question question;
  SondageWidget({this.question});

  @override
  _SondageWidgetState createState() => _SondageWidgetState();
}

class _SondageWidgetState extends State<SondageWidget> {
  List answers = [];
  List answers_id =[];

  bool isChecked(int index)  {
    bool exist =  false;
    for(int i in answers){
      if(i == index){
          exist =  true;
      }
    }
    return exist;
  }

  setAnswer(index){
    setState(() {
        if(widget.question.multi){
          if(isChecked(index)){
            answers.remove(index);
            widget.question.answers[index].votes-=1;
          }else{
            answers.add(index);
            widget.question.answers[index].votes+=1;

          }
        }else{
          for(int answerIndex in answers){
            int IndexCurrent  =0;
            for(Answer answer in widget.question.answers ){
              if(IndexCurrent == answerIndex){
                widget.question.answers[index].votes-=1;
              }
              IndexCurrent++;
            }
          }
          answers.clear();
          answers.add(index);
          widget.question.answers[index].votes = (widget.question.answers[index].votes + 1);
        }

    });
  }
  sendAnswers(){

    if(answers.isEmpty){
      Fluttertoast.showToast(
        msg:"Please select an answer before submit !",
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    setState(() {
      widget.question.open = false;
      _saveSondage(widget.question.id);
    });
    String answers_string= "";
    for(int i in answers){
      int IndexCurrent  =0;
      for(Answer answer in widget.question.answers ){
        if(i == IndexCurrent){
          answers_string=answers_string+"_"+widget.question.answers[IndexCurrent].id.toString();
        }
        IndexCurrent++;
      }
    }
    _submitAnswer(answers_string);
  }
  Future<String>  _submitAnswer(String answers_string) async{


    var statusCode = 200;
    var response;
    print(apiRest.submitAnswer());
    try {
      response = await http.post(apiRest.submitAnswer(), body: {'question': widget.question.id.toString(),'choices': answers_string});
    } catch (ex) {
      statusCode =  500;
    }
    if(statusCode == 200){
      var jsonData =  convert.jsonDecode(response.body);
      if(jsonData["code"] == 200){
        Fluttertoast.showToast(
          msg:"Your Answer has been counted successfully!",
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      }else{
        Fluttertoast.showToast(
          msg: "Operation has been cancelled !",
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }else{
      Fluttertoast.showToast(
        msg: "Operation has been cancelled !",
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }


  }
  _saveSondage(int id ) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>  votedQuestions=  await prefs.getStringList('voted_question');
    if(votedQuestions==null){
      votedQuestions=  [];
    }
    bool exist = false;
    for(String questionId in votedQuestions){
      if(int.parse(questionId) == id){
        exist = true;
      }
    }
    if(!exist){
      votedQuestions.add(id.toString());
      prefs.setStringList("voted_question", votedQuestions);
    }


  }


  @override
  Widget build(BuildContext context) {
    return  Container(
      margin: EdgeInsets.only(left: 10,right: 10,bottom: 10,top: 5),
      width: MediaQuery.of(context).size.width,
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
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(left:10,right: 10,top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                      color: Theme.of(context).accentColor,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [BoxShadow(
                          color: Theme.of(context).accentColor,
                          offset: Offset(0,0),
                          blurRadius: 1
                      )]
                  ),
                  child: Icon(LineIcons.question,color: Colors.white),
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.question.question,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyText1.color,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            color: Colors.grey.withOpacity(0.2),
          ),
          Visibility(
            visible: (widget.question.open),
            child: ListView.builder(
              primary: false,
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: widget.question.answers.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: (){
                    setAnswer(index);
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: 10,right: 10,top: 5,bottom:5 ),
                    padding: EdgeInsets.only(left: 15,top: 5,right: 5,bottom: 5),
                    decoration: BoxDecoration(
                        color: Theme.of(context).textTheme.subtitle1.color,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [BoxShadow(
                            color: Colors.black45,
                            offset: Offset(0,0),
                            blurRadius: 1
                        )]
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            widget.question.answers[index].answer.toString(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5
                            ),
                          ),
                        ),
                        Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.check, color: (isChecked(index))? Theme.of(context).primaryColor : Colors.transparent),
                        ),

                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Visibility(
            visible: !(widget.question.open),
            child: ListView.builder(
              primary: false,
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: widget.question.answers.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  margin: EdgeInsets.only(left: 10,right: 10,top: 5,bottom:5 ),
                  decoration: BoxDecoration(
                      color: Theme.of(context).textTheme.subtitle1.color,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [BoxShadow(
                          color: Colors.black45,
                          offset: Offset(0,0),
                          blurRadius: 1
                      )]
                  ),
                  child: Stack(
                    children: [
                    Container(
                      height: 50,
                      width: (MediaQuery.of(context).size.width - 40 ) * ((widget.question.answers[index].votes == 0 || widget.question.getVotes() == 0)? 0 : (widget.question.answers[index].votes / widget.question.getVotes()) ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10),topLeft: Radius.circular(10)),
                      )
                    ),
                      Container(
                        padding: EdgeInsets.only(left: 15,top: 5,right: 5,bottom: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Flexible(
                              child: Text(
                                widget.question.answers[index].answer.toString(),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.5
                                ),
                              ),
                            ),
                            Container(
                              height: 40,
                              width: 50,
                              decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  (( ((widget.question.answers[index].votes == 0 || widget.question.getVotes() == 0)? 0 :(widget.question.answers[index].votes / widget.question.getVotes())) *1000).floor()/10).toString()+"%",
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11
                                    ),
                                ),
                              )
                            )

                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 10),
          Visibility(
            visible: (widget.question.open) ,
            child: Container(
              height: 50,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).accentColor,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10),bottomRight: Radius.circular(10)),
                boxShadow: [BoxShadow(
                  color: Theme.of(context).accentColor,
                  offset: Offset(0,0),
                  blurRadius: 1
                )]
              ),
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                ),
                onPressed: (){
                  sendAnswers();
                },
                icon:Icon( Icons.check ,color: Colors.white),
                label: Text(
                    "Submit Answer".toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                    ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

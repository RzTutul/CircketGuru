
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:app/config/colors.dart';
import 'package:app/model/competition.dart';

class CompetitionsWidget extends StatefulWidget {

  List<Competition> competitions;
  Function action;


  CompetitionsWidget({this.competitions, this.action});

  @override
  _CompetitionsWidgetState createState() => _CompetitionsWidgetState();
}

class _CompetitionsWidgetState extends State<CompetitionsWidget> {


  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      child: ListView.builder(
          itemCount: widget.competitions.length ,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, int index) {
            return buildCompetition(index );
          }
      ),
    );
  }

  Widget buildCompetition(int index) {
    return GestureDetector(
      onTap: () {
        widget.action(widget.competitions[index]);
      },
      child: Container(
        margin: EdgeInsets.only(left: 10, right: 5, top: 10, bottom: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(
                color: Colors.black54.withOpacity(0.3),
                offset: Offset(0,0),
                blurRadius: 5
            )]
        ),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 500),
          curve: Curves.linearToEaseOut,
          decoration: BoxDecoration(
            color: (widget.competitions[index].selected == true)? Theme.of(context).accentColor :Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
            child: Row(
              children: [
                (widget.competitions[index].id  == 0)?
                Icon(LineIcons.trophy,color: (widget.competitions[index].selected == true)
                    ? Colors.white
                    : Theme.of(context).textTheme.bodyText2.color
                )
                    :
                Image.network(widget.competitions[index].image,color: (widget.competitions[index].selected == true)
                    ? Colors.white
                    : Theme.of(context).textTheme.bodyText2.color
                ),
                SizedBox(width: 5),
                Text(
                  (widget.competitions[index].id  == 0)?
                  "All competitions"
                      :
                  widget.competitions[index].name
                  ,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: (widget.competitions[index].selected == true)
                          ? Colors.white
                          : Theme.of(context).textTheme.bodyText2.color
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
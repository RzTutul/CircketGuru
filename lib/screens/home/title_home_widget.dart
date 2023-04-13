import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:app/config/colors.dart';

class TitleHomeWidget extends StatelessWidget {
  var title;

  TitleHomeWidget({this.title});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      child:Text(
        this.title,
        style: TextStyle(
            color: Theme.of(context).textTheme.bodyText1.color,
            fontWeight: FontWeight.w700,
            fontSize: 24
        ),
      ),
    );
  }
}

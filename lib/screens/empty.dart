import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

Widget EmptyWidget(var context) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(LineIcons.list,color: Theme.of(context).textTheme.subtitle1.color,size: 100)
      ],
    ),
  );
}
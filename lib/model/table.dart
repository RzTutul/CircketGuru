import 'dart:convert';

import 'package:app/model/header.dart';
import 'package:app/model/line.dart';

class Table {
  final int id;
  final String title;
  int columns;
  final List<Line> lines;
  final Header header;

  Table({this.id, this.title, this.columns,this.lines,this.header});

  factory Table.fromJson(Map<String, dynamic> parsedJson){

    List<Line> linesList = [] ;
    var data = parsedJson['lines'];
    for(Map i in data){
      linesList.add(Line.fromJson(i));
    }
    Header _header = Header.fromJson(parsedJson['header']);
    return Table(
        id: parsedJson['id'],
        title : parsedJson['title'],
        columns : parsedJson ['columns'],
        lines : linesList,
        header : _header,
    );
  }
}

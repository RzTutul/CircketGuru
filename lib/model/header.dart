import 'dart:convert';

class Header {
  final int id;
  final String prefix;
  final String label;
  final String row1;
  final String row2;
  final String row3;
  final String row4;
  final String row5;
  final String row6;
  final String row7;
  final String row8;


  Header({this.id, this.prefix, this.label, this.row1, this.row2,
    this.row3, this.row4, this.row5, this.row6, this.row7, this.row8});

  factory Header.fromJson(Map<String, dynamic> parsedJson){


    return Header(
      id: parsedJson['id'],
      prefix: parsedJson['prefix'],
      label: parsedJson['label'],
      row1: parsedJson['row1'],
      row2: parsedJson['row2'],
      row3: parsedJson['row3'],
      row4: parsedJson['row4'],
      row5: parsedJson['row5'],
      row6: parsedJson['row6'],
      row7: parsedJson['row7'],
      row8: parsedJson['row8'],

    );
  }




}

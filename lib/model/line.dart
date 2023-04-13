import 'dart:convert';

class Line {
  final int id;
  final String color;
  final String prefix;
  final String label;
  final String image;
  final String row1;
  final String row2;
  final String row3;
  final String row4;
  final String row5;
  final String row6;
  final String row7;
  final String row8;


  Line({this.id, this.prefix, this.label, this.image, this.row1, this.row2,
      this.row3, this.row4, this.row5, this.row6, this.row7, this.row8,this.color});

  factory Line.fromJson(Map<String, dynamic> parsedJson){


    return Line(
      id: parsedJson['id'],
      prefix: parsedJson['prefix'],
      color: parsedJson['color'],
      label: parsedJson['label'],
      image: parsedJson['image'],
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

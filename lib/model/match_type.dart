import 'package:app/model/table.dart';

class MatchTypeData {
  final int id;
  final String name;
  final String image;
  bool selected = false;


  MatchTypeData( {this.id, this.name, this.image,this.selected = false});

  factory MatchTypeData.fromJson(Map<String, dynamic> parsedJson){

    return MatchTypeData(
        id: parsedJson['id'],
        name : parsedJson['name'],
        image : parsedJson['image'],
    );
  }
}

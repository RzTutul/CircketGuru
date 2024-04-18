import 'package:app/model/table.dart';

class MatchTypeData {
  final int id;
  final String name;
  final String value;
  final String image;
  bool selected = false;


  MatchTypeData( {this.id, this.name, this.value,this.image,this.selected = false});

  factory MatchTypeData.fromJson(Map<String, dynamic> parsedJson){

    return MatchTypeData(
        id: parsedJson['id'],
        name : parsedJson['name'],
        value : parsedJson['value'],
        image : parsedJson['image'],
    );
  }
}

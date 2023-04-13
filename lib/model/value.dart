
import 'package:app/model/player.dart';

class Value {
  final int id;
  final String name;
  final String value;

  Value( {this.id, this.name,this.value});

  factory Value.fromJson(Map<String, dynamic> parsedJson){

    return Value(
        id: parsedJson['id'],
        name : parsedJson['name'],
        value : parsedJson['value']
    );
  }
}

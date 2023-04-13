
import 'package:app/model/value.dart';

class Player {
  final int id;
  final String fname;
  final String lname;
  final String image;
  final String number;

  final String position;

  final String age;

  final String height;

  final String weight;

  final String country;
  final String country_image;

  final List<Value> socials ;
  final List<Value> statistics;




  Player( {this.id, this.fname,this.lname, this.image,this.number,this.position, this.age, this.height, this.weight, this.country, this.country_image, this.socials, this.statistics});

  factory Player.fromJson(Map<String, dynamic> parsedJson){
     List<Value> _socials = [];
     List<Value> _statistics =  [];
    if(parsedJson['socials'] !=null)
    for(Map i in parsedJson['socials']){
      Value value = Value.fromJson(i);

      _socials.add(value);
    }

    if(parsedJson['statistics'] !=null)
    for(Map i in parsedJson ['statistics']){
      Value value = Value.fromJson(i);
     _statistics.add(value);
   }

    return Player(
        id: parsedJson['id'],
        fname : parsedJson['fname'],
        lname : parsedJson['lname'],
        image : parsedJson ['image'],
        number : parsedJson ['number'],
        position : parsedJson ['position'],
        age : parsedJson ['age'],
        height : parsedJson ['height'],
        weight : parsedJson ['weight'],
        country : parsedJson ['country'],
        country_image : parsedJson ['country_image'],
        socials : _socials,
        statistics : _statistics
    );
  }
}

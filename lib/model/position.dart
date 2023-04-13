
import 'package:app/model/player.dart';

class Position {
  final int id;
  final String title;
  final List<Player> players ;


  Position( {this.id, this.title,this.players});

  factory Position.fromJson(Map<String, dynamic> parsedJson){

    List<Player> _players =  [];

    for(Map i in parsedJson ['players']){
      Player player = Player.fromJson(i);
      _players.add(player);
    }
    return Position(
      id: parsedJson['id'],
      title : parsedJson['title'],
      players : _players,
    );
  }
}


class Club {
  final int id;
  final String name;
  final String image;


  Club({this.id, this.name, this.image});

  factory Club.fromJson(Map<String, dynamic> parsedJson){
    return Club(
      id: parsedJson['id'],
      name : parsedJson['name'],
      image : parsedJson ['image'],
    );
  }
}

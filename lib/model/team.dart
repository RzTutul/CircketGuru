
class Team {
  final int id;
  final String title;
  final String subtitle;
  final String image;
  final String icon;
  final int position;
  final String type;


  Team( {this.id, this.title,this.subtitle, this.image,this.icon,this.position, this.type});

  factory Team.fromJson(Map<String, dynamic> parsedJson){
    return Team(
      id: parsedJson['id'],
      title : parsedJson['title'],
      subtitle : parsedJson['subtitle'],
      image : parsedJson ['image'],
      icon : parsedJson ['icon'],
      position : parsedJson ['position'],
      type : parsedJson ['type'],
    );
  }
}

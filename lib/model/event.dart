class Event {
  final int id;
  final String type;
  final String time;
  final String title;
  final String subtitle;
  final String image;
  final String name;


  Event({this.id, this.type, this.time, this.title, this.subtitle, this.image, this.name});

  factory Event.fromJson(Map<String, dynamic> parsedJson){
    return Event(
      id: parsedJson['id'],
      type : parsedJson['type'],
      time : parsedJson ['time'],
      title : parsedJson ['title'],
      subtitle : parsedJson ['subtitle'],
      image : parsedJson ['image'],
      name : parsedJson ['name']
    );
  }
}

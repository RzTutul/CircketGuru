
class Staff {
  final int id;
  final String name;
  final String status;
  final String image;
  final String bio;


  Staff({this.id, this.name,this.status, this.image,this.bio});

  factory Staff.fromJson(Map<String, dynamic> parsedJson){
    return Staff(
      id: parsedJson['id'],
      name : parsedJson['name'],
      status : parsedJson['status'],
      image : parsedJson ['image'],
      bio : parsedJson ['bio'],
    );
  }
}


class Article {
  final int id;
  final String title;
  final String content;
  final String created;
  final String image;



  Article( {this.id, this.title,this.content, this.created,this.image});

  factory Article.fromJson(Map<String, dynamic> parsedJson){
    return Article(
      id: parsedJson['id'],
      title : parsedJson['title'],
      content : parsedJson['content'],
      created : parsedJson ['created'],
      image : parsedJson ['image'],
    );
  }
}

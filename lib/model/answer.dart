class Answer {
  final int id;
  final String answer;
  int votes;

  Answer({this.id, this.answer, this.votes});

  factory Answer.fromJson(Map<String, dynamic> parsedJson){
    return Answer(
        id: parsedJson['id'],
        answer : parsedJson['answer'],
        votes : parsedJson ['votes']
    );
  }
}

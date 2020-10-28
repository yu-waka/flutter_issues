class Github_Issue{
  final int number;
  final String title;
  final String body;
  final String state;
  final String updated_at;

  Github_Issue.fromJson(Map<String,dynamic> json)
    : number = json['number'],
    title = json['title'],
    body = json['body'],
    state = json['state'],
    updated_at = json['updated_at'];
}
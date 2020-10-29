class GithubIssue{
  final int number;
  final String title;
  final String body;
  final String state;
  final int comments;
  final String createdAt;
  final String updatedAt;

  GithubIssue.fromJson(Map<String,dynamic> json)
    : number = json['number'],
    title = json['title'],
    body = json['body'],
    state = json['state'],
    comments = json['comments'],
    createdAt = json['created_at'],
    updatedAt = json['updated_at'];
}
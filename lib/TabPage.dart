import 'package:flutter/material.dart';
import 'package:flutter_issues/GithubIssue.dart';
import 'package:flutter_issues/Utility.dart';

class TabPage extends StatelessWidget{
  final List<GithubIssue> issues;
  final ScrollController scrollController;
  const TabPage({Key key,this.issues,this.scrollController}) :super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: _buildIssueList()
    );
  }
  Widget _buildIssueList(){
    return ListView.builder(
      controller: scrollController,
      itemBuilder:(BuildContext context,int index){
        return _buildCard(issues[index]);
      },
      itemCount: issues.length,

    );
  }
  Widget _buildCard(GithubIssue issue){

    // initializeDateFormatting("ja_JP");
    // DateTime updated_at = DateTime.parse(issue.updated_at);
    // var formatter = DateFormat('yyyy/MM/dd HH:mm',"ja_JP");
    // var formatted = formatter.format(updated_at);

    return Card(
      margin: EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
              padding: EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Text(
                    'No.'+issue.number.toString(),
                    style: TextStyle(
                        fontSize: 12.0
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3.0),
                    child:Icon(
                      Icons.comment,
                      size: 12.0,
                    ) ,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3.0),
                    child: Text(
                      issue.comments.toString(),
                      style: TextStyle(
                          fontSize: 12.0
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: Text('State:'+issue.state),
                  ),
                ],
              )
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Text(
              issue.title,
              style: TextStyle(
                  fontWeight: FontWeight.bold,fontSize: 12.0
              ),
            ),
          ),
          issue.body != null ? DefaultTextStyle(
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.grey,
            ),
            maxLines: 3,
            child: Padding(
                child: Text(
                  issue.body,
                ),
                padding: EdgeInsets.fromLTRB(12, 0, 12, 12)
            ),
          )
              :Container(),
          Padding(
            padding: EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Container(
              child: Text('updated_at:'+ Utility.dateformatFromIso8601(issue.updatedAt)),
              alignment:Alignment.centerRight,
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Container(
              child: Text('created_at:'+ Utility.dateformatFromIso8601(issue.createdAt)),
              alignment:Alignment.centerRight,
            ),
          )
        ],
      ),
    );
  }
}
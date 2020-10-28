import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';
import 'package:flutter_issues/IssueType.dart';
import 'package:flutter_issues/github_issue.dart';
import 'package:flutter_issues/Setting.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_issues/SettingPage.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Issues',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget{
  @override
  _MainPageState createState() => _MainPageState();
}
class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin{
  final _tab = <Tab> [
    Tab(text: 'all',),
    Tab(text: '2',),
    // Tab(text: '3',),
    // Tab(text: '4',),
    // Tab(text: '5',),
    // Tab(text: '6',),
  ];
  //
  List<List<Github_Issue>> issueList=[[],[],[],[],[],[]];
  TabController _tabController;
  int _activeIndex = 0;
  var _setting = Setting(false, false, 0);

  @override
  void initState(){
    super.initState();
    _tabController = TabController(vsync:this,length: _tab.length);
    _tabController.addListener(_setActiveTabIndex);
    _setIssueList(0);
  }
  void _setActiveTabIndex(){
    _activeIndex = _tabController.index;
    _setIssueList(_activeIndex);
  }

  void _setIssueList(int index){
    if(issueList[index].length == 0){
      _getIssues(index,_setting).then((value){
        setState(() {
          issueList[index] = value;
        });
      });
    }
  }

  @override
  void dispose(){
    _tabController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Issues'),
        actions: [
          IconButton(icon: Icon(Icons.list), onPressed: _showSetting)
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: _tab,
        ),
      ),
      body:  TabBarView(
        controller: _tabController,
        children: <Widget>[
          //all
          issueList[0].length != 0 ?
          TabPage(issues: issueList[IssueType.all.index],) :
          Center(
            child: Text('Issueの読み込み中です'),
          ),
          //p: webview
          issueList[1].length != 0 ?
          TabPage(issues: issueList[IssueType.webview.index],):
          Center(
            child: Text('Issueの読み込み中です'),
          ),
        ],
      ),
    );
  }
  void _showSetting() async{
    final result = await showDialog<Setting>(
        context: context,
        builder: (_){
          return SettingPage(setting: _setting,);
        }
    );
    if(result != null){
      _setting = result;
      setState(() {
        issueList.forEach((element) {element.clear();});
      });
      _setIssueList(_activeIndex);
    }
  }
}

class TabPage extends StatelessWidget{
  final IssueType type;
  final List<Github_Issue> issues;
  const TabPage({Key key, this.type,this.issues}) :super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: _buildIssueList()
    );
  }
  Widget _buildIssueList(){
    return ListView.builder(
        itemBuilder:(BuildContext context,int index){
          return _buildCard(issues[index]);
        },
      itemCount: issues.length,
    );
  }
  Widget _buildCard(Github_Issue issue){
    return Card(
      margin: EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(
              issue.number.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,fontSize: 12.0
              ),
            ),
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
          DefaultTextStyle(
              style: TextStyle(
                fontWeight: FontWeight.w200,
                color: Colors.grey,
              ),
              maxLines: 3,
              child: Padding(
                child: Text(
                  issue.body,
                ),
                padding: EdgeInsets.fromLTRB(12, 0, 12, 12)
              ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: 50,
                child: Text(issue.state),
              )
            ],
          ),
        ],
      ),
    );
  }
}
  Future<List<Github_Issue>> _getIssues(int issueType,Setting setting) async{
  String sortQuery = '';
  String labelsquery = '';
  String stateQuery = '';
  //ソートクエリの生成
    switch(setting.sortType){
      case 0:
        sortQuery = "?sort=created&order=desc";
        break;
      case 1:
        sortQuery = "?sort=updated&order=asc";
        break;
      case 2:
        sortQuery = "?sort=comments&order=desc";

        break;
    }
  //ラベルによる絞り込み
    switch(issueType){
      case 0:
        break;
      case 1:
        labelsquery = '&labels=p: webview';
        break;
    }
    if(setting.excludeClosedIssues){
      stateQuery = '&state=open';
    }else{
      stateQuery = '&state=all';
    }

    final respons = await http.get('https://api.github.com/repos/flutter/flutter/issues'+sortQuery+labelsquery+stateQuery);
    if(respons.statusCode == 200){
      List<Github_Issue> list =[];
      List<dynamic> decoded = json.decode(respons.body);
      for(var item in decoded){
        list.add(Github_Issue.fromJson(item));
      }
      return list;
    }else{
      throw Exception('Fail to get issues');
    }
  }
// }
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_issues/GithubIssue.dart';
import 'package:flutter_issues/Setting.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_issues/SettingPage.dart';
import 'package:flutter_issues/TabPage.dart';
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
    Tab(text: 'p: webview',),
    Tab(text: 'p: shared_preferences',),
    Tab(text: 'waiting for customer response',),
    Tab(text: 'severe: new feature',),
    Tab(text: 'p: share',),
  ];
  //
  List<List<GithubIssue>> issueList=[[],[],[],[],[],[]];
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
          TabPage(issues: issueList[0],) :
          Center(
            child: Text('Issueの読み込み中です'),
          ),
          //p: webview
          issueList[1].length != 0 ?
          TabPage(issues: issueList[1],):
          Center(child: Text('Issueの読み込み中です'),),
          //
          issueList[2].length != 0 ?
          TabPage(issues: issueList[2],):
          Center(child: Text('Issueの読み込み中です'),),
          //
          issueList[3].length != 0 ?
          TabPage(issues: issueList[3],):
          Center(child: Text('Issueの読み込み中です'),),
          //
          issueList[4].length != 0 ?
          TabPage(issues: issueList[4],):
          Center(child: Text('Issueの読み込み中です'),),
          //
          issueList[5].length != 0 ?
          TabPage(issues: issueList[5],):
          Center(child: Text('Issueの読み込み中です'),),
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

  //issuesの取得処理
  Future<List<GithubIssue>> _getIssues(int issueType,Setting setting) async{
    String sortQuery = '';
    String labelsquery = '';
    String stateQuery = '';
    String dateQuery = '';
    //ソートクエリの生成
    switch(setting.sortType){
      case 0:
        sortQuery = "&sort=created&direction=desc";
        break;
      case 1:
        sortQuery = "&sort=updated&direction=asc";
        break;
      case 2:
        sortQuery = "&sort=comments&direction=desc";

        break;
    }
    //ラベルによる絞り込み
    switch(issueType){
      case 0:
        break;
      case 1:
        labelsquery = '&labels=p: webview';
        break;
      case 2:
        labelsquery = '&labels=p: shared_preferences';
        break;
      case 3:
        labelsquery = '&labels=waiting for customer response';
        break;
      case 4:
        labelsquery = '&labels=severe: new feature';
        break;
      case 5:
        labelsquery = '&labels=p: share';
        break;
    }
    if(setting.excludeClosedIssues){
      stateQuery = '?state=open';
    }else{
      stateQuery = '?state=all';
    }
    if(setting.excludeOldIssues){
      //1年前の時刻を取得
      DateTime oneYearsAgo = DateTime.now().toUtc().add(Duration(days: 365) * -1);
      dateQuery = '&since='+ oneYearsAgo.toIso8601String();
    }

    final respons = await http.get('https://api.github.com/repos/flutter/flutter/issues'+stateQuery+dateQuery+labelsquery+sortQuery);
    if(respons.statusCode == 200){
      List<GithubIssue> list =[];
      List<dynamic> decoded = json.decode(respons.body);
      for(var item in decoded){
        list.add(GithubIssue.fromJson(item));
      }
      return list;
    }else{
      throw Exception('Fail to get issues');
    }
  }
}
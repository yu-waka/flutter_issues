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
  List<List<GithubIssue>> _issueList=[[],[],[],[],[],[]];
  List<Setting> _settingList=[
    Setting(false, false, 0),
    Setting(false, false, 0),
    Setting(false, false, 0),
    Setting(false, false, 0),
    Setting(false, false, 0),
    Setting(false, false, 0)];

  List<int> _pageList = [1,1,1,1,1,1];
  List<bool> _loadStateList = [false,false,false,false,false,false];

  TabController _tabController;
  ScrollController _scrollController;
  int _activeIndex = 0;

  @override
  void initState(){
    super.initState();
    _tabController = TabController(vsync:this,length: _tab.length);
    _tabController.addListener(_setActiveTabIndex);

    _scrollController = ScrollController();
    _scrollController.addListener(_setScrollEvent);

    _setIssueList(0);
  }
  void _setActiveTabIndex(){
    _activeIndex = _tabController.index;
    _setIssueList(_activeIndex);
  }
  void _setScrollEvent(){
    final maxScrollExtent = _scrollController.position.maxScrollExtent;
    final currentPosition = _scrollController.position.pixels;
    if (maxScrollExtent > 0 &&
        (maxScrollExtent - 20.0) <= currentPosition) {
      //
      _addIssueList(_activeIndex);
    }
  }
  void _setIssueList(int index){
    //既にIssueリストを取得している場合、実行しない
    if(_issueList[index].length != 0){
      return;
    }
      _getIssues(index,_settingList[index],1).then((value){
        setState(() {
          _issueList[index] = value;
        });
      });
  }
  void _addIssueList(int index){
    //Issueリスト読み込み中の場合、実行しない
    if(_loadStateList[index] == true) {
      return;
    }
    _loadStateList[index] = true;
    _pageList[index]++;
    _getIssues(index, _settingList[index], _pageList[index]).then((value){
      setState(() {
        _issueList[index].addAll(value);
        _loadStateList[index] = false;
      });
    });
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
          _issueList[0].length != 0 ?
          TabPage(issues: _issueList[0],scrollController: _scrollController,) :
          Center(child: Text('Issueの読み込み中です'),),
          //p: webview
          _issueList[1].length != 0 ?
          TabPage(issues: _issueList[1],scrollController: _scrollController,):
          Center(child: Text('Issueの読み込み中です'),),
          //
          _issueList[2].length != 0 ?
          TabPage(issues: _issueList[2],scrollController: _scrollController,):
          Center(child: Text('Issueの読み込み中です'),),
          //
          _issueList[3].length != 0 ?
          TabPage(issues: _issueList[3],scrollController: _scrollController,):
          Center(child: Text('Issueの読み込み中です'),),
          //
          _issueList[4].length != 0 ?
          TabPage(issues: _issueList[4],scrollController: _scrollController,):
          Center(child: Text('Issueの読み込み中です'),),
          //
          _issueList[5].length != 0 ?
          TabPage(issues: _issueList[5],scrollController: _scrollController,):
          Center(child: Text('Issueの読み込み中です'),),
        ],
      ),
    );
  }
  void _showSetting() async{
    //現在の設定値を保持
    final bkexcludeClosedIssues = _settingList[_activeIndex].excludeClosedIssues;
    final bkexcludeOldIssues = _settingList[_activeIndex].excludeOldIssues;
    final bksortType = _settingList[_activeIndex].sortType;

    //ダイアログの表示
    final result = await showDialog<Setting>(
        context: context,
        builder: (_){
          return SettingPage(setting: _settingList[_activeIndex],);
        }
    );

    //設定ダイアログクローズ時のパラメータチェック
    if(result != null){
      //更新ボタンが押された場合、リストの更新を実行する
      _settingList[_activeIndex] = result;
      setState(() {
        _issueList[_activeIndex].clear();
      });
      //絞りこみ条件が更新された為、ページ数をリセット
      _pageList[_activeIndex]=1;
      //Issueリストの取得
      _setIssueList(_activeIndex);
    }else{
      //更新ボタンを押されずにダイアログが閉じた場合、操作前の設定値に戻す
      _settingList[_activeIndex].excludeClosedIssues = bkexcludeClosedIssues;
      _settingList[_activeIndex].excludeOldIssues = bkexcludeOldIssues;
      _settingList[_activeIndex].sortType = bksortType;
    }
  }

  //issuesの取得処理
  Future<List<GithubIssue>> _getIssues(int issueType,Setting setting,int page) async{
    String sortQuery = '';
    String labelsquery = '';
    String stateQuery = '';
    String dateQuery = '';
    String pageQuery = '';
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
    //issueのstateでの絞り込み
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

    //
    pageQuery = "&page="+page.toString();

    //apiリクエストの実行
    final respons = await http.get('https://api.github.com/repos/flutter/flutter/issues'+stateQuery+dateQuery+labelsquery+sortQuery+pageQuery);
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
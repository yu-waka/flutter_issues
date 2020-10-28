import 'package:flutter/material.dart';
import 'package:flutter_issues/Setting.dart';
class SettingPage extends StatefulWidget{
  final Setting setting;
  const SettingPage({Key key,this.setting}):super(key: key);
  @override
  _SettingPageState createState() => _SettingPageState();
}
class _SettingPageState extends State<SettingPage>{
  Setting _setting;

  Widget excludeClosedIssues(){
    return CheckboxListTile(
        title: Text('Closed状態のIssueを除外する'),
        value: _setting.excludeClosedIssues,
        onChanged:(bool e){
          setState(() {
            _setting.excludeClosedIssues = e;
          });
        });
  }
  Widget excludeOldIssues(){
    return CheckboxListTile(
        title: Text('1年以上更新のないIssueを除外する'),
        value: _setting.excludeOldIssues,
        onChanged:(bool e){
          setState(() {
            _setting.excludeOldIssues  = e;
          });
        });
  }
  Widget sortType(){
    return Column(
      children: [
        RadioListTile(
          title: Text('作成日時の新しい順'),
          value: 0,
          groupValue: _setting.sortType,
          onChanged: (_){
            setState(() {
              _setting.sortType = 0;
            });
          },
        ),
        RadioListTile(
          title: Text('更新日の古い順'),
          value: 1,
          groupValue: _setting.sortType,
          onChanged: (_){
            setState(() {
              _setting.sortType = 1;
            });
          },
        ),
        RadioListTile(
          title: Text('コメントの多い順'),
          value: 2,
          groupValue: _setting.sortType,
          onChanged: (_){
            setState(() {
              _setting.sortType = 2;
            });
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      _setting = widget.setting;
    });
    return SimpleDialog(
      children: [
        excludeClosedIssues(),
        excludeOldIssues(),
        sortType(),
        Padding(
          padding: EdgeInsets.all(12),
          child: RaisedButton(
            child: Text('更新する'),
            onPressed: (){
              Navigator.pop(context,_setting);

            },
          ),)
      ],
    );
  }
}
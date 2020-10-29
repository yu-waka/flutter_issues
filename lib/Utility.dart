import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class Utility{
  //iso8601形式からのフォーマット
  static String dateformatFromIso8601(String str){
    initializeDateFormatting("ja_JP");
    DateTime dateTime = DateTime.parse(str);
    var formatter = DateFormat('yyyy/MM/dd(E) HH:mm', "ja_JP");
    return formatter.format(dateTime);
  }
}
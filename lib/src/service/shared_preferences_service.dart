import 'package:shared_preferences/shared_preferences.dart';
Future<bool> fetchIsDark() async {
  final prefs = await SharedPreferences.getInstance();
  var isDark = prefs.getBool('isDark');
  return isDark != null ? isDark : false;
}
Future<List<String>> fetchLocalTechs() async{
  final prefs = await SharedPreferences.getInstance();
  //Add to favorite techs
  return prefs.getStringList('techs');
}
Future<bool> setLocalTechs(List<String> localTechIdList) async{
  final prefs = await SharedPreferences.getInstance();
  //Add to favorite techs
  return await prefs.setStringList('techs', localTechIdList);
}

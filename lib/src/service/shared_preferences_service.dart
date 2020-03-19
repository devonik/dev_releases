import 'package:shared_preferences/shared_preferences.dart';

Future<List<String>> fetchLocalTechs() async{
  final prefs = await SharedPreferences.getInstance();
  //Add to favorite techs
  return prefs.getStringList('techs');
}

Future<bool> isThemeDark() async{
  final prefs = await SharedPreferences.getInstance();
  //Add to favorite techs
  return prefs.getBool('isDark');
}

import 'package:shared_preferences/shared_preferences.dart';
class SharedPrefsHelper{
  static late SharedPreferences sharedPrefs;
    static Future<SharedPreferences> init() async {
    return  sharedPrefs=await SharedPreferences.getInstance();
    }

    //get=save data
    static Future<bool> saveData({required String key,required dynamic value}) async {
      if (value is int) {
        return  await sharedPrefs.setInt(key, value);
      }
      else  if (value is double) {
        return  await sharedPrefs.setDouble(key, value);
      }
      else  if (value is String) {
        return  await sharedPrefs.setString(key, value);
      }
      else  if (value is List<String>) {
        return  await sharedPrefs.setStringList(key, value);
      }
      else{
        return  await sharedPrefs.setBool(key, value);

      }
    }
    //read data
  static Object? getData({required String key})  {
      return sharedPrefs.get(key);
  }
  static Future<bool> removeData({required String key}) async {
      return  await sharedPrefs.remove(key);
  }


}
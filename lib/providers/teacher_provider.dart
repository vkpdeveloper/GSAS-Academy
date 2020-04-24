import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TeacherProvider with ChangeNotifier {
  String _name;
  String _mobile;
  String _teacherID;
  String _teacherProfile;
  DateTime _date = DateTime.now();

  TeacherProvider() {
    _name = "";
    _mobile = "";
    _teacherID = "";
    _teacherProfile = "";
    loadTeacherData();
  }

  // GETTERS
  String get getCurrentDate => "${_date.day}-${_date.month}-${_date.year}";
  String get getTeacherName => _name;
  String get getTeacherProfile => _teacherProfile;
  String get getTeacherMobile => _mobile;
  String get getTeacherID => _teacherID;

  loadTeacherData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    _name = preferences.getString('name');
    _mobile = preferences.getString('mobile');
    _teacherProfile = preferences.getString('profile');
    _teacherID = preferences.getString('mobile');
    notifyListeners();
  }
}

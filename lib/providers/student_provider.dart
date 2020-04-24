import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentProvider extends ChangeNotifier {
  String _presentStatus;
  bool _isPresent;
  String _studentName;
  String _studentClass;
  String _studentSection;
  String _studentID;
  String _studentProfile;
  String _studentMobile;
  Firestore _firestore = Firestore.instance;
  DateTime _currentDate = DateTime.now();
  String _todayDate;

  StudentProvider() {
    _isPresent = false;
    _presentStatus = "Loading...";
    _studentName = "";
    _studentClass = "";
    _studentSection = "";
    _studentMobile = "";
    _studentID = "";
    _studentProfile = "";
    _todayDate =
        "${_currentDate.day}-${_currentDate.month}-${_currentDate.year}";
    getStudentInfo();
    Timer(Duration(milliseconds: 200), checkPresenty);
  }

  bool get getAttendance => _isPresent;
  String get getTodayDate => _todayDate;
  String get getStudentName => _studentName;
  String get getStudentClass => _studentClass;
  String get getStudentSection => _studentSection;
  String get getStudentMobile => _studentMobile;
  String get getStudentID => _studentID.replaceAll('/', '-');
  String get getStudentProfile => _studentProfile;
  String get getPresentStatus => _presentStatus;

  void checkPresenty() async {
    if (_currentDate.weekday == 7) {
      _isPresent = true;
      _presentStatus = "Holiday";
      notifyListeners();
    } else {
      if (_currentDate.hour > 9) {
        _firestore
            .collection('attendance')
            .document(_studentClass)
            .collection(_todayDate)
            .document(_studentID.replaceAll('/', '-'))
            .get()
            .then((data) {
          if (!data.exists) {
            _firestore
                .collection('attendance')
                .document(_studentClass)
                .collection(_todayDate)
                .document(_studentID.replaceAll('/', '-'))
                .setData({
              "isPresent": false,
              "name": _studentName,
              "id": _studentID.replaceAll('/', '-'),
              "section": _studentSection,
              "profile": _studentProfile
            });
            _presentStatus = "Absent";
            _isPresent = false;
            notifyListeners();
          } else {
            if (data.data['isPresent'] == true) {
              _presentStatus = "Present";
              _isPresent = true;
              notifyListeners();
            } else {
              _presentStatus = "Absent";
              _isPresent = false;
              notifyListeners();
            }
          }
        });
      } else {
        DocumentSnapshot _attendanceData = await _firestore
            .collection('attendance')
            .document(_studentClass)
            .collection(_todayDate)
            .document(_studentID.replaceAll('/', '-'))
            .get();
        if (_attendanceData.exists &&
            _attendanceData.data['isPresent'] == true) {
          _presentStatus = "Present";
          _isPresent = true;
          notifyListeners();
        } else {
          _presentStatus = "Sign Attendance";
          _isPresent = false;
          notifyListeners();
        }
      }
    }
  }

  bool get isSunday => _currentDate.weekday == 7;

  void setPresent() async {
    if (!_isPresent && _presentStatus != "Adsent") {
      _firestore
          .collection('attendance')
          .document(_studentClass)
          .collection(_todayDate)
          .document(_studentID.replaceAll('/', '-'))
          .setData({
        "isPresent": true,
        "name": _studentName,
        "id": _studentID.replaceAll('/', '-'),
        "section": _studentSection,
        "profile": _studentProfile
      });
      _presentStatus = "Present";
      _isPresent = true;
      notifyListeners();
    }
  }

  void getStudentInfo() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _studentName = _prefs.getString('name');
    _studentClass = _prefs.getString('class');
    _studentSection = _prefs.getString('section');
    _studentID = _prefs.getString('admID');
    _studentProfile = _prefs.getString('profile');
    _studentMobile = _prefs.getString('mobile');
    notifyListeners();
  }
}

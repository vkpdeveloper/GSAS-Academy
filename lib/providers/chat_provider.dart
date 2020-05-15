import 'dart:io';
import 'package:flutter/material.dart';

class ChatProvider with ChangeNotifier {
  List<String> _allClasses = [
    'LKG',
    'UKG',
    '1st',
    '2nd',
    '3rd',
    '4th',
    '5th',
    '6th',
    '7th',
    '8th',
    '9th',
    '10th',
    '11th',
    '12th'
  ];
  List<String> _allSection = ['A', 'B', 'C', 'D'];
  List<String> _allSubject = [
    "Physics",
    "Chemistry",
    "Biology",
    "Mathematics",
    "Computer",
    "Hindi",
    "English",
    "Economics",
    "Geography",
    "Political science",
    "History",
    "Sanskrit",
  ];
  List<String> _allDays = List.generate(32, (day) => day.toString());
  List<String> _allMonths = List.generate(13, (month) => month.toString());
  String _selectedSection = "A";
  String _selectedClass = '9th';
  String _selectedSubject = "Physics";
  String _selectFileText = "Select PDF";
  String _selectVideoFile = "Select Video";
  File _selectedPDFFile;
  DateTime _date = DateTime.now();
  String _selectedMonth;
  String _selectedDay;
  String _selectedYear;

  ChatProvider() {
    _selectedMonth = _date.month.toString();
    _selectedDay = _date.day.toString();
    getAllCalendar();
    _selectedYear = _date.year.toString();
  }

  String get getSelectedDay => _selectedDay;
  String get getSelectedMonth => _selectedMonth;
  List<String> get getAllDays => _allDays;
  List<String> get getAllMonths => _allMonths;
  String get getSelectedYear => _selectedYear;

  setDay(String value) {
    _selectedDay = value;
    notifyListeners();
  }

  setMonth(String value) {
    _selectedMonth = value;
    notifyListeners();
  }

  getAllCalendar() {
    _allMonths.remove(0.toString());
    _allDays.remove(0.toString());
    notifyListeners();
  }

  List<String> get getAllClasses => _allClasses;
  String get getCurrentDate => "${_date.day}-${_date.month}-${_date.year}";
  List<String> get getAllSection => _allSection;
  String get getSelectedSection => _selectedSection;
  File get getSelectedFile => _selectedPDFFile;
  String get getSelectedClass => _selectedClass;
  String get getSelectedSubject => _selectedSubject;
  List<String> get getAllSubject => _allSubject;
  String get getSelectionText => _selectFileText;
  String get getVideoFileText => _selectVideoFile;

  void setAfterSelect(String newText) {
    _selectFileText = newText;
    notifyListeners();
  }

  void setVideoFileText(String newText) {
    _selectVideoFile = newText;
    notifyListeners();
  }

  void setFilePath(File newFile) {
    _selectedPDFFile = newFile;
    notifyListeners();
  }

  void setSubject(String newSubject) {
    _selectedSubject = newSubject;
    notifyListeners();
  }

  void setClass(String newClass) {
    _selectedClass = newClass;
    notifyListeners();
  }

  void setSection(String newSection) {
    _selectedSection = newSection;
    notifyListeners();
  }
}

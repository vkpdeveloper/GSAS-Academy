import 'dart:io';

import 'package:flutter/material.dart';

class ChatProvider with ChangeNotifier {
  List<String> _allClasses = ['9th', '10th', '11th', '12th'];
  List<String> _allSection = ['A', 'B', 'C', 'D'];
  List<String> _allSubject = [
    "Physics",
    "Chemistry",
    "Biology",
    "Mathematics",
    "Computer",
    "Hindi",
    "English",
    "Social Science"
  ];
  String _selectedSection = "A";
  String _selectedClass = '9th';
  String _selectedSubject = "Physics";
  String _selectFileText = "Select PDF";
  String _selectVideoFile = "Select Video";
  File _selectedPDFFile;
  DateTime _date = DateTime.now();

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

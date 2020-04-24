import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gsasacademy/enum/view_state.dart';
import 'package:gsasacademy/providers/student_provider.dart';
import 'package:gsasacademy/utils/firebaseutils.dart';

class HomeworkProvider with ChangeNotifier {
  FirebaseUtils _utils = FirebaseUtils();
  DocumentSnapshot _snapshot;
  bool _isHomeworkDone;
  ViewState _viewState = ViewState.IDLE;
  ViewState get getViewState => _viewState;

  HomeworkProvider() {
    _isHomeworkDone = false;
  }

  void setToLoading() {
    _viewState = ViewState.LOADING;
    notifyListeners();
  }

  void setToIdle() {
    _viewState = ViewState.IDLE;
    notifyListeners();
  }

  bool get isHomeworkDone => _isHomeworkDone;

  isHomeworkDoneof(StudentProvider studentProvider, String subject) async {
    DocumentSnapshot snapshot =
        await _utils.isHomeworkDoneOf(studentProvider, subject);
    if (snapshot != null) {
      if (snapshot.exists) {
        _isHomeworkDone = true;
        notifyListeners();
      }
    } else {
      _isHomeworkDone = false;
      notifyListeners();
    }
  }
}

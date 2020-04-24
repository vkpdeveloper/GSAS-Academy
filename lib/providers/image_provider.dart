import 'package:flutter/widgets.dart';
import 'package:gsasacademy/enum/view_state.dart';

class ImageUploadProvider with ChangeNotifier {
  ViewState _viewState = ViewState.IDLE;
  bool _isEditedMessage = false;
  ViewState get getViewState => _viewState;
  String _docID;

  void setToLoading() {
    _viewState = ViewState.LOADING;
    notifyListeners();
  }

  void setToIdle() {
    _viewState = ViewState.IDLE;
    notifyListeners();
  }

  void setEditedMessage(bool isEditing) {
    _isEditedMessage = isEditing;
    notifyListeners();
  }

  void setDocID(String documentID) {
    _docID = documentID;
    notifyListeners();
  }

  bool get getEditingMessage => _isEditedMessage;
  String get getDocID => _docID;

}
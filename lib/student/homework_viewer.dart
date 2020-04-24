import 'dart:io';
import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'package:gsasacademy/enum/view_state.dart';
import 'package:gsasacademy/providers/homework_provider.dart';
import 'package:gsasacademy/providers/student_provider.dart';
import 'package:gsasacademy/utils/firebaseutils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class HomeworkPDFViewer extends StatelessWidget {
  final PDFDocument documnet;
  final String title;

  const HomeworkPDFViewer({Key key, this.documnet, this.title})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final FirebaseUtils _utils = FirebaseUtils();
    HomeworkProvider _homeworkProvider = Provider.of<HomeworkProvider>(context);
    StudentProvider studentProvider = Provider.of<StudentProvider>(context);

    checkIsHomeworkDone() {
      _homeworkProvider.isHomeworkDoneof(studentProvider, title);
    }

    checkIsHomeworkDone();

    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          _homeworkProvider.getViewState == ViewState.LOADING
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.only(right:8.0),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : _homeworkProvider.isHomeworkDone
                  ? IgnorePointer(
                      ignoring: true,
                      child: FlatButton(
                        onPressed: () {},
                        textColor: Colors.white,
                        child: Text(
                          "Homework Submitted",
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ),
                    )
                  : FlatButton(
                      onPressed: () async {
                        File homeworkFile = await ImagePicker.pickImage(
                            source: ImageSource.camera);
                        _utils.submitHomework(studentProvider, homeworkFile,
                            _homeworkProvider, title);
                      },
                      textColor: Colors.white,
                      child: Text(
                        "Submit Homework",
                        style: TextStyle(fontSize: 16.0),
                      ),
                    )
        ],
        title: Text("$title Homework"),
      ),
      body: PDFViewer(
        document: documnet,
      ),
    );
  }
}

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gsasacademy/providers/chat_provider.dart';
import 'package:gsasacademy/themeConstants.dart';
import 'package:gsasacademy/utils/firebaseutils.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provider/provider.dart';

class TeacherVideoUploader extends StatefulWidget {
  @override
  _TeacherVideoUploaderState createState() => _TeacherVideoUploaderState();
}

class _TeacherVideoUploaderState extends State<TeacherVideoUploader> {
  File videoFile;
  FirebaseUtils _utils = FirebaseUtils();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ChatProvider provider = Provider.of<ChatProvider>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text("Upload Video Class"),
        ),
        body: Container(
            child: Column(children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 0.0, left: 20.0),
            child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Select Class and Section : ",
                  style: TextStyle(fontSize: 16.0),
                )),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 40.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                DropdownButton<String>(
                  value: provider.getSelectedClass,
                  onChanged: (value) {
                    provider.setClass(value);
                  },
                  items: provider.getAllClasses.map((cls) {
                    return DropdownMenuItem<String>(
                      value: cls,
                      child: Text("Class $cls"),
                    );
                  }).toList(),
                ),
                SizedBox(
                  width: 20.0,
                ),
                DropdownButton<String>(
                  value: provider.getSelectedSection,
                  onChanged: (value) {
                    provider.setSection(value);
                  },
                  items: provider.getAllSection.map((sec) {
                    return DropdownMenuItem<String>(
                      value: sec,
                      child: Text("Section $sec"),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          DropdownButton<String>(
            value: provider.getSelectedSubject,
            onChanged: (value) {
              provider.setSubject(value);
            },
            items: provider.getAllSubject.map((sub) {
              return DropdownMenuItem<String>(
                value: sub,
                child: Text("$sub"),
              );
            }).toList(),
          ),
          SizedBox(
            height: 10.0,
          ),
          MaterialButton(
            color: ThemeConst.primaryColor,
            textColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0)),
            onPressed: () async {
              videoFile = await FilePicker.getFile(type: FileType.video);
              if (videoFile != null) {
                provider.setVideoFileText("Video Selected");
              }
            },
            child: Text(
              provider.getVideoFileText,
              style: TextStyle(fontSize: 16.0),
            ),
            minWidth: MediaQuery.of(context).size.width - 30,
            height: 40.0,
          ),
          SizedBox(
            height: 20.0,
          ),
          MaterialButton(
            color: ThemeConst.primaryColor,
            textColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0)),
            onPressed: () async {
              if (videoFile != null) {
                ProgressDialog progressDialog = ProgressDialog(context,
                    isDismissible: false, type: ProgressDialogType.Normal);
                progressDialog.show();
                progressDialog.style(message: "Starting...");
                _utils.addOnlineClass(progressDialog, provider, videoFile);
              } else {
                Fluttertoast.showToast(msg: "File is not selected");
              }
            },
            child: Text(
              "Add Class",
              style: TextStyle(fontSize: 16.0),
            ),
            minWidth: MediaQuery.of(context).size.width - 30,
            height: 40.0,
          ),
        ])));
  }
}

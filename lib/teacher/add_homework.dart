import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gsasacademy/enum/view_state.dart';
import 'package:gsasacademy/providers/chat_provider.dart';
import 'package:gsasacademy/providers/image_provider.dart';
import 'package:gsasacademy/themeConstants.dart';
import 'package:gsasacademy/utils/firebaseutils.dart';
import 'package:provider/provider.dart';

class AddHomework extends StatelessWidget {
  final TextEditingController _aboutHomeworkCont = TextEditingController();
  final FirebaseUtils _utils = FirebaseUtils();
  @override
  Widget build(BuildContext context) {
    ChatProvider provider = Provider.of<ChatProvider>(context);
    ImageUploadProvider imageUploadProvider =
        Provider.of<ImageUploadProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Homework"),
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
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 40.0),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: <Widget>[
              MaterialButton(
                color: ThemeConst.primaryColor,
                textColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0)),
                onPressed: () async {
                  File pdfFile = await FilePicker.getFile(
                      type: FileType.custom, allowedExtensions: ['pdf']);
                  provider.setAfterSelect("PDF Selected");
                  provider.setFilePath(pdfFile);
                },
                child: Text(
                  provider.getSelectionText,
                  style: TextStyle(fontSize: 16.0),
                ),
                minWidth: MediaQuery.of(context).size.width - 30,
                height: 40.0,
              ),
              SizedBox(height: 15.0,),
              TextField(
                controller: _aboutHomeworkCont,
                decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0)),
                    hintText: "Enter What to do in the homework",
                    labelText: "About Homework"),
              ),
              SizedBox(
                height: 20.0,
              ),
              if (imageUploadProvider.getViewState == ViewState.LOADING)
                CircularProgressIndicator(),
              if (imageUploadProvider.getViewState == ViewState.IDLE)
                MaterialButton(
                  color: ThemeConst.primaryColor,
                  textColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0)),
                  onPressed: () {
                    if (_aboutHomeworkCont.text.trim() != "") {
                      if (provider.getSelectionText == "PDF Selected") {
                        _utils.addHomeWorkInClass(
                            imageUploadProvider, provider, _aboutHomeworkCont.text);
                      } else {
                        Fluttertoast.showToast(msg: "PDF File not selected");
                      }
                    } else {
                      Fluttertoast.showToast(msg: "Enter about homework");
                    }
                  },
                  child: Text(
                    "Add Homework",
                    style: TextStyle(fontSize: 16.0),
                  ),
                  minWidth: MediaQuery.of(context).size.width - 30,
                  height: 40.0,
                )
            ],
          ),
        )
      ])),
    );
  }
}

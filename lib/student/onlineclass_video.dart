import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gsasacademy/providers/student_provider.dart';
import 'package:gsasacademy/student/class_videoplayer.dart';
import 'package:gsasacademy/themeConstants.dart';
import 'package:gsasacademy/utils/firebaseutils.dart';
import 'package:gsasacademy/utils/static_methods.dart';
import 'package:provider/provider.dart';

class StudentOnlineClass extends StatefulWidget {
  final String studentClass;

  StudentOnlineClass({@required this.studentClass});

  @override
  _HomeworkStudentState createState() => _HomeworkStudentState();
}

class _HomeworkStudentState extends State<StudentOnlineClass> {
  FirebaseUtils _utils = FirebaseUtils();
  Map<String, dynamic> allClasses;
  StaticMethods _staticMethods = StaticMethods();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    StudentProvider studentProvider = Provider.of<StudentProvider>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text("Today's Classes"),
        ),
        body: StreamBuilder(
          stream: Firestore.instance
              .collection('onlineClass')
              .document(studentProvider.getStudentClass)
              .collection(studentProvider.getStudentSection)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Center(
                  child: CircularProgressIndicator(),
                );
                break;
              default:
                return Padding(
                  padding: const EdgeInsets.only(
                      left: 20.0, right: 20.0, top: 8.0, bottom: 10.0),
                  child: ListView(
                    children:
                        snapshot.data.documents.map((DocumentSnapshot data) {
                      if (data.data['date'] == studentProvider.getTodayDate) {
                        return Card(
                          elevation: 5.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0)),
                          child: ListTile(
                            title: Text(data.documentID),
                            trailing: MaterialButton(
                              color: ThemeConst.primaryColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0)),
                              textColor: Colors.white,
                              onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          OnlineClassVideoPlayer(
                                            subject: data.documentID,
                                            videoURL: data.data['video'],
                                          ))),
                              child: Text(
                                "Open Class",
                                style: TextStyle(fontSize: 16.0),
                              ),
                            ),
                          ),
                        );
                      }else{
                        return Card(
                          elevation: 5.0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0)),
                          child: ListTile(
                            title: Text(data.documentID),
                            subtitle: Text("Class not available yet !"),
                          ),
                        );
                      }
                    }).toList(),
                  ),
                );
            }
          },
        ));
  }
}

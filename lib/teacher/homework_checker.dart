import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gsasacademy/providers/chat_provider.dart';
import 'package:gsasacademy/teacher/homework_verifier.dart';
import 'package:provider/provider.dart';

class HomeworkChecker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ChatProvider provider = Provider.of<ChatProvider>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text("Homework Checker"),
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
          Expanded(
            child: StreamBuilder(
              stream: Firestore.instance
                  .collection('submittedHomework')
                  .document(provider.getSelectedClass)
                  .collection(provider.getSelectedSection)
                  .document(provider.getCurrentDate)
                  .collection(provider.getSelectedSubject)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  default:
                    if (snapshot.data.documents.length == 0) {
                      return Center(
                        child: Text("No Homeworks Submitted Yet !"),
                      );
                    } else {
                      return ListView(
                        children:
                            snapshot.data.documents.map((DocumentSnapshot doc) {
                          if (doc.data['isChecked'] == false) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                  top: 10.0, left: 15.0, right: 15.0),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0)),
                                elevation: 8.0,
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.all(10.0),
                                      child: Column(
                                        children: <Widget>[
                                          Align(
                                              alignment: Alignment.topLeft,
                                              child: Text(
                                                "ADM ID: ${doc.documentID}",
                                                style:
                                                    TextStyle(fontSize: 16.0),
                                              )),
                                          SizedBox(
                                            height: 5.0,
                                          ),
                                          Align(
                                              alignment: Alignment.topLeft,
                                              child: Text(
                                                "Name: ${doc.data['name']}",
                                                style:
                                                    TextStyle(fontSize: 16.0),
                                              )),
                                          SizedBox(
                                            height: 5.0,
                                          ),
                                        ],
                                      ),
                                    ),
                                    MaterialButton(
                                      height: 40.0,
                                      minWidth:
                                          MediaQuery.of(context).size.width -
                                              40,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(15.0),
                                              bottomRight:
                                                  Radius.circular(15.0))),
                                      onPressed: () async {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    HomeworkVerifier(
                                                      title: doc.documentID,
                                                      documentSnapshot: doc,
                                                    )));
                                      },
                                      color: Colors.green,
                                      child: Text(
                                        "Open Homework",
                                        style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          } else {
                            return Padding(
                              padding: const EdgeInsets.only(
                                  top: 10.0, left: 15.0, right: 15.0),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0)),
                                elevation: 8.0,
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.all(10.0),
                                      child: Column(
                                        children: <Widget>[
                                          Align(
                                              alignment: Alignment.topLeft,
                                              child: Text(
                                                "ADM ID: ${doc.documentID}",
                                                style:
                                                    TextStyle(fontSize: 16.0),
                                              )),
                                          SizedBox(
                                            height: 5.0,
                                          ),
                                          Align(
                                              alignment: Alignment.topLeft,
                                              child: Text(
                                                "Name: ${doc.data['name']}",
                                                style:
                                                    TextStyle(fontSize: 16.0),
                                              )),
                                          SizedBox(
                                            height: 5.0,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        "Homework Checked ${doc.data['isCorrect'] ? "(Correct)" : "(Wrong)"}",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5.0,
                                    )
                                  ],
                                ),
                              ),
                            );
                          }
                        }).toList(),
                      );
                    }
                }
              },
            ),
          )
        ])));
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:gsasacademy/providers/chat_provider.dart';
import 'package:provider/provider.dart';

class StudentAttendance extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ChatProvider provider = Provider.of<ChatProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Attendance Checker"),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10.0),
              child: Column(
                children: <Widget>[
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Select Date : ",
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      DropdownButton<String>(
                        value: provider.getSelectedDay,
                        onChanged: (value) {
                          provider.setDay(value);
                        },
                        items: provider.getAllDays.map((day) {
                          return DropdownMenuItem<String>(
                            value: day,
                            child: Text("Date $day"),
                          );
                        }).toList(),
                      ),
                      SizedBox(
                        width: 40.0,
                      ),
                      DropdownButton<String>(
                        value: provider.getSelectedMonth,
                        onChanged: (value) {
                          provider.setMonth(value);
                        },
                        items: provider.getAllMonths.map((month) {
                          return DropdownMenuItem<String>(
                            value: month,
                            child: Text("Month $month"),
                          );
                        }).toList(),
                      ),
                    ],
                  )
                ],
              ),
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
            Expanded(
              child: StreamBuilder(
                stream: Firestore.instance
                    .collection('attendance')
                    .document(provider.getSelectedClass)
                    .collection(provider.getCurrentDate)
                    .where('section', isEqualTo: provider.getSelectedSection)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text("Loading Error Occured..."),
                    );
                  } else if (snapshot.hasData) {
                    return ListView(
                      children:
                          snapshot.data.documents.map((DocumentSnapshot doc) {
                        if (doc.data['isPresent']) {
                          return ListTile(
                            leading: getPhoto(doc.data['profile']),
                            title: Row(
                              children: <Widget>[
                                Icon(
                                  Octicons.primitive_dot,
                                  color: Colors.green,
                                ),
                                Text("${doc.data['name']} (Present)")
                              ],
                            ),
                            subtitle: Text(
                                "ADM ID : ${doc.data['id']}"),
                          );
                        } else if (!doc.data['isPresent']) {
                          return ListTile(
                            leading: getPhoto(doc.data['profile']),
                            title: Row(
                              children: <Widget>[
                                Icon(
                                  Octicons.primitive_dot,
                                  color: Colors.red,
                                ),
                                Text("${doc.data['name']} (Absent)")
                              ],
                            ),
                            subtitle: Text("ADM ID : ${doc.data['id']}"),
                          );
                        }
                      }).toList(),
                    );
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget getPhoto(String url) {
    return CachedNetworkImage(
      imageUrl: url,
      placeholder: (context, str) {
        return CircularProgressIndicator();
      },
      errorWidget: (context, str, event) {
        return CircularProgressIndicator();
      },
      imageBuilder: (context, image) {
        return CircleAvatar(
          backgroundImage: image,
          backgroundColor: Colors.white,
        );
      },
    );
  }
}

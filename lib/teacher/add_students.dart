import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gsasacademy/models/student_model.dart';
import 'package:gsasacademy/providers/chat_provider.dart';
import 'package:gsasacademy/themeConstants.dart';
import 'package:gsasacademy/utils/firebaseutils.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AddRemoveStudents extends StatelessWidget {
  final FirebaseUtils _utils = FirebaseUtils();
  final TextEditingController _nameCont = TextEditingController();
  final TextEditingController _mobileCont = TextEditingController();
  @override
  Widget build(BuildContext context) {
    ChatProvider provider = Provider.of<ChatProvider>(context);
    return Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
              color: Colors.white,
              icon: Icon(Icons.add),
              onPressed: () => showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0)),
                      title: Text("Add New Student"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 10.0, bottom: 0.0, left: 20.0),
                            child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  "Select Class and Section : ",
                                  style: TextStyle(fontSize: 16.0),
                                )),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 40.0),
                            child: Column(
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
                                  width: 15.0,
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
                          TextField(
                            controller: _nameCont,
                            decoration: InputDecoration(
                                hintText: "Enter Student Name",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25.0)),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 15.0)),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          TextField(
                            controller: _mobileCont,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                hintText: "Enter Student Mobile",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25.0)),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 15.0)),
                          ),
                          SizedBox(
                            height: 15.0,
                          ),
                          MaterialButton(
                            minWidth: MediaQuery.of(context).size.width - 50,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0)),
                            color: ThemeConst.primaryColor,
                            onPressed: () {
                              Student _student =
                                  new Student(_nameCont.text, _mobileCont.text);
                              _nameCont.clear();
                              _mobileCont.clear();
                              _utils.addNewStudent(provider, _student, context);
                            },
                            child: Text(
                              "ADD STUDENT",
                              style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            height: 40.0,
                          )
                        ],
                      ),
                    );
                  }),
            )
          ],
          title: Text("Student Panel"),
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
          StreamBuilder(
            stream: Firestore.instance
                .collection(provider.getSelectedClass)
                .where('section', isEqualTo: provider.getSelectedSection)
                .orderBy('name', descending: false)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                default:
                  if (snapshot.data.documents.length == 0) {
                    return Expanded(
                      child: Center(
                        child: Text(
                            "No Students are is class ${provider.getSelectedClass}"),
                      ),
                    );
                  } else {
                    return Expanded(
                      child: ListView(
                        children:
                            snapshot.data.documents.map((DocumentSnapshot doc) {
                          return ListTile(
                              title: Text(doc.data['name']),
                              leading: getPhoto(
                                  doc.data['profileUrl'], doc.data['name']),
                              subtitle: Text(doc.documentID),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  IconButton(
                                    icon: Icon(Icons.call),
                                    onPressed: () =>
                                        launch("tel: +91${doc.documentID}"),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete_forever),
                                    onPressed: () => _utils.removeStudent(
                                        provider, doc.documentID),
                                  ),
                                ],
                              ));
                        }).toList(),
                      ),
                    );
                  }
              }
            },
          )
        ])));
  }

  Widget getPhoto(String url, String name) {
    if (url != null) {
      return CachedNetworkImage(
        imageUrl: url,
        placeholder: (context, str) {
          return CircularProgressIndicator();
        },
        errorWidget: (context, str, event) {
          return CircularProgressIndicator();
        },
        imageBuilder: (context, imageProvider) {
          return CircleAvatar(
            backgroundColor: Colors.white,
            backgroundImage: NetworkImage(url),
          );
        },
      );
    } else {
      return CircleAvatar(
        backgroundColor: ThemeConst.primaryColor,
        child: Center(
          child: Text(
            name.substring(0, 1),
            style: TextStyle(
                fontSize: 18.0,
                color: Colors.white,
                fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }
}

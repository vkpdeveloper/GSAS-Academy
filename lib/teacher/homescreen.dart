import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gsasacademy/providers/chat_provider.dart';
import 'package:gsasacademy/providers/teacher_provider.dart';
import 'package:gsasacademy/themeConstants.dart';
import 'package:gsasacademy/widgets/option_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TeacherHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TeacherProvider teacherProvider = Provider.of<TeacherProvider>(context);
    ChatProvider chatProvider = Provider.of<ChatProvider>(context);

    _showChatOpenerDialog(BuildContext context) {
      return showDialog(
          context: context,
          builder: (context) {
            ChatProvider chatProvider = Provider.of<ChatProvider>(context);
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0)),
              title: Text("Select class and section"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  DropdownButton<String>(
                    elevation: 5,
                    value: chatProvider.getSelectedClass,
                    hint: Text("Select Class"),
                    onChanged: (value) {
                      chatProvider.setClass(value);
                    },
                    items: chatProvider.getAllClasses.map((cls) {
                      if (cls == "Select Class") {
                        return DropdownMenuItem<String>(
                          value: cls,
                          child: Text("$cls"),
                        );
                      } else {
                        return DropdownMenuItem<String>(
                          value: cls,
                          child: Text("Class $cls"),
                        );
                      }
                    }).toList(),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  DropdownButton<String>(
                    elevation: 5,
                    value: chatProvider.getSelectedSection,
                    hint: Text("Select Section"),
                    onChanged: (value) {
                      chatProvider.setSection(value);
                    },
                    items: chatProvider.getAllSection.map((sec) {
                      return DropdownMenuItem<String>(
                        value: sec,
                        child: Text("Section $sec"),
                      );
                    }).toList(),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  MaterialButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      FirebaseMessaging().subscribeToTopic(
                          '${chatProvider.getSelectedClass}_${chatProvider.getSelectedSection}_teacher');
                      Navigator.pushNamed(context, '/chatteacher');
                    },
                    color: ThemeConst.primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0)),
                    child: Text(
                      "Start Chat",
                      style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            );
          });
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          FirebaseAuth.instance.signOut();
          SharedPreferences _prefs = await SharedPreferences.getInstance();
          _prefs.clear();
          Fluttertoast.showToast(msg: "Logout Success");
          Navigator.pushNamed(context, '/loginscreen');
        },
        tooltip: "LOG OUT",
        child: Icon(FontAwesome.sign_out),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomRight,
                  colors: [ThemeConst.primaryColor, Colors.white])),
          child: Padding(
            padding: const EdgeInsets.only(
                left: 15.0, right: 15.0, top: 40.0, bottom: 0.0),
            child: Column(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Welcome, ${teacherProvider.getTeacherName}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                              color: Colors.white),
                        ),
                        CachedNetworkImage(
                          placeholder: (context, str) {
                            return CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            );
                          },
                          errorWidget: (context, str, event) {
                            return CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            );
                          },
                          imageUrl: teacherProvider.getTeacherProfile,
                          imageBuilder: (context, provider) {
                            return CircleAvatar(
                              backgroundColor: ThemeConst.primaryColor,
                              backgroundImage: provider,
                              radius: 25.0,
                            );
                          },
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                  ],
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(top: 8.0, right: 15.0, left: 15.0),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          OptionWidget(
                            onPressed: () => Navigator.pushNamed(
                                context, '/attendanceChecker'),
                            label: "Attendance",
                            optionImage: AssetImage('asset/images/shift.png'),
                          ),
                          OptionWidget(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/addHomework'),
                            label: "Homework",
                            optionImage: AssetImage('asset/images/book.png'),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          OptionWidget(
                            onPressed: () => Navigator.pushNamed(
                                context, '/teacherVideoUploader'),
                            label: "Class",
                            optionImage: AssetImage('asset/images/video.png'),
                          ),
                          OptionWidget(
                            onPressed: () => _showChatOpenerDialog(context),
                            label: "Chat",
                            optionImage:
                                AssetImage('asset/images/communication.png'),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          OptionWidget(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/teacherGallery'),
                            label: "Gallery",
                            optionImage: AssetImage('asset/images/gallery.png'),
                          ),
                          OptionWidget(
                            onPressed: () => Navigator.pushNamed(
                                context, '/addRemoveStudent'),
                            label: "Students",
                            optionImage: AssetImage('asset/images/test.png'),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

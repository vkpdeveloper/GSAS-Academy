import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gsasacademy/providers/student_provider.dart';
import 'package:gsasacademy/student/homework_screen.dart';
import 'package:gsasacademy/student/onlineclass_video.dart';
import 'package:gsasacademy/themeConstants.dart';
import 'package:gsasacademy/utils/firebaseutils.dart';
import 'package:gsasacademy/widgets/option_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatelessWidget {
  FirebaseUtils _utils = FirebaseUtils();

  _showHolidayPage(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)),
            title: Text("Holiday"),
            content: Text(
              "Dear Student, today is holiday and there is no any homeworks and online classes today so you can practice on your yesterday homeworks.",
              style: TextStyle(fontSize: 16.0),
              textAlign: TextAlign.center,
            ),
          );
        });
  }

  Widget build(BuildContext context) {
    StudentProvider _studentProvider = Provider.of<StudentProvider>(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomRight,
                    colors: [ThemeConst.primaryColor, Colors.white])),
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 50.0, left: 20.0, right: 20.0, bottom: 10.0),
              child: Column(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            "Dashboard",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                                color: Colors.white),
                          ),
                          FlatButton(
                            onPressed: () async {
                              FirebaseAuth.instance.signOut();
                              SharedPreferences _prefs =
                                  await SharedPreferences.getInstance();
                              _prefs.clear();
                              Fluttertoast.showToast(msg: "Logout Success");
                              Navigator.pushNamed(context, '/loginscreen');
                            },
                            child: Text(
                              "Logout",
                              style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 10.0, left: 10, right: 10.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width - 40,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25.0),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                    blurRadius: 14,
                                    color: Colors.black12.withOpacity(0.1),
                                    offset: Offset(10, 10)),
                                BoxShadow(
                                    blurRadius: 14,
                                    color: Colors.black12.withOpacity(0.1),
                                    offset: Offset(-10, -10))
                              ]),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: CachedNetworkImage(
                                    placeholder: (context, str) {
                                      return CircularProgressIndicator();
                                    },
                                    errorWidget: (context, str, event) {
                                      return CircularProgressIndicator();
                                    },
                                    imageUrl:
                                        _studentProvider.getStudentProfile,
                                    imageBuilder: (context, provider) {
                                      return CircleAvatar(
                                        backgroundColor: Colors.white,
                                        backgroundImage: provider,
                                        radius: 40.0,
                                      );
                                    },
                                  )),
                              SizedBox(
                                height: 15.0,
                              ),
                              Text(
                                "Vaibhav Pathak",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 5.0,
                              ),
                              Text(
                                "Class ${_studentProvider.getStudentClass} (${_studentProvider.getStudentSection})",
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        top: 20.0, right: 15.0, left: 15.0, bottom: 20.0),
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            OptionWidget(
                              label: _studentProvider.getPresentStatus,
                              onPressed: () => _studentProvider.setPresent(),
                              optionImage: AssetImage('asset/images/shift.png'),
                            ),
                            OptionWidget(
                              label: "Homework",
                              onPressed: () => _studentProvider.isSunday
                                  ? _showHolidayPage(context)
                                  : Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => HomeworkStudent(
                                                studentClass: _studentProvider
                                                    .getStudentClass,
                                              ))),
                              optionImage: AssetImage('asset/images/book.png'),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            OptionWidget(
                              label: "Classes",
                              onPressed: () {
                                _studentProvider.isSunday
                                    ? _showHolidayPage(context)
                                    : Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                StudentOnlineClass(
                                                  studentClass: _studentProvider
                                                      .getStudentClass,
                                                )));
                              },
                              optionImage: AssetImage('asset/images/video.png'),
                            ),
                            OptionWidget(
                              label: "Chat",
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/studentChat'),
                              optionImage:
                                  AssetImage('asset/images/communication.png'),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            OptionWidget(
                              label: "Gallery",
                              onPressed: () => Navigator.pushNamed(
                                  context, '/studentgallery'),
                              optionImage:
                                  AssetImage('asset/images/gallery.png'),
                            ),
                            OptionWidget(
                              label: "Developer",
                              onPressed: () => launch("tel: +918318045008"),
                              profileImage: CachedNetworkImage(
                                placeholder: (context, str) {
                                  return CircularProgressIndicator();
                                },
                                errorWidget: (context, str, event) {
                                  return CircularProgressIndicator();
                                },
                                imageUrl:
                                    "https://vaibhavpathakofficial.tk/img/vaibhav.png",
                                imageBuilder: (context, provider) {
                                  return CircleAvatar(
                                    backgroundColor: Colors.white,
                                    backgroundImage: provider,
                                    radius: 45.0,
                                  );
                                },
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text(
                          "Developer Vaibhav Pathak",
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

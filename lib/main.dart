import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:gsasacademy/providers/chat_provider.dart';
import 'package:gsasacademy/providers/homework_provider.dart';
import 'package:gsasacademy/providers/image_provider.dart';
import 'package:gsasacademy/providers/student_provider.dart';
import 'package:gsasacademy/providers/teacher_provider.dart';
import 'package:gsasacademy/teacher/add_homework.dart';
import 'package:gsasacademy/student/chatscreen.dart';
import 'package:gsasacademy/student/student_gallery.dart';
import 'package:gsasacademy/teacher/add_students.dart';
import 'package:gsasacademy/teacher/chatscreen_teacher.dart';
import 'package:gsasacademy/teacher/homescreen.dart';
import 'package:gsasacademy/teacher/homework_checker.dart';
import 'package:gsasacademy/teacher/student_attendance.dart';
import 'package:gsasacademy/teacher/teacher_gallery.dart';
import 'package:gsasacademy/teacher/video_uploaded_teacher.dart';
import 'package:gsasacademy/themeConstants.dart';
import 'package:gsasacademy/utils/firebaseutils.dart';
import 'package:gsasacademy/views/homepage.dart';
import 'package:gsasacademy/views/loginpage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (BuildContext context) => StudentProvider(),
        ),
        ChangeNotifierProvider(
          create: (BuildContext context) => ImageUploadProvider(),
        ),
        ChangeNotifierProvider(
          create: (BuildContext context) => HomeworkProvider(),
        ),
        ChangeNotifierProvider(
          create: (BuildContext context) => TeacherProvider(),
        ),
        ChangeNotifierProvider(
          create: (BuildContext context) => ChatProvider(),
        ),
      ],
      child: MaterialApp(
        initialRoute: '/',
        routes: {
          '/homescreen': (context) => HomeScreen(),
          '/loginscreen': (context) => LoginScreen(),
          '/hometeacher': (context) => TeacherHome(),
          '/studentChat': (context) => ChatScreen(),
          '/studentgallery': (context) => StudentGallery(),
          '/chatteacher': (context) => ChatScreenTeacher(),
          '/attendanceChecker': (context) => StudentAttendance(),
          '/addHomework': (context) => AddHomework(),
          '/teacherVideoUploader': (context) => TeacherVideoUploader(),
          '/teacherGallery': (context) => TeacherGallery(),
          '/homeworkChecker': (context) => HomeworkChecker(),
          '/addRemoveStudent': (context) => AddRemoveStudents()
        },
        debugShowCheckedModeBanner: false,
        title: 'GSAS Academy',
        theme: ThemeData(
            fontFamily: "Open Sans",
            primaryColor: ThemeConst.primaryColor,
            accentColor: ThemeConst.primaryColor),
        home: SplashScreen(),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  FirebaseUtils _firebaseUtils = FirebaseUtils();
  FirebaseMessaging _messaging = FirebaseMessaging();
  bool isNoInternet = false;

  @override
  void initState() {
    super.initState();
    checkInternetAndRedirect();
    _messaging.configure(onMessage: (data) {
      print(data);
    });
  }

  checkInternetAndRedirect() async {
    Connectivity _conn = Connectivity();
    ConnectivityResult result = await _conn.checkConnectivity();
    if (result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi) {
      Timer(Duration(seconds: 3), () async {
        if (await _firebaseUtils.isLogged()) {
          SharedPreferences _pref = await SharedPreferences.getInstance();
          if (_pref.getBool('isStudent') != null) {
            if (_pref.getBool('isStudent')) {
              FirebaseMessaging().subscribeToTopic(
                  '${_pref.getString('class')}_${_pref.getString('section')}');
              FirebaseMessaging().subscribeToTopic(
                  '${_pref.getString('class')}_${_pref.getString('section')}_study');
              Navigator.pushReplacementNamed(context, '/homescreen');
            } else {
              FirebaseMessaging().subscribeToTopic('teacher');
              Navigator.pushReplacementNamed(context, '/hometeacher');
            }
          } else {
            Navigator.pushReplacementNamed(context, '/loginscreen');
          }
        } else {
          Navigator.pushReplacementNamed(context, '/loginscreen');
        }
      });
    } else {
      setState(() {
        isNoInternet = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(color: ThemeConst.primaryColor),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "GSAS Academy",
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontSize: 28.0),
            ),
            SizedBox(
              height: 20.0,
            ),
            isNoInternet
                ? Text(
                    "NO INTERNET !",
                    style: TextStyle(fontSize: 16.0, color: Colors.white),
                  )
                : CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
          ],
        ),
      ),
    );
  }
}

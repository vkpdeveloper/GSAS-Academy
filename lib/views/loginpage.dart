import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gsasacademy/themeConstants.dart';
import 'package:gsasacademy/utils/firebaseutils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isTeacherLogger = false;
  bool isStudentLogger = true;
  bool isProfileUploaded = false;
  ProgressDialog progressDialog;
  List<String> classes = ["Select Class", "9th", "10th", "11th", "12th"];
  String selectedClass = "Select Class";
  File pickedImage;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _admController = TextEditingController();
  TextEditingController _mobileController = TextEditingController();
  TextEditingController _nameTeacher = TextEditingController();
  TextEditingController _mobileTeacher = TextEditingController();
  TextEditingController _otpController = TextEditingController();
  String verID;
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  bool isCodeSent = false;
  AuthCredential _authCredential;
  FirebaseUtils _firebaseUtils = FirebaseUtils();
  StorageReference _storageReference;
  GlobalKey _scaffold = GlobalKey();
  String selectedSection = "Select Section";
  List sections = ["Select Section", "A", "B", "C", "D"];
  String firebaseToken;

  getFirebaseToken() async {
    String token = await FirebaseMessaging().getToken();
    setState(() {
      firebaseToken = token;
    });
  }

  @override
  void initState() {
    super.initState();
    getFirebaseToken();
  }

  void signInWithPhoneNumber(String smsCode, String verID, BuildContext context,
      bool isStudent) async {
    _authCredential = PhoneAuthProvider.getCredential(
        verificationId: verID, smsCode: smsCode);
    _firebaseAuth.signInWithCredential(_authCredential).catchError((error) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Verification failed !");
    }).then((data) {
      Navigator.pop(context);
      progressDialog.show();
      if (isStudent) {
        _firebaseUtils.uploadImage(pickedImage, selectedClass).then((url) {
          if (url != null) {
            _firebaseUtils.saveStudentData(
                _nameController.text,
                selectedClass,
                _mobileController.text,
                _admController.text,
                url,
                selectedSection,
                firebaseToken,
                _scaffold.currentContext, progressDialog);
            progressDialog.dismiss();
          } else {
            progressDialog.dismiss();
            Fluttertoast.showToast(msg: "Verification Unsuccessful");
          }
        });
      } else {
        _firebaseUtils.uploadImageTeacher(pickedImage).then((url) {
          if (url != null) {
            _firebaseUtils.saveTeacherData(
                _nameTeacher.text, _mobileTeacher.text, url, firebaseToken, progressDialog, _scaffold.currentContext);
          } else {
            progressDialog.dismiss();
            Fluttertoast.showToast(msg: "Verification Unsuccessful");
          }
        });
      }
    });
  }

  _showOTPVerifier(BuildContext context, bool isStudent) {
    if (isStudent) {
      verifyPhoneNumber(_mobileController.text, true, context);
    } else {
      verifyPhoneNumber(_mobileTeacher.text, false, context);
    }
    progressDialog = ProgressDialog(context,
        isDismissible: false, type: ProgressDialogType.Normal);
    progressDialog.style(
      backgroundColor: Colors.white,
      borderRadius: 25.0,
      elevation: 8.0,
      insetAnimCurve: Curves.bounceIn,
      message: "Uploading data...",
    );
    BuildContext cxt = context;
    return showDialog(
        context: cxt,
        barrierDismissible: false,
        builder: (cxt) {
          return StatefulBuilder(
            builder: (context, _setState) {
              return WillPopScope(
                onWillPop: () {},
                child: AlertDialog(
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Close",
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                    FlatButton(
                      onPressed: () {
                        if (_otpController.text.length == 6) {
                          if (isStudent) {
                            signInWithPhoneNumber(
                                _otpController.text, verID, context, true);
                          } else {
                            signInWithPhoneNumber(
                                _otpController.text, verID, context, false);
                          }
                        } else {
                          Fluttertoast.showToast(msg: "Wrong OTP");
                        }
                      },
                      child: Text(
                        "Done",
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ],
                  elevation: 8.0,
                  contentPadding: const EdgeInsets.all(20.0),
                  titlePadding: const EdgeInsets.only(
                      left: 20.0, right: 20.0, top: 20.0, bottom: 0.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0)),
                  title: Text("Enter OTP"),
                  content: TextField(
                    controller: _otpController,
                    decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 8.0),
                        prefixIcon: Icon(Icons.lock),
                        hintText: "Enter One Time Password",
                        labelText: "One Time Password",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(35.0))),
                  ),
                ),
              );
            },
          );
        });
  }

  verifyPhoneNumber(String mobile, bool isStudent, BuildContext context) async {
    try {
      PhoneVerificationCompleted _verificationDone =
          (AuthCredential credential) {
        _firebaseAuth.signInWithCredential(credential).then(((user) async {
          Navigator.pop(context);
          progressDialog.show();
          if (isStudent) {
            _firebaseUtils
                .uploadImage(pickedImage, selectedClass)
                .then((url) async {
              if (url != null) {
                _firebaseUtils.saveStudentData(
                    _nameController.text,
                    selectedClass,
                    _mobileController.text,
                    _admController.text,
                    url,
                    selectedSection,
                    firebaseToken,
                    _scaffold.currentContext, progressDialog);
              } else {
                progressDialog.dismiss();
                Fluttertoast.showToast(msg: "Verification Unsuccessful");
              }
            });
          } else {
            _firebaseUtils.uploadImageTeacher(pickedImage).then((url) {
              if (url != null) {
                _firebaseUtils.saveTeacherData(
                    _nameTeacher.text, _mobileTeacher.text, url, firebaseToken, progressDialog, _scaffold.currentContext);
              } else {
                progressDialog.dismiss();
                Fluttertoast.showToast(msg: "Verification Unsuccessful");
              }
            });
          }
        })).catchError((e) {
          Fluttertoast.showToast(msg: "Verification Unsuccessful");
        });
      };

      PhoneCodeSent _codeSend =
          (String verificationId, [int forceResendingToken]) {
        setState(() {
          verID = verificationId;
        });
        Fluttertoast.showToast(
          msg: "OTP sent successfully",
        );
      };

      PhoneVerificationFailed _verficationFailed = (AuthException exception) {
        print(exception.message);
        Fluttertoast.showToast(
          msg: "Error Occured !",
        );
      };

      PhoneCodeAutoRetrievalTimeout _codeTimeout = (verificationId) {
        setState(() {
          verID = verificationId;
        });
        Fluttertoast.showToast(msg: "Code timeout !");
      };
      _firebaseAuth.verifyPhoneNumber(
          phoneNumber: "+91$mobile",
          timeout: Duration(seconds: 60),
          verificationCompleted: _verificationDone,
          verificationFailed: _verficationFailed,
          codeSent: _codeSend,
          codeAutoRetrievalTimeout: _codeTimeout);
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffold,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 60.0, vertical: 40.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isStudentLogger = true;
                          isTeacherLogger = false;
                        });
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 400),
                        child: Column(
                          children: <Widget>[
                            Text(
                              "Student",
                              style: TextStyle(
                                  fontSize: isStudentLogger ? 16 : 18,
                                  fontWeight: FontWeight.bold,
                                  color: isStudentLogger
                                      ? ThemeConst.primaryColor
                                      : Colors.black54),
                            ),
                            if (isStudentLogger)
                              Container(
                                height: 5.0,
                                width: 80,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(35.0),
                                    color: ThemeConst.primaryColor),
                              )
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isStudentLogger = false;
                          isTeacherLogger = true;
                        });
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 400),
                        child: Column(
                          children: <Widget>[
                            Text(
                              "Teacher",
                              style: TextStyle(
                                  fontSize: isTeacherLogger ? 16 : 18,
                                  fontWeight: FontWeight.bold,
                                  color: isTeacherLogger
                                      ? ThemeConst.primaryColor
                                      : Colors.black54),
                            ),
                            if (isTeacherLogger)
                              Container(
                                height: 5.0,
                                width: 80,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(35.0),
                                    color: ThemeConst.primaryColor),
                              )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isStudentLogger) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      'asset/images/backschool.png',
                      height: 200.0,
                      fit: BoxFit.fitWidth,
                    ),
                    Text(
                      "Welcome Student !",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54),
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                    if (isProfileUploaded)
                      GestureDetector(
                        onTap: () async {
                          File picker = await ImagePicker.pickImage(
                              source: ImageSource.gallery, imageQuality: 50);
                          if (picker != null) {
                            setState(() {
                              pickedImage = picker;
                              isProfileUploaded = true;
                            });
                          } else {
                            setState(() {
                              isProfileUploaded = false;
                            });
                          }
                        },
                        child: CircleAvatar(
                          minRadius: 50.0,
                          maxRadius: 50.0,
                          backgroundColor: ThemeConst.primaryColor,
                          backgroundImage: FileImage(pickedImage),
                        ),
                      ),
                    if (!isProfileUploaded)
                      GestureDetector(
                        onTap: () async {
                          File picker = await ImagePicker.pickImage(
                              source: ImageSource.gallery, imageQuality: 50);
                          if (picker != null) {
                            setState(() {
                              pickedImage = picker;
                              isProfileUploaded = true;
                            });
                          } else {
                            setState(() {
                              isProfileUploaded = false;
                            });
                          }
                        },
                        child: CircleAvatar(
                          backgroundColor: ThemeConst.primaryColor,
                          maxRadius: 50.0,
                          minRadius: 50.0,
                          child: Icon(
                            Icons.add_a_photo,
                            color: Colors.white,
                            size: 35.0,
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(
                          right: 30.0, left: 30.0, top: 15.0),
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              DropdownButton<String>(
                                onChanged: (value) {
                                  setState(() {
                                    selectedClass = value;
                                  });
                                },
                                value: selectedClass,
                                items: classes.map((cls) {
                                  if (cls == "Select Class") {
                                    return DropdownMenuItem<String>(
                                      child: Text(cls),
                                      value: cls,
                                    );
                                  } else {
                                    return DropdownMenuItem<String>(
                                      child: Text("Class $cls"),
                                      value: cls,
                                    );
                                  }
                                }).toList(),
                              ),
                              DropdownButton<String>(
                                onChanged: (value) {
                                  setState(() {
                                    selectedSection = value;
                                  });
                                },
                                value: selectedSection,
                                items: sections.map((sec) {
                                  if (sec == "Select Section") {
                                    return DropdownMenuItem<String>(
                                      child: Text(sec),
                                      value: sec,
                                    );
                                  } else {
                                    return DropdownMenuItem<String>(
                                      child: Text("$sec"),
                                      value: sec,
                                    );
                                  }
                                }).toList(),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 5.0),
                                prefixIcon: Icon(Icons.person),
                                hintText: "Enter Name",
                                labelText: "Name",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(35.0))),
                          ),
                          SizedBox(
                            height: 15.0,
                          ),
                          TextField(
                            controller: _admController,
                            decoration: InputDecoration(
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 5.0),
                                prefixIcon: Icon(Icons.lock),
                                hintText: "eg. GSASAC/00000",
                                labelText: "Admission ID",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(35.0))),
                          ),
                          SizedBox(
                            height: 15.0,
                          ),
                          TextField(
                            controller: _mobileController,
                            keyboardType: TextInputType.number,
                            maxLength: 10,
                            decoration: InputDecoration(
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 5.0),
                                prefixIcon: Icon(Icons.dialpad),
                                hintText: "Enter Mobile Number",
                                labelText: "Mobile Number",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(35.0))),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          MaterialButton(
                            height: 40.0,
                            color: ThemeConst.primaryColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(35.0)),
                            onPressed: () {
                              progressDialog = ProgressDialog(context,
                                  isDismissible: false,
                                  type: ProgressDialogType.Normal);
                              progressDialog.style(
                                backgroundColor: Colors.white,
                                borderRadius: 25.0,
                                elevation: 8.0,
                                insetAnimCurve: Curves.bounceIn,
                                message: "Uploading data...",
                              );
                              if (_nameController.text != "" &&
                                  _mobileController.text.length == 10 &&
                                  _admController.text != "") {
                                if (_admController.text.contains("GSASAC/")) {
                                  if (selectedClass != "Select Class") {
                                    if (selectedSection != "Select Section") {
                                      if (pickedImage != null) {
                                        _showOTPVerifier(context, true);
                                      } else {
                                        Fluttertoast.showToast(
                                            msg: "Pick your profile photo");
                                      }
                                    } else {
                                      Fluttertoast.showToast(
                                          msg: "Select a section");
                                    }
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: "Select a class");
                                  }
                                } else {
                                  Fluttertoast.showToast(
                                      msg: "Wrong Admission ID");
                                }
                              } else {
                                Fluttertoast.showToast(
                                    msg: "Some fields are blank !");
                              }
                            },
                            minWidth: MediaQuery.of(context).size.width - 30,
                            child: Text(
                              "Login",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 18.0),
                            ),
                          ),
                          SizedBox(
                            height: 20.0,
                          )
                        ],
                      ),
                    )
                  ],
                )
              ],
              if (isTeacherLogger) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      'asset/images/teacher.png',
                      height: 200.0,
                      fit: BoxFit.fitWidth,
                    ),
                    Text(
                      "Welcome Teacher !",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54),
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                    if (isProfileUploaded)
                      GestureDetector(
                        onTap: () async {
                          File picker = await ImagePicker.pickImage(
                              source: ImageSource.gallery);
                          if (picker != null) {
                            setState(() {
                              pickedImage = picker;
                              isProfileUploaded = true;
                            });
                          } else {
                            setState(() {
                              isProfileUploaded = false;
                            });
                          }
                        },
                        child: CircleAvatar(
                          minRadius: 50.0,
                          maxRadius: 50.0,
                          backgroundColor: ThemeConst.primaryColor,
                          backgroundImage: FileImage(pickedImage),
                        ),
                      ),
                    if (!isProfileUploaded)
                      GestureDetector(
                        onTap: () async {
                          File picker = await ImagePicker.pickImage(
                              source: ImageSource.gallery, imageQuality: 50);
                          if (picker != null) {
                            setState(() {
                              pickedImage = picker;
                              isProfileUploaded = true;
                            });
                          } else {
                            setState(() {
                              isProfileUploaded = false;
                            });
                          }
                        },
                        child: CircleAvatar(
                          backgroundColor: ThemeConst.primaryColor,
                          maxRadius: 50.0,
                          minRadius: 50.0,
                          child: Icon(
                            Icons.add_a_photo,
                            color: Colors.white,
                            size: 35.0,
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(
                          right: 30.0, left: 30.0, top: 15.0),
                      child: Column(
                        children: <Widget>[
                          TextField(
                            controller: _nameTeacher,
                            decoration: InputDecoration(
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 5.0),
                                prefixIcon: Icon(Icons.person),
                                hintText: "Enter Name",
                                labelText: "Name",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(35.0))),
                          ),
                          SizedBox(
                            height: 15.0,
                          ),
                          TextField(
                            controller: _mobileTeacher,
                            keyboardType: TextInputType.number,
                            maxLength: 10,
                            decoration: InputDecoration(
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 5.0),
                                prefixIcon: Icon(Icons.dialpad),
                                hintText: "Enter Mobile Number",
                                labelText: "Mobile Number",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(35.0))),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          MaterialButton(
                            height: 40.0,
                            color: ThemeConst.primaryColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(35.0)),
                            onPressed: () {
                              if (_nameTeacher.text.trim() != "" &&
                                  _mobileTeacher.text.length == 10) {
                                if (pickedImage != null) {
                                  _showOTPVerifier(context, false);
                                } else {
                                  Fluttertoast.showToast(
                                      msg: "Pick your profile photo");
                                }
                              } else {
                                Fluttertoast.showToast(
                                    msg: "Blank fields detected !");
                              }
                            },
                            minWidth: MediaQuery.of(context).size.width - 30,
                            child: Text(
                              "Login",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 18.0),
                            ),
                          ),
                          SizedBox(
                            height: 20.0,
                          )
                        ],
                      ),
                    )
                  ],
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}

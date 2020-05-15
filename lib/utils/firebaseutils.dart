import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gsasacademy/models/student_model.dart';
import 'package:gsasacademy/providers/chat_provider.dart';
import 'package:gsasacademy/providers/homework_provider.dart';
import 'package:gsasacademy/providers/image_provider.dart';
import 'package:gsasacademy/providers/student_provider.dart';
import 'package:gsasacademy/providers/teacher_provider.dart';
import 'package:path/path.dart' as path;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart';

class FirebaseUtils {
  var _firestoreStudent = Firestore.instance;
  var _firestoreTeacher = Firestore.instance.collection('teacher');
  AuthCredential _authCredential;
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  StorageReference _storageReference;
  Firestore _firestore = Firestore.instance;

  saveStudentData(
      String name,
      String className,
      String mobile,
      String admID,
      String profileUrl,
      String section,
      String token,
      BuildContext context,
      ProgressDialog progressDialog) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _firestore.collection(className).document(mobile).get().then((data) {
      if (data.exists) {
        _prefs.setString("name", data.data['name']);
        _prefs.setString("class", className);
        _prefs.setString("mobile", mobile);
        _prefs.setString("admID", admID);
        _prefs.setString("profile", profileUrl);
        _prefs.setString("section", section);
        _prefs.setBool("isStudent", true);
        _firestoreStudent.collection(className).document(mobile).setData({
          "profileUrl": profileUrl,
          "admId": admID,
          "token": token
        }, merge: true);
        Fluttertoast.showToast(msg: "Login Successful");
        Navigator.pushReplacementNamed(context, '/homescreen');
      } else {
        progressDialog.dismiss();
        Fluttertoast.showToast(msg: "Student is not registered with us.");
      }
    });
  }

  saveTeacherData(String name, String mobile, String profileUrl, String token,
      ProgressDialog progressDialog, BuildContext context) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _firestore.collection('teacher').document(mobile).get().then((data) {
      if (data.exists) {
        _prefs.setString("name", data.data['name']);
        _prefs.setString("mobile", mobile);
        _prefs.setString("profile", profileUrl);
        _prefs.setBool("isStudent", false);
        _firestoreTeacher.document(mobile).setData({
          "profileUrl": profileUrl,
          "token": token
        }, merge: true);
        progressDialog.dismiss();
        Navigator.pushReplacementNamed(context, '/hometeacher');
        Fluttertoast.showToast(msg: "Verification Successful");
      }else{
        progressDialog.dismiss();
        Fluttertoast.showToast(msg: "Teacher is not registered with us.");
      }
    });
  }

  Future<String> uploadImage(File imageFile, String className) async {
    try {
      _storageReference = FirebaseStorage.instance
          .ref()
          .child("$className/${path.basename(imageFile.path)}");
      StorageUploadTask _storageUploadTask =
          _storageReference.putFile(imageFile);
      String url =
          await (await _storageUploadTask.onComplete).ref.getDownloadURL();
      return url;
    } catch (e) {
      return null;
    }
  }

  Future<String> uploadImageTeacher(File imageFile) async {
    try {
      _storageReference = FirebaseStorage.instance
          .ref()
          .child("teacher/${path.basename(imageFile.path)}");
      StorageUploadTask _storageUploadTask =
          _storageReference.putFile(imageFile);
      String url =
          await (await _storageUploadTask.onComplete).ref.getDownloadURL();
      return url;
    } catch (e) {
      return null;
    }
  }

  Future<bool> isLogged() async {
    try {
      final FirebaseUser user = await _firebaseAuth.currentUser();
      return user != null;
    } catch (e) {
      return false;
    }
  }

  sendTextMessage(String message, String by, String id, String className,
      String section, String name) async {
    _firestore.collection('chat').document(className).collection(section).add({
      "message": message,
      "by": by,
      "type": "text",
      "id": id,
      "name": name,
      "timestamp": Timestamp.now()
    }); 
    String topic = "${className}_$section";
    Response res = await get(
        'https://arcane-tor-25475.herokuapp.com/send?topic=$topic&title=$name&msg=$message');
    topic = "${className}_${section}_teacher";
    res = await get(
        'https://arcane-tor-25475.herokuapp.com/send?topic=$topic&title=$name ($className Section: $section) &msg=$message');
  }

  Future<List> uploadImagetoStorage(File imageFile) async {
    List fileData = [];
    String fileName = DateTime.now().microsecondsSinceEpoch.toString();
    StorageReference reference =
        FirebaseStorage.instance.ref().child("chat/$fileName");
    StorageUploadTask uploadTask = reference.putFile(imageFile);
    fileData.add(fileName);
    String url = await (await uploadTask.onComplete).ref.getDownloadURL();
    fileData.add(url);
    return fileData;
  }

  sendImageMessage(List data, String className, String section, String by,
      String name, String id) async {
    _firestore.collection('chat').document(className).collection(section).add({
      "message": data[1],
      "fileName": data[0],
      "by": by,
      "type": "image",
      "id": id,
      "name": name,
      "timestamp": Timestamp.now()
    });
    String topic = "${className}_$section";
    Response res = await get(
        'https://arcane-tor-25475.herokuapp.com/send?topic=$topic&title=$name&msg=Photo');
    topic = "${className}_${section}_teacher";
    res = await get(
        'https://arcane-tor-25475.herokuapp.com/send?topic=$topic&title=$name ($className Section: $section) &msg=Photo');
  }

  void uploadImageWithProvider(
      File image,
      ImageUploadProvider imageUploadProvider,
      StudentProvider studentProvider) async {
    imageUploadProvider.setToLoading();
    List uploadedData = await uploadImagetoStorage(image);
    sendImageMessage(
        uploadedData,
        studentProvider.getStudentClass,
        studentProvider.getStudentSection,
        "student",
        studentProvider.getStudentName,
        studentProvider.getStudentID);
    imageUploadProvider.setToIdle();
  }

  void deleteMessage(
      StudentProvider studentProvider, String docID, BuildContext context) {
    _firestore
        .collection('chat')
        .document(studentProvider.getStudentClass)
        .collection(studentProvider.getStudentSection)
        .document(docID)
        .delete();
    Navigator.pop(context);
    Fluttertoast.showToast(msg: "Message Deleted");
  }

  void editMessage(
      StudentProvider studentProvider, String docID, String newMessage) {
    _firestore
        .collection('chat')
        .document(studentProvider.getStudentClass)
        .collection(studentProvider.getStudentSection)
        .document(docID)
        .updateData({"message": newMessage});
  }

  Future<String> uploadHomeworkToStorage(File imageFile) async {
    String fileName = DateTime.now().microsecondsSinceEpoch.toString();
    StorageReference reference =
        FirebaseStorage.instance.ref().child("homework/$fileName");
    StorageUploadTask uploadTask = reference.putFile(imageFile);
    String url = await (await uploadTask.onComplete).ref.getDownloadURL();
    return url;
  }

  submitHomework(StudentProvider studentProvider, File homeworkFile,
      HomeworkProvider homeworkProvider, String subject) async {
    homeworkProvider.setToLoading();
    String url = await uploadHomeworkToStorage(homeworkFile);
    homeworkProvider.setToIdle();
    homeworkProvider.isHomeworkDoneof(studentProvider, subject);
    setHomeworkToFirestore(studentProvider, url, subject);
  }

  setHomeworkToFirestore(
      StudentProvider studentProvider, String url, String subject) {
    _firestore
        .collection('submittedHomework')
        .document(studentProvider.getStudentClass)
        .collection(studentProvider.getStudentSection)
        .document(studentProvider.getTodayDate)
        .collection(subject)
        .document(studentProvider.getStudentID)
        .setData({
      "homework": url,
      "isCorrect": false,
      "name": studentProvider.getStudentName,
      "id": studentProvider.getStudentMobile,
      "isChecked": false
    }, merge: true);
  }

  delectChatMesasgeTeacher(TeacherProvider teacherProvider, String docID,
      BuildContext context, ChatProvider chatProvider, String fileName) {
    if (fileName != null) {
      FirebaseStorage.instance.ref().child('chat/$fileName').delete();
    }
    _firestore
        .collection('chat')
        .document(chatProvider.getSelectedClass)
        .collection(chatProvider.getSelectedSection)
        .document(docID)
        .delete();
    Navigator.pop(context);
    Fluttertoast.showToast(msg: "Message Deleted");
  }

  sendAsTeacherMessage(ChatProvider chatProvider,
      TeacherProvider teacherProvider, String message) async {
    _firestore
        .collection("chat")
        .document(chatProvider.getSelectedClass)
        .collection(chatProvider.getSelectedSection)
        .add({
      "by": "teacher",
      "id": teacherProvider.getTeacherID,
      "message": message,
      "type": "text",
      "timestamp": Timestamp.now(),
      "name": teacherProvider.getTeacherName
    });
    String topic =
        "${chatProvider.getSelectedClass}_${chatProvider.getSelectedSection}";
    await get(
        'https://arcane-tor-25475.herokuapp.com/send?topic=$topic&title=${teacherProvider.getTeacherName}, Sir&msg=$message');
    topic =
        "${chatProvider.getSelectedClass}_${chatProvider.getSelectedSection}_teacher";
    await get(
        'https://arcane-tor-25475.herokuapp.com/send?topic=$topic&title=${teacherProvider.getTeacherName}, Sir (${chatProvider.getSelectedClass} Section: ${chatProvider.getSelectedSection}) &msg=$message');
  }

  deleteStudentMessageByTeacher(
      ChatProvider chatProvider, String docID, BuildContext context) {
    _firestore
        .collection("chat")
        .document(chatProvider.getSelectedClass)
        .collection(chatProvider.getSelectedSection)
        .document(docID)
        .delete();
    Navigator.pop(context);
    Fluttertoast.showToast(msg: "Message Deleted");
  }

  editStudentMessageByTeacher(ImageUploadProvider imageUploadProvider,
      ChatProvider chatProvider, String newMessage) {
    _firestore
        .collection("chat")
        .document(chatProvider.getSelectedClass)
        .collection(chatProvider.getSelectedSection)
        .document(imageUploadProvider.getDocID)
        .updateData({"message": newMessage});
  }

  sendImageMessageByTeacher(
      ChatProvider chatProvider, List data, TeacherProvider teacherProvider) async {
    _firestore
        .collection('chat')
        .document(chatProvider.getSelectedClass)
        .collection(chatProvider.getSelectedSection)
        .add({
      "by": "teacher",
      "message": data[1],
      "fileName": data[0],
      "type": "image",
      "timestamp": Timestamp.now(),
      "name": teacherProvider.getTeacherName,
      "id": teacherProvider.getTeacherID
    });
  }

  sendImageMessageAsTeacher(
      ChatProvider chatProvider,
      ImageUploadProvider imageUploadProvider,
      File imageFile,
      TeacherProvider teacherProvider) async {
    imageUploadProvider.setToLoading();
    List fileData = await uploadImagetoStorage(imageFile);
    sendImageMessageByTeacher(chatProvider, fileData, teacherProvider);
    imageUploadProvider.setToIdle();
    String topic =
        "${chatProvider.getSelectedClass}_${chatProvider.getSelectedSection}";
    await get(
        'https://arcane-tor-25475.herokuapp.com/send?topic=$topic&title=${teacherProvider.getTeacherName}, Sir &msg=Photo');
    topic =
        "${chatProvider.getSelectedClass}_${chatProvider.getSelectedSection}_teacher";
    await get(
        'https://arcane-tor-25475.herokuapp.com/send?topic=$topic&title=${teacherProvider.getTeacherName}, Sir (${chatProvider.getSelectedClass} Section: ${chatProvider.getSelectedSection}) &msg=Photo');
  }

  uploadHomeFile(
      File pdfFile, ChatProvider chatProvider, String aboutHomework) async {
    StorageReference reference = FirebaseStorage.instance.ref().child(
        'homeworks/${chatProvider.getSelectedClass}-${chatProvider.getSelectedSection}-${chatProvider.getSelectedSubject}');
    StorageUploadTask uploadTask = reference.putFile(pdfFile);
    String url = await (await uploadTask.onComplete).ref.getDownloadURL();
    return url;
  }

  addHomeWorkInClass(ImageUploadProvider imageUploadProvider,
      ChatProvider chatProvider, String aboutHomework) async {
    imageUploadProvider.setToLoading();
    _firestore
        .collection('homework')
        .document(chatProvider.getSelectedClass)
        .collection(chatProvider.getSelectedSection)
        .document(chatProvider.getSelectedSubject)
        .get()
        .then((data) async {
      if (data.exists) {
        if (data.data['date'] == null) {
          print(data.data['date']);
          String url = await uploadHomeFile(
              chatProvider.getSelectedFile, chatProvider, aboutHomework);
          _firestore
              .collection('homework')
              .document(chatProvider.getSelectedClass)
              .collection(chatProvider.getSelectedSection)
              .document(chatProvider.getSelectedSubject)
              .setData({
            "date": chatProvider.getCurrentDate,
            "pdf": url,
            "work": aboutHomework
          });
          Fluttertoast.showToast(msg: "Homework added");
          imageUploadProvider.setToIdle();
          String topic =
              "${chatProvider.getSelectedClass}_${chatProvider.getSelectedSection}_study";
          await get(
              'https://arcane-tor-25475.herokuapp.com/send?topic=$topic&title=Homework (${chatProvider.getSelectedSubject})&msg=Dear Students, Today\'s Homework Added');
        } else if (data.data['date'] == chatProvider.getCurrentDate) {
          Fluttertoast.showToast(msg: "Homework already added !");
          imageUploadProvider.setToIdle();
        }
      } else {
        String url = await uploadHomeFile(
            chatProvider.getSelectedFile, chatProvider, aboutHomework);
        _firestore
            .collection('homework')
            .document(chatProvider.getSelectedClass)
            .collection(chatProvider.getSelectedSection)
            .document(chatProvider.getSelectedSubject)
            .setData({
          "date": chatProvider.getCurrentDate,
          "pdf": url,
          "work": aboutHomework
        });
        Fluttertoast.showToast(msg: "Homework added");
        imageUploadProvider.setToIdle();
        String topic =
            "${chatProvider.getSelectedClass}_${chatProvider.getSelectedSection}_study";
        await get(
            'https://arcane-tor-25475.herokuapp.com/send?topic=$topic&title=Homework (${chatProvider.getSelectedSubject})&msg=Dear Students, Today\'s Homework Added');
      }
    });
  }

  addOnlineClass(ProgressDialog progressDialog, ChatProvider chatProvider,
      File compressedFile) async {
    progressDialog.update(message: "Uploading class...");
    _firestore
        .collection('onlineClass')
        .document(chatProvider.getSelectedClass)
        .collection(chatProvider.getSelectedSection)
        .document(chatProvider.getSelectedSubject)
        .get()
        .then((data) async {
      if (data.exists) {
        if (data.data['date'] == null) {
          StorageReference ref = FirebaseStorage.instance.ref().child(
              'onlineClass/${chatProvider.getSelectedSubject}-${chatProvider.getSelectedClass}-${chatProvider.getSelectedSection}');
          StorageUploadTask task = ref.putFile(compressedFile);
          String url = await (await task.onComplete).ref.getDownloadURL();
          progressDialog.update(message: "Adding Class...");
          _firestore
              .collection('homework')
              .document(chatProvider.getSelectedClass)
              .collection(chatProvider.getSelectedSection)
              .document(chatProvider.getSelectedSubject)
              .setData({
            "date": chatProvider.getCurrentDate,
            "video": url,
          });
          progressDialog.dismiss();
          chatProvider.setVideoFileText("Select Video");
          Fluttertoast.showToast(msg: "Class added");
        } else if (data.data['date'] == chatProvider.getCurrentDate) {
          progressDialog.dismiss();
          chatProvider.setVideoFileText("Select Video");
          Fluttertoast.showToast(msg: "Class already added !");
        }
      } else {
        StorageReference ref = FirebaseStorage.instance.ref().child(
            'onlineClass/${chatProvider.getSelectedSubject}-${chatProvider.getSelectedClass}-${chatProvider.getSelectedSection}');
        StorageUploadTask task = ref.putFile(compressedFile);
        String url = await (await task.onComplete).ref.getDownloadURL();
        progressDialog.update(message: "Adding Class...");
        _firestore
            .collection('onlineClass')
            .document(chatProvider.getSelectedClass)
            .collection(chatProvider.getSelectedSection)
            .document(chatProvider.getSelectedSubject)
            .setData({
          "date": chatProvider.getCurrentDate,
          "video": url,
        });
        chatProvider.setVideoFileText("Select Video");
        progressDialog.dismiss();
        Fluttertoast.showToast(msg: "Class added");
        String topic =
            "${chatProvider.getSelectedClass}_${chatProvider.getSelectedSection}_study";
        await get(
            'https://arcane-tor-25475.herokuapp.com/send?topic=$topic&title=Online Class (${chatProvider.getSelectedSubject})&msg=Dear Students, Today\'s Video Class Added');
      }
    });
  }

  uploadGalleryImage(File newImage) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference reference =
        FirebaseStorage.instance.ref().child('gallery/$fileName');
    StorageUploadTask uploadTask = reference.putFile(newImage);
    String url = await (await uploadTask.onComplete).ref.getDownloadURL();
    return url;
  }

  addToGallery(File imageFile, ImageUploadProvider imageUploadProvider) async {
    imageUploadProvider.setToLoading();
    String url = await uploadGalleryImage(imageFile);
    _firestore.collection('gallery').add({'image': url});
    imageUploadProvider.setToIdle();
  }

  Future<DocumentSnapshot> isHomeworkDoneOf(
      StudentProvider provider, String subject) async {
    DocumentSnapshot snapshot = await Firestore.instance
        .collection('submittedHomework')
        .document(provider.getStudentClass)
        .collection(provider.getStudentSection)
        .document(provider.getTodayDate)
        .collection(subject)
        .document(provider.getStudentID)
        .get();
    if (snapshot.exists) {
      return snapshot;
    } else {
      return null;
    }
  }

  checkHomework(ChatProvider provider, DocumentSnapshot doc, bool isCorrect,
      BuildContext context, String message) async {
    _firestore
        .collection("submittedHomework")
        .document(provider.getSelectedClass)
        .collection(provider.getSelectedSection)
        .document(provider.getCurrentDate)
        .collection(provider.getSelectedSubject)
        .document(doc.documentID)
        .setData({"isChecked": true, "isCorrect": isCorrect}, merge: true);
    if (isCorrect == false) {
      String studentToken;
      Firestore.instance
          .collection(provider.getSelectedClass)
          .document(doc.data['id'])
          .get()
          .then((document) async {
        studentToken = document.data['token'];
        await get(
            'https://arcane-tor-25475.herokuapp.com/sendToStudent?token=$studentToken&title=Your Homework of ${provider.getSelectedSubject} Checked But Wrong&msg=$message');
      });
    } else if (isCorrect == true) {
      String studentToken;
      Firestore.instance
          .collection(provider.getSelectedClass)
          .document(doc.data['id'])
          .get()
          .then((document) async {
        studentToken = document.data['token'];
        await get(
            'https://arcane-tor-25475.herokuapp.com/sendToStudent?token=$studentToken&title=Your Homework of ${provider.getSelectedSubject} Checked (Correct) &msg=Dear Student, You answers are right keep it up.');
      });
    }
    Navigator.of(context).pop();
  }

  removeStudent(ChatProvider provider, String docID) {
    _firestore.collection(provider.getSelectedClass).document(docID).delete();
    Fluttertoast.showToast(msg: "Student Registration Removed");
  }

  addNewStudent(ChatProvider provider, Student student, BuildContext context) {
    _firestore
        .collection(provider.getSelectedClass)
        .document(student.studentMobile)
        .setData({
      "name": student.name,
      "section": provider.getSelectedSection,
      "class": provider.getSelectedClass,
      "mobile": student.studentMobile
    }, merge: true);
    Fluttertoast.showToast(msg: "Student Registration Done");
    Navigator.of(context).pop();
  }
}

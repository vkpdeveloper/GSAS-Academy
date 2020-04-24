import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
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

  saveStudentData(String name, String className, String mobile, String admID,
      String profileUrl, String section, String token) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.setString("name", name);
    _prefs.setString("class", className);
    _prefs.setString("mobile", mobile);
    _prefs.setString("admID", admID);
    _prefs.setString("profile", profileUrl);
    _prefs.setString("section", section);
    _prefs.setBool("isStudent", true);
    _firestoreStudent.collection(className).document(mobile).setData({
      "name": name,
      "mobile": mobile,
      "profileUrl": profileUrl,
      "class": className,
      "section": section,
      "admId": admID,
      "token": token
    }, merge: true);
  }

  saveTeacherData(
      String name, String mobile, String profileUrl, String token) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.setString("name", name);
    _prefs.setString("mobile", mobile);
    _prefs.setString("profile", profileUrl);
    _prefs.setBool("isStudent", false);
    _firestoreTeacher.document(mobile).setData({
      "name": name,
      "mobile": mobile,
      "profileUrl": profileUrl,
      "token": token
    }, merge: true);
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
        'https://arcane-tor-25475.herokuapp.com/send?topic=$topic&title=New Message&msg=$message');
    topic = "${className}_${section}_teacher";
    res = await get(
        'https://arcane-tor-25475.herokuapp.com/send?topic=$topic&title=New Message ($className Section: $section) &msg=$message');
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
        'https://arcane-tor-25475.herokuapp.com/send?topic=$topic&title=New Message&msg=Photo');
    topic = "${className}_${section}_teacher";
    res = await get(
        'https://arcane-tor-25475.herokuapp.com/send?topic=$topic&title=New Message ($className Section: $section) &msg=Photo');
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
      TeacherProvider teacherProvider, String message) {
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
      ChatProvider chatProvider, List data, TeacherProvider teacherProvider) {
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
      BuildContext context) {
    _firestore
        .collection("submittedHomework")
        .document(provider.getSelectedClass)
        .collection(provider.getSelectedSection)
        .document(provider.getCurrentDate)
        .collection(provider.getSelectedSubject)
        .document(doc.documentID)
        .setData({"isChecked": true, "isCorrect": isCorrect}, merge: true);
    Navigator.of(context).pop();
  }
}

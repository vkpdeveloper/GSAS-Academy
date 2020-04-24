import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:gsasacademy/enum/view_state.dart';
import 'package:gsasacademy/providers/image_provider.dart';
import 'package:gsasacademy/providers/student_provider.dart';
import 'package:gsasacademy/themeConstants.dart';
import 'package:gsasacademy/utils/firebaseutils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  ScrollController _controller = ScrollController();
  TextEditingController messageController = TextEditingController();
  FirebaseUtils _utils = FirebaseUtils();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unSubscribeMe();
    Timer(Duration(seconds: 2), () {
      _controller.animateTo(_controller.position.maxScrollExtent,
          duration: Duration(milliseconds: 200), curve: Curves.linearToEaseOut);
    });
  }

  unSubscribeMe() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String className = _prefs.getString('class');
    String section = _prefs.getString('section');
    String topic = "${className}_$section";
    await FirebaseMessaging().unsubscribeFromTopic(topic);
  }

  void onDispose() {
    super.dispose();
    _controller.dispose();
    messageController.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _controller.animateTo(_controller.position.maxScrollExtent,
          duration: Duration(milliseconds: 200), curve: Curves.linearToEaseOut);
    }
    if (state == AppLifecycleState.paused) {
      _controller.animateTo(_controller.position.maxScrollExtent,
          duration: Duration(milliseconds: 200), curve: Curves.linearToEaseOut);
    }
  }

  _showEditingDialog(
      BuildContext context,
      String docID,
      StudentProvider studentProvider,
      String oldMessage,
      ImageUploadProvider imageUploadProvider) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)),
            title: Text("Select Option"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  onTap: () =>
                      _utils.deleteMessage(studentProvider, docID, context),
                  leading: Icon(Icons.delete),
                  title: Text("Delete Message"),
                ),
                ListTile(
                  onTap: () {
                    messageController.text = oldMessage;
                    imageUploadProvider.setEditedMessage(true);
                    imageUploadProvider.setDocID(docID);
                    Navigator.pop(context);
                  },
                  leading: Icon(Feather.edit),
                  title: Text("Edit Message"),
                )
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    StudentProvider _studentProvider = Provider.of<StudentProvider>(context);
    ImageUploadProvider _imageUploadProvider =
        Provider.of<ImageUploadProvider>(context);
    return WillPopScope(
      onWillPop: () async {
        FirebaseMessaging().subscribeToTopic(
            "${_studentProvider.getStudentClass}_${_studentProvider.getStudentSection}");
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Chat"),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: Firestore.instance
                        .collection('chat')
                        .document(_studentProvider.getStudentClass)
                        .collection(_studentProvider.getStudentSection)
                        .orderBy('timestamp', descending: false)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) return Text("Error Occured !");
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                          break;
                        default:
                          return ListView(
                            controller: _controller,
                            children: snapshot.data.documents
                                .map((DocumentSnapshot doc) {
                              if (doc.data['id'] ==
                                  _studentProvider.getStudentID) {
                                if (doc.data['type'] == 'text') {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10.0, right: 15.0),
                                    child: Align(
                                      alignment: Alignment.topRight,
                                      child: InkWell(
                                        highlightColor: Colors.grey,
                                        onLongPress: () => _showEditingDialog(
                                            context,
                                            doc.documentID,
                                            _studentProvider,
                                            doc.data['message'],
                                            _imageUploadProvider),
                                        splashColor: Colors.grey,
                                        child: Card(
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(15.0),
                                                    topLeft:
                                                        Radius.circular(15.0),
                                                    bottomLeft:
                                                        Radius.circular(15.0))),
                                            elevation: 8.0,
                                            semanticContainer: true,
                                            color: ThemeConst.primaryColor,
                                            child: Container(
                                              width: (MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      2) +
                                                  50,
                                              child: Column(
                                                children: <Widget>[
                                                  Align(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: Text(
                                                      "YOU",
                                                      style: TextStyle(
                                                        fontSize: 10.0,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 5.0,
                                                  ),
                                                  Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      doc.data['message'],
                                                      style: TextStyle(
                                                        fontSize: 14.0,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              padding: EdgeInsets.all(10.0),
                                            )),
                                      ),
                                    ),
                                  );
                                }
                                if (doc.data['type'] == 'image') {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10.0, right: 15.0),
                                    child: Align(
                                      alignment: Alignment.topRight,
                                      child: Hero(
                                        tag: doc.data['message'],
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                  topRight:
                                                      Radius.circular(15.0),
                                                  topLeft:
                                                      Radius.circular(15.0),
                                                  bottomLeft:
                                                      Radius.circular(15.0))),
                                          elevation: 8.0,
                                          semanticContainer: true,
                                          color: ThemeConst.primaryColor,
                                          child: Container(
                                            width: (MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2) +
                                                50,
                                            padding: EdgeInsets.all(10.0),
                                            child: Column(
                                              children: <Widget>[
                                                Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Text(
                                                    "YOU",
                                                    style: TextStyle(
                                                      fontSize: 10.0,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 5.0,
                                                ),
                                                Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: GestureDetector(
                                                      onTap: () => {},
                                                      child: CachedNetworkImage(
                                                        imageUrl:
                                                            doc.data['message'],
                                                        imageBuilder: (context,
                                                            provider) {
                                                          return GestureDetector(
                                                            onTap: () =>
                                                                Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              PhotoView(
                                                                        heroAttributes:
                                                                            PhotoViewHeroAttributes(tag: doc.data['message']),
                                                                        loadingBuilder:
                                                                            (context,
                                                                                event) {
                                                                          return Center(
                                                                              child: CircularProgressIndicator(
                                                                            valueColor:
                                                                                AlwaysStoppedAnimation<Color>(ThemeConst.primaryColor),
                                                                          ));
                                                                        },
                                                                        imageProvider:
                                                                            NetworkImage(doc.data['message']),
                                                                        enableRotation:
                                                                            false,
                                                                      ),
                                                                    )),
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15.0),
                                                              child: Image(
                                                                image: provider,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        placeholder:
                                                            (context, str) {
                                                          return Center(
                                                            child:
                                                                CircularProgressIndicator(
                                                              valueColor:
                                                                  AlwaysStoppedAnimation<
                                                                          Color>(
                                                                      Colors
                                                                          .white),
                                                            ),
                                                          );
                                                        },
                                                        errorWidget: (context,
                                                            str, event) {
                                                          return Center(
                                                            child:
                                                                CircularProgressIndicator(
                                                              valueColor:
                                                                  AlwaysStoppedAnimation<
                                                                          Color>(
                                                                      Colors
                                                                          .white),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ))
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              } else if (doc.data['id'] !=
                                  _studentProvider.getStudentID) {
                                if (doc.data['by'] == 'student') {
                                  if (doc.data['type'] == 'text') {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10.0, left: 15.0),
                                      child: Align(
                                        alignment: Alignment.topLeft,
                                        child: Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                  topRight:
                                                      Radius.circular(15.0),
                                                  topLeft:
                                                      Radius.circular(15.0),
                                                  bottomRight:
                                                      Radius.circular(15.0)),
                                            ),
                                            elevation: 8.0,
                                            semanticContainer: true,
                                            color: Colors.white,
                                            child: Container(
                                              width: (MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      2) +
                                                  50,
                                              child: Column(
                                                children: <Widget>[
                                                  Align(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: Text(
                                                      doc.data['name'],
                                                      style: TextStyle(
                                                        fontSize: 10.0,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 5.0,
                                                  ),
                                                  Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      doc.data['message'],
                                                      style: TextStyle(
                                                        fontSize: 14.0,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              padding: EdgeInsets.all(10.0),
                                            )),
                                      ),
                                    );
                                  } else if (doc.data['type'] == 'image') {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10.0, left: 15.0),
                                      child: Align(
                                        alignment: Alignment.topLeft,
                                        child: Hero(
                                          tag: doc.data['message'],
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(15.0),
                                                    topLeft:
                                                        Radius.circular(15.0),
                                                    bottomLeft:
                                                        Radius.circular(15.0))),
                                            elevation: 8.0,
                                            semanticContainer: true,
                                            color: ThemeConst.primaryColor,
                                            child: Container(
                                              width: (MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      2) +
                                                  50,
                                              padding: EdgeInsets.all(10.0),
                                              child: Column(
                                                children: <Widget>[
                                                  Align(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: Text(
                                                      doc.data['name'],
                                                      style: TextStyle(
                                                        fontSize: 10.0,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 5.0,
                                                  ),
                                                  Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: GestureDetector(
                                                        onTap: () => {},
                                                        child:
                                                            CachedNetworkImage(
                                                          imageUrl: doc
                                                              .data['message'],
                                                          imageBuilder:
                                                              (context,
                                                                  provider) {
                                                            return GestureDetector(
                                                              onTap: () =>
                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                PhotoView(
                                                                          heroAttributes:
                                                                              PhotoViewHeroAttributes(tag: doc.data['message']),
                                                                          loadingBuilder:
                                                                              (context, event) {
                                                                            return Center(
                                                                                child: CircularProgressIndicator(
                                                                              valueColor: AlwaysStoppedAnimation<Color>(ThemeConst.primaryColor),
                                                                            ));
                                                                          },
                                                                          imageProvider:
                                                                              NetworkImage(doc.data['message']),
                                                                          enableRotation:
                                                                              false,
                                                                        ),
                                                                      )),
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            15.0),
                                                                child: Image(
                                                                  image:
                                                                      provider,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                          placeholder:
                                                              (context, str) {
                                                            return Center(
                                                              child:
                                                                  CircularProgressIndicator(
                                                                valueColor:
                                                                    AlwaysStoppedAnimation<
                                                                            Color>(
                                                                        Colors
                                                                            .white),
                                                              ),
                                                            );
                                                          },
                                                          errorWidget: (context,
                                                              str, event) {
                                                            return Center(
                                                              child:
                                                                  CircularProgressIndicator(
                                                                valueColor:
                                                                    AlwaysStoppedAnimation<
                                                                            Color>(
                                                                        Colors
                                                                            .white),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ))
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                } else {
                                  if (doc.data['type'] == 'text') {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10.0, left: 15.0),
                                      child: Align(
                                        alignment: Alignment.topLeft,
                                        child: Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                  topRight:
                                                      Radius.circular(15.0),
                                                  topLeft:
                                                      Radius.circular(15.0),
                                                  bottomRight:
                                                      Radius.circular(15.0)),
                                            ),
                                            elevation: 8.0,
                                            semanticContainer: true,
                                            color: Colors.red,
                                            child: Container(
                                              width: (MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      2) +
                                                  50,
                                              child: Column(
                                                children: <Widget>[
                                                  Align(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: Text(
                                                      "${doc.data['name']}, Sir",
                                                      style: TextStyle(
                                                        fontSize: 10.0,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 5.0,
                                                  ),
                                                  Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      doc.data['message'],
                                                      style: TextStyle(
                                                        fontSize: 14.0,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              padding: EdgeInsets.all(10.0),
                                            )),
                                      ),
                                    );
                                  } else if (doc.data['type'] == 'image') {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10.0, left: 15.0),
                                      child: Align(
                                        alignment: Alignment.topLeft,
                                        child: Hero(
                                          tag: doc.data['message'],
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(15.0),
                                                    topLeft:
                                                        Radius.circular(15.0),
                                                    bottomLeft:
                                                        Radius.circular(15.0))),
                                            elevation: 8.0,
                                            semanticContainer: true,
                                            color: Colors.red,
                                            child: Container(
                                              width: (MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      2) +
                                                  50,
                                              padding: EdgeInsets.all(10.0),
                                              child: Column(
                                                children: <Widget>[
                                                  Align(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    child: Text(
                                                      "${doc.data['name']}, Sir",
                                                      style: TextStyle(
                                                        fontSize: 10.0,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 5.0,
                                                  ),
                                                  Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: GestureDetector(
                                                        onTap: () => {},
                                                        child:
                                                            CachedNetworkImage(
                                                          imageUrl: doc
                                                              .data['message'],
                                                          imageBuilder:
                                                              (context,
                                                                  provider) {
                                                            return GestureDetector(
                                                              onTap: () =>
                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                PhotoView(
                                                                          heroAttributes:
                                                                              PhotoViewHeroAttributes(tag: doc.data['message']),
                                                                          loadingBuilder:
                                                                              (context, event) {
                                                                            return Center(
                                                                                child: CircularProgressIndicator(
                                                                              valueColor: AlwaysStoppedAnimation<Color>(ThemeConst.primaryColor),
                                                                            ));
                                                                          },
                                                                          imageProvider:
                                                                              NetworkImage(doc.data['message']),
                                                                          enableRotation:
                                                                              false,
                                                                        ),
                                                                      )),
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            15.0),
                                                                child: Image(
                                                                  image:
                                                                      provider,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                          placeholder:
                                                              (context, str) {
                                                            return Center(
                                                              child:
                                                                  CircularProgressIndicator(
                                                                valueColor:
                                                                    AlwaysStoppedAnimation<
                                                                            Color>(
                                                                        Colors
                                                                            .white),
                                                              ),
                                                            );
                                                          },
                                                          errorWidget: (context,
                                                              str, event) {
                                                            return Center(
                                                              child:
                                                                  CircularProgressIndicator(
                                                                valueColor:
                                                                    AlwaysStoppedAnimation<
                                                                            Color>(
                                                                        Colors
                                                                            .white),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ))
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                }
                              }
                            }).toList(),
                          );
                      }
                    },
                  ),
                ),
              ),
              _imageUploadProvider.getViewState == ViewState.LOADING
                  ? Container(
                      padding: EdgeInsets.all(10.0),
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text("Uploading Image..."),
                          CircularProgressIndicator()
                        ],
                      ),
                    )
                  : Container(),
              Container(
                color: Colors.white,
                margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                padding: EdgeInsets.only(top: 4.0, bottom: 4.0),
                height: 60.0,
                child: Row(children: <Widget>[
                  FloatingActionButton(
                    heroTag: '1',
                    child: Icon(FontAwesome.file_photo_o),
                    onPressed: () async {
                      File myImage = await ImagePicker.pickImage(
                          source: ImageSource.gallery);
                      _utils.uploadImageWithProvider(
                          myImage, _imageUploadProvider, _studentProvider);
                      _controller.animateTo(
                          _controller.position.maxScrollExtent,
                          duration: Duration(milliseconds: 200),
                          curve: Curves.linearToEaseOut);
                    },
                    foregroundColor: Colors.white,
                    backgroundColor: ThemeConst.primaryColor,
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    child: TextField(
                        maxLengthEnforced: true,
                        autocorrect: true,
                        controller: messageController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 10.0),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0)),
                          hintText: "Type a message",
                        )),
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  FloatingActionButton(
                    heroTag: '2',
                    child: Icon(_imageUploadProvider.getEditingMessage
                        ? MaterialIcons.check
                        : MaterialIcons.send),
                    onPressed: () {
                      if (messageController.text.trim() != "") {
                        if (_imageUploadProvider.getEditingMessage == false) {
                          _utils.sendTextMessage(
                              messageController.text,
                              "student",
                              _studentProvider.getStudentID,
                              _studentProvider.getStudentClass,
                              _studentProvider.getStudentSection,
                              _studentProvider.getStudentName);
                          messageController.clear();
                          _controller.animateTo(
                              _controller.position.maxScrollExtent,
                              duration: Duration(milliseconds: 200),
                              curve: Curves.linearToEaseOut);
                        } else {
                          _utils.editMessage(
                              _studentProvider,
                              _imageUploadProvider.getDocID,
                              messageController.text);
                          messageController.clear();
                          _imageUploadProvider.setDocID("");
                          _imageUploadProvider.setEditedMessage(false);
                        }
                      }
                    },
                    foregroundColor: Colors.white,
                    backgroundColor: ThemeConst.primaryColor,
                  ),
                ]),
              )
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:gsasacademy/enum/view_state.dart';
import 'package:gsasacademy/providers/chat_provider.dart';
import 'package:gsasacademy/providers/image_provider.dart';
import 'package:gsasacademy/providers/teacher_provider.dart';
import 'package:gsasacademy/themeConstants.dart';
import 'package:gsasacademy/utils/firebaseutils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreenTeacher extends StatefulWidget {
  @override
  _ChatScreenTeacherState createState() => _ChatScreenTeacherState();
}

class _ChatScreenTeacherState extends State<ChatScreenTeacher>
    with WidgetsBindingObserver {
  ScrollController _controller = ScrollController();
  TextEditingController messageController = TextEditingController();
  FirebaseUtils _utils = FirebaseUtils();
  GlobalKey _scaffoldKey = GlobalKey();

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
    String topic = "${className}_${section}_teacher";
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
      String fileName,
      TeacherProvider teacherProvider,
      String oldMessage,
      ImageUploadProvider imageUploadProvider,
      ChatProvider chatProvider,
      bool isImage) {
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
                  onTap: () => _utils.delectChatMesasgeTeacher(
                      teacherProvider, docID, context, chatProvider, fileName),
                  leading: Icon(Icons.delete),
                  title: Text("Delete Message"),
                ),
                if (!isImage)
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

  _showEditingDialogStudent(
      BuildContext context,
      String docID,
      String oldMessage,
      ImageUploadProvider imageUploadProvider,
      ChatProvider chatProvider) {
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
                  onTap: () => _utils.deleteStudentMessageByTeacher(
                      chatProvider, docID, context),
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

  _showImageDelete(
      BuildContext context, String docID, ChatProvider chatProvider) {
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
                  onTap: () => _utils.deleteStudentMessageByTeacher(
                      chatProvider, docID, context),
                  leading: Icon(Icons.delete),
                  title: Text("Delete Message"),
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    ChatProvider chatProvider = Provider.of<ChatProvider>(context);
    TeacherProvider teacherProvider = Provider.of<TeacherProvider>(context);
    ImageUploadProvider _imageUploadProvider =
        Provider.of<ImageUploadProvider>(context);
    return WillPopScope(
      onWillPop: () async {
        FirebaseMessaging().subscribeToTopic(
            "${chatProvider.getSelectedClass}_${chatProvider.getSelectedSection}_teacher");
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(title: Text("Chat")),
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
                        .document(chatProvider.getSelectedClass)
                        .collection(chatProvider.getSelectedSection)
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
                                  teacherProvider.getTeacherID) {
                                if (doc.data['type'] == 'text') {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10.0, right: 15.0),
                                    child: Align(
                                      alignment: Alignment.topRight,
                                      child: GestureDetector(
                                        onLongPress: () => _showEditingDialog(
                                            context,
                                            doc.documentID,
                                            doc.data['fileName'],
                                            teacherProvider,
                                            doc.data['message'],
                                            _imageUploadProvider,
                                            chatProvider,
                                            false),
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
                                        child: GestureDetector(
                                          onLongPress: () => _showEditingDialog(
                                              context,
                                              doc.documentID,
                                              doc.data['fileName'],
                                              teacherProvider,
                                              doc.data['message'],
                                              _imageUploadProvider,
                                              chatProvider,
                                              true),
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
                                                        onTap: () {},
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
                                    ),
                                  );
                                }
                              } else if (doc.data['id'] !=
                                  teacherProvider.getTeacherID) {
                                if (doc.data['by'] == 'student') {
                                  if (doc.data['type'] == 'text') {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10.0, left: 15.0),
                                      child: Align(
                                        alignment: Alignment.topLeft,
                                        child: GestureDetector(
                                          onLongPress: () =>
                                              _showEditingDialogStudent(
                                                  context,
                                                  doc.documentID,
                                                  doc.data['message'],
                                                  _imageUploadProvider,
                                                  chatProvider),
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
                                          child: GestureDetector(
                                            onLongPress: () => _showImageDelete(
                                                context,
                                                doc.documentID,
                                                chatProvider),
                                            child: Card(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topRight:
                                                              Radius.circular(
                                                                  15.0),
                                                          topLeft:
                                                              Radius.circular(
                                                                  15.0),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  15.0))),
                                              elevation: 8.0,
                                              semanticContainer: true,
                                              color: Colors.white,
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
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 5.0,
                                                    ),
                                                    Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: GestureDetector(
                                                          onTap: () => {},
                                                          child:
                                                              CachedNetworkImage(
                                                            imageUrl: doc.data[
                                                                'message'],
                                                            imageBuilder:
                                                                (context,
                                                                    provider) {
                                                              return GestureDetector(
                                                                onTap: () =>
                                                                    Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                          builder: (context) =>
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
                                                                child:
                                                                    ClipRRect(
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
                                                                  valueColor: AlwaysStoppedAnimation<
                                                                          Color>(
                                                                      Colors
                                                                          .white),
                                                                ),
                                                              );
                                                            },
                                                            errorWidget:
                                                                (context, str,
                                                                    event) {
                                                              return Center(
                                                                child:
                                                                    CircularProgressIndicator(
                                                                  valueColor: AlwaysStoppedAnimation<
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
                                                      "${doc.data['name']}, Sir",
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
                                                    bottomRight:
                                                        Radius.circular(15.0))),
                                            elevation: 8.0,
                                            semanticContainer: true,
                                            color: Colors.white,
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
                                                                valueColor: AlwaysStoppedAnimation<
                                                                        Color>(
                                                                    ThemeConst
                                                                        .primaryColor),
                                                              ),
                                                            );
                                                          },
                                                          errorWidget: (context,
                                                              str, event) {
                                                            return Center(
                                                              child:
                                                                  CircularProgressIndicator(
                                                                valueColor: AlwaysStoppedAnimation<
                                                                        Color>(
                                                                    ThemeConst
                                                                        .primaryColor),
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
                      decoration: BoxDecoration(color: Colors.white),
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
                          source: ImageSource.gallery, imageQuality: 50);
                      if (myImage != null) {
                        _utils.sendImageMessageAsTeacher(chatProvider,
                            _imageUploadProvider, myImage, teacherProvider);
                        _controller.animateTo(
                            _controller.position.maxScrollExtent,
                            duration: Duration(milliseconds: 200),
                            curve: Curves.linearToEaseOut);
                      }
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
                      if (_imageUploadProvider.getEditingMessage) {
                        _utils.editStudentMessageByTeacher(_imageUploadProvider,
                            chatProvider, messageController.text);
                        messageController.clear();
                        _imageUploadProvider.setDocID("");
                        _imageUploadProvider.setEditedMessage(false);
                      }
                      if (messageController.text.trim() != "") {
                        if (_imageUploadProvider.getEditingMessage == false) {
                          _utils.sendAsTeacherMessage(chatProvider,
                              teacherProvider, messageController.text);
                          messageController.clear();
                          _controller.animateTo(
                              _controller.position.maxScrollExtent,
                              duration: Duration(milliseconds: 200),
                              curve: Curves.linearToEaseOut);
                        } else {}
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

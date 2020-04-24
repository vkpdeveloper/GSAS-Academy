import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gsasacademy/providers/chat_provider.dart';
import 'package:gsasacademy/utils/firebaseutils.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';

class HomeworkVerifier extends StatelessWidget {
  final String title;
  final DocumentSnapshot documentSnapshot;
  final FirebaseUtils _utils = FirebaseUtils();

  HomeworkVerifier({Key key, this.title, this.documentSnapshot})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    ChatProvider provider = Provider.of<ChatProvider>(context);
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () =>
                _utils.checkHomework(provider, documentSnapshot, true, context),
            color: Colors.white,
          ),
        ],
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () =>
              _utils.checkHomework(provider, documentSnapshot, false, context),
          color: Colors.white,
        ),
        title: Text("$title Homework"),
      ),
      body: PhotoView(
        backgroundDecoration: BoxDecoration(color: Colors.white),
        imageProvider: NetworkImage(documentSnapshot.data['homework']),
      ),
    );
  }
}

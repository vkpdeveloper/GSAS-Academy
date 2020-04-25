import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
    TextEditingController field = TextEditingController();
    ChatProvider provider = Provider.of<ChatProvider>(context);
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () => _utils.checkHomework(
                provider, documentSnapshot, true, context, ""),
            color: Colors.white,
          ),
        ],
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  actions: <Widget>[
                    FlatButton(
                      onPressed: () {
                        if (field.text.trim() != "") {
                          _utils.checkHomework(provider, documentSnapshot,
                              false, context, field.text);
                          Navigator.pop(context);
                        } else {
                          Fluttertoast.showToast(
                              msg: "Write the issue in the text box");
                        }
                      },
                      child: Text(
                        "Done",
                        style: TextStyle(fontSize: 16.0, color: Colors.blue),
                      ),
                    )
                  ],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0)),
                  title: Text("Fault in answers : "),
                  content: TextField(
                    controller: field,
                    maxLines: 5,
                    decoration: InputDecoration(
                        hintText: "Write here",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                  ),
                );
              }),
          color: Colors.white,
        ),
        title: Text("$title Homework"),
      ),
      body: PhotoView(
        loadingBuilder: (context, event) => Center(
          child: Container(
            width: 50.0,
            height: 50.0,
            child: CircularProgressIndicator(
              value: event == null
                  ? 0
                  : event.cumulativeBytesLoaded / event.expectedTotalBytes,
            ),
          ),
        ),
        backgroundDecoration: BoxDecoration(color: Colors.white),
        imageProvider: NetworkImage(documentSnapshot.data['homework']),
      ),
    );
  }
}

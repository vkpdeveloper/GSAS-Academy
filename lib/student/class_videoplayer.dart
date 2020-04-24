import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gsasacademy/providers/student_provider.dart';
import 'package:gsasacademy/student/homework_viewer.dart';
import 'package:gsasacademy/themeConstants.dart';
import 'package:gsasacademy/utils/firebaseutils.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class OnlineClassVideoPlayer extends StatefulWidget {
  final String videoURL;
  final String subject;

  const OnlineClassVideoPlayer({Key key, this.videoURL, this.subject})
      : super(key: key);

  @override
  _OnlineClassVideoPlayerState createState() => _OnlineClassVideoPlayerState();
}

class _OnlineClassVideoPlayerState extends State<OnlineClassVideoPlayer> {
  VideoPlayerController videoPlayerController;
  Future<void> initVideoPlayer;
  ChewieController _controller;
  FirebaseUtils _utils = FirebaseUtils();

  void dispose() {
    super.dispose();
    videoPlayerController.dispose();
  }

  @override
  void initState() {
    super.initState();
    videoPlayerController = VideoPlayerController.network(widget.videoURL);
    _controller = ChewieController(
        allowFullScreen: true,
        allowMuting: true,
        aspectRatio: 3 / 2,
        allowedScreenSleep: false,
        showControls: true,
        videoPlayerController: videoPlayerController,
        autoPlay: true,
        errorBuilder: (context, str) {
          return Text("Error in playing the video");
        },
        deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
        showControlsOnInitialize: true,
        autoInitialize: true,
        looping: false);
  }

  @override
  Widget build(BuildContext context) {
    StudentProvider _studentProvider = Provider.of<StudentProvider>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text("${widget.subject} Class"),
        ),
        body: Column(
          children: <Widget>[
            AspectRatio(
              aspectRatio: 3 / 2,
              child: Chewie(
                controller: _controller,
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 8.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0)),
                child: ListTile(
                  title: Text("Homework"),
                  trailing: MaterialButton(
                    onPressed: () async {
                      DocumentSnapshot documentSnapshot = await Firestore
                          .instance
                          .collection('homework')
                          .document(_studentProvider.getStudentClass)
                          .collection(_studentProvider.getStudentSection)
                          .document(widget.subject)
                          .get();
                      PDFDocument doc = await PDFDocument.fromURL(documentSnapshot.data['pdf']);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HomeworkPDFViewer(
                                    title: widget.subject,
                                    documnet: doc,
                                  )));
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0)),
                    color: ThemeConst.primaryColor,
                    child: Text(
                      "Open Work",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
            )
          ],
        ));
  }
}

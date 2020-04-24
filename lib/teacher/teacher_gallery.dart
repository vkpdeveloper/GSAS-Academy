import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gsasacademy/enum/view_state.dart';
import 'package:gsasacademy/providers/image_provider.dart';
import 'package:gsasacademy/themeConstants.dart';
import 'package:gsasacademy/utils/firebaseutils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';

class TeacherGallery extends StatelessWidget {
  final FirebaseUtils _utils = FirebaseUtils();
  @override
  Widget build(BuildContext context) {
    ImageUploadProvider imageUploadProvider =
        Provider.of<ImageUploadProvider>(context);
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          imageUploadProvider.getViewState == ViewState.LOADING
              ? Center(
                child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )),
              )
              : IconButton(
                  icon: Icon(Icons.cloud_upload),
                  tooltip: "Add new image",
                  onPressed: () async {
                    File imageFile = await ImagePicker.pickImage(
                        source: ImageSource.gallery, imageQuality: 75);
                    _utils.addToGallery(imageFile, imageUploadProvider);
                  },
                  color: Colors.white,
                )
        ],
        title: Text("School Gallery"),
      ),
      body: StreamBuilder(
        stream: Firestore.instance.collection('gallery').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text("Error in loading images"),
            );
          }
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(
                child: CircularProgressIndicator(),
              );
              break;
            default:
              if (!snapshot.hasData) {
                return Center(
                  child: Text("No Images Found !"),
                );
              } else {
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2),
                  itemBuilder: (BuildContext context, int index) {
                    return CachedNetworkImage(
                      imageUrl: snapshot.data.documents[index]['image'],
                      imageBuilder: (context, provider) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PhotoView(
                                    heroAttributes: PhotoViewHeroAttributes(
                                        tag: snapshot.data.documents[index]
                                            ['image']),
                                    loadingBuilder: (context, event) {
                                      return Center(
                                          child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                ThemeConst.primaryColor),
                                      ));
                                    },
                                    imageProvider: NetworkImage(snapshot
                                        .data.documents[index]['image']),
                                    enableRotation: false,
                                  ),
                                )),
                            child: Hero(
                              tag: snapshot.data.documents[index]['image'],
                              child: Card(
                                elevation: 3.0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0)),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15.0),
                                  child: Image(
                                    image: provider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      placeholder: (context, str) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                      errorWidget: (context, str, event) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    );
                  },
                  itemCount: snapshot.data.documents.length,
                );
              }
          }
        },
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

typedef void ImagePickerCallback(File image);

class ImagePickerWidget extends StatelessWidget {
  final ImagePickerCallback callback;

  ImagePickerWidget({this.callback});

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    callback(image);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56.0, // in logical pixels
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      // Row is a horizontal, linear layout.
      child: Center(
        child:
          IconButton(
            onPressed: getImage,
            tooltip: 'Click to upload',
            icon: Icon(Icons.file_upload),
          )
      )
    );
  }
}

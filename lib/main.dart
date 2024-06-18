import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'api_client.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RemoveBackground(),
    ),
  );
}

class RemoveBackground extends StatefulWidget {
  @override
  _RemoveBackgroundState createState() => new _RemoveBackgroundState();
}

class _RemoveBackgroundState extends State<RemoveBackground> {
  Uint8List? imageFile;

  String? imagePath;

  bool Loading = false;

  ScreenshotController controller = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Remove Bg'),
          actions: [
            IconButton(
                onPressed: () {
                  getImage(ImageSource.gallery);
                },
                icon: const Icon(Icons.image)),
            IconButton(
                onPressed: () {
                  getImage(ImageSource.camera);
                },
                icon: const Icon(Icons.camera_alt)),
            IconButton(
                onPressed: () async {
                  Loading = true;
                  imageFile = await ApiClient().removeBgApi(imagePath!);
                  Loading = false;
                  setState(() {});
                },
                icon: const Icon(Icons.delete)),
            IconButton(
                onPressed: () async {
                  saveImage();
                },
                icon: const Icon(Icons.save))
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              (Loading == true)
                  ? CircularProgressIndicator()
                  : Container(child: Text("")),
              (imageFile != null)
                  ? Screenshot(
                      controller: controller,
                      child: Image.memory(
                        imageFile!,
                        filterQuality: FilterQuality.high,
                      ),
                    )
                  : Container(
                      width: 300,
                      height: 300,
                      color: Colors.grey[300]!,
                      child: const Icon(
                        Icons.image,
                        size: 100,
                      ),
                    ),
            ],
          ),
        ));
  }

  void getImage(ImageSource source) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage != null) {
        imagePath = pickedImage.path;
        imageFile = await pickedImage.readAsBytes();
        setState(() {});
      }
    } catch (e) {
      imageFile = null;
      setState(() {});
    }
  }

  void saveImage() async {
    bool isGranted = await Permission.storage.status.isGranted;
    if (!isGranted) {
      isGranted = await Permission.storage.request().isGranted;
    }

    if (isGranted) {
      String directory = (await getExternalStorageDirectory())!.path;
      String fileName =
          DateTime.now().microsecondsSinceEpoch.toString() + ".png";
      controller.captureAndSave(directory, fileName: fileName);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
}


class MakeThumbnail {
  Future<String> getThumbnailTwo(String videopath, int position) async {
    try {
      final thumbnailFile = await VideoThumbnail.thumbnailFile(
        video: videopath,
        timeMs: position,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.JPEG,
      );

      // ignore: unnecessary_null_comparison
      if (thumbnailFile != null) {
        return Future<String>.value(thumbnailFile);
      } else {
        return Future<String>.value('');
      }
    } catch (e) {
      return Future<String>.value('');
    }
    }
}

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? image;
  // 画像をギャラリーから選ぶ関数
  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      // 画像がnullの場合戻る
      if (image == null) return;

      print(image);

      final imageTemp = File(image.path);

      setState(() => this.image = imageTemp);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  // カメラを使う関数
  Future pickImageC() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      // 画像がnullの場合戻る
      if (image == null) return;

      final imageTemp = File(image.path);

      setState(() => this.image = imageTemp);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future pickVideo() async {
    try {
      final file = await ImagePicker().pickVideo(source: ImageSource.gallery);
      print(file);

// 生成したサムネイルの表示


    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Image Picker Example"),
        ),
        body: Center(
            child: Column(
              children: [
                MaterialButton(
                  color: Colors.blue,
                  child: const Text(
                    "Pick Image from Garary",
                    style: TextStyle(
                        color: Colors.white70, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    pickImage();
                  },
                ),
                MaterialButton(
                  color: Colors.blue,
                  child: const Text(
                    "Pick Image from Garary",
                    style: TextStyle(
                        color: Colors.white70, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    pickImageC();
                  },
                ),
                MaterialButton(
                  color: Colors.blue,
                  child: const Text(
                    "Pick Video from Garary",
                    style: TextStyle(
                        color: Colors.white70, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    pickVideo();
                  },
                ),
                SizedBox(height: 20),
                // 画像がないと文字が表示される
                image != null ? Image.file(image!) : Text("No image selected")
              ],
            )) // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
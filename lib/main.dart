import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'util.dart';
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
  XFile? video;
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
      final _video = await ImagePicker().pickVideo(source: ImageSource.gallery);
      if (_video == null) return;
      //final i = await MakeThumbnail().getThumbnailTwo(File(_video.path).path, 3);

      //final thumbnail = await _generateThumbnail(File(_video.path));
      //final tempImg = MemoryImage(thumbnail!);

      //setState(() => this.image = tempImg);

      setState(() {
        video = _video;
        print(video);
      });
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
                //image != null ? Image.file(image!) : Text("No image selected")
                video != null ? FutureBuilder<ImageProvider>(
                    future: _imageProvider(File(video!.path)!),
                    builder: (context, snapshot) {
                      if (snapshot.data != null && snapshot.connectionState == ConnectionState.done ) {
                        return Container(
                          height: 300,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                            borderRadius: BorderRadius.circular(9),
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: snapshot.data!,
                            ),
                          ),
                        );
                      }
                      return Text("No video selected");
                    }): Text("No video selected")
              ],
            )) // This trailing comma makes auto-formatting nicer for build methods.
    );
  }


  /// generate jpeg thumbnail
  Future<Uint8List?> _generateThumbnail(File file) async {
    final thumbnailAsUint8List = await VideoThumbnail.thumbnailData(
      video: file.path,
      imageFormat: ImageFormat.JPEG,
      maxWidth:
      320, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 50,
    );
    return thumbnailAsUint8List!;
  }

  /// depending on file type show particular image
  Future<ImageProvider<Object>>? _imageProvider(File file) async {
    //if (file.fileType == FileType.video) {
      final thumbnail = await _generateThumbnail(file);
      return MemoryImage(thumbnail!);
    /*} else if (file.fileType == FileType.image) {
      return FileImage(file);
    } else {
      throw Exception("Unsupported media format");
    }*/

  }

  Widget _buildInlineVideoPlayer() {
    print(File(this.video!.path));
    final VideoPlayerController controller =
    VideoPlayerController.file(File(this.video!.path));
    const double volume = 1.0; //kIsWeb ? 0.0 : 1.0;
    controller.setVolume(volume);
    controller.initialize();
    controller.setLooping(true);
    controller.play();
    return Center(child: AspectRatioVideo(controller));
  }

}


class AspectRatioVideo extends StatefulWidget {
  const AspectRatioVideo(this.controller, {super.key});

  final VideoPlayerController? controller;

  @override
  AspectRatioVideoState createState() => AspectRatioVideoState();
}

class AspectRatioVideoState extends State<AspectRatioVideo> {
  VideoPlayerController? get controller => widget.controller;
  bool initialized = false;

  void _onVideoControllerUpdate() {
    if (!mounted) {
      return;
    }
    if (initialized != controller!.value.isInitialized) {
      initialized = controller!.value.isInitialized;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    controller!.addListener(_onVideoControllerUpdate);
  }

  @override
  void dispose() {
    controller!.removeListener(_onVideoControllerUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (initialized) {
      return Center(
        child: AspectRatio(
          aspectRatio: controller!.value.aspectRatio,
          child: VideoPlayer(controller!),
        ),
      );
    } else {
      return Container();
    }
  }
}

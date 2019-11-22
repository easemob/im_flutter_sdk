import 'package:flutter/foundation.dart';
import 'dart:io';

//import 'package:audio_recorder/audio_recorder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_sound/flutter_sound.dart';

///媒体工具，选照片，拍照，录音，播放语音
class MediaUtil {
  FlutterSound flutterSound = new FlutterSound();

  factory MediaUtil() => _getInstance();
  static MediaUtil get instance => _getInstance();
  static MediaUtil _instance;
  MediaUtil._internal() {
    // 初始化
  }
  static MediaUtil _getInstance() {
    if (_instance == null) {
      _instance = new MediaUtil._internal();
    }
    return _instance;
  }
  

  //拍照，成功则返回照片的本地路径，注：Android 必须要加 file:// 头
  Future<String> takePhoto() async {
    File imgfile = await ImagePicker.pickImage(source: ImageSource.camera);
    if (imgfile == null) {
      return null;
    }
    String imgPath = imgfile.path;
//    if (TargetPlatform.android == defaultTargetPlatform) {
//      imgPath = "file://" + imgfile.path;
//    }
    return imgPath;
  }

  //从相册选照片，成功则返回照片的本地路径，注：Android 必须要加 file:// 头
  Future<String> pickImage() async {
    File imgfile = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (imgfile == null) {
      return null;
    }
    String imgPath = imgfile.path;
    print('-------->imgUrl: ' + imgPath);
    return imgPath;
  }

  //开始录音
  void startRecordAudio() async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path +
        "/" +
        DateTime.now().millisecondsSinceEpoch.toString() +
        ".aac";
//    await AudioRecorder.start(
//        path: tempPath, audioOutputFormat: AudioOutputFormat.AAC);
  }

  //录音结束，通过 finished 返回本地路径和语音时长，注：Android 必须要加 file:// 头
  void stopRecordAudio(Function(String path, int duration) finished) async {
//    Recording recording = await AudioRecorder.stop();
    String path = ''; //recording.path;

    if (path == null) {
      if (finished != null) {
        finished(null, 0);
      }
    }

    if (TargetPlatform.android == defaultTargetPlatform) {
      path = "file://" + path;
    }
    if (finished != null) {
//      finished(path, recording.duration.inSeconds);
    }
  }

  //播放语音
  void startPlayAudio(String path) {
    if(flutterSound.isPlaying) {
      stopPlayAudio();
    }
    flutterSound.startPlayer(path);
  }

  //停止播放语音
  void stopPlayAudio() {
    flutterSound.stopPlayer();
  }

  String getCorrectedLocalPath(String localPath) {
    String path = localPath;
    //Android 本地路径需要删除 file:// 才能被 File 对象识别
    if (TargetPlatform.android == defaultTargetPlatform) {
      path = localPath.replaceFirst("file://", "");
    }
    return path;
  }
}

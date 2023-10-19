// Copyright 2023 a1147
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:io';
import 'dart:typed_data';

import 'package:dart_amqp/dart_amqp.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:hospital_ai_client/base/models/dao/cam.dart';
import 'package:hospital_ai_client/constants.dart';

abstract class BaseFilePicker {
  Future<String?> saveFile();
}

class FilePickerImpl extends BaseFilePicker {
  @override
  Future<String?> saveFile() async {
    final f = await FilePicker.platform
        .saveFile(dialogTitle: "保存文件到", allowedExtensions: ["mp4"]);
    return f;
  }
}

abstract class CamRecorder {
  Future<void> recordRealtime(Cam cam, String filePath);

  Future<void> recordFrom(Cam cam, DateTime dt, String filePath);

  Future<void> stopRecording();
}

class FFmpegCamRecorder extends CamRecorder {
  String binPath = "";
  Process? _currentProcess;

  FFmpegCamRecorder() {
    final dir = Directory.fromRawPath(
        Uint8List.fromList(Platform.resolvedExecutable.codeUnits));
    binPath = "${dir.parent.path}/bins/ffmpeg.exe";
  }

  @override
  Future<void> recordFrom(Cam cam, DateTime dt, String filePath) {
    if (cam.camType == CamType.rtsp.index) {
      final rtspUrl = getRtspBackTrackUrl(cam, dt, DateTime.now());
      return recordUrl(rtspUrl, filePath);
    } else {
      throw UnimplementedError();
    }
  }

  @override
  Future<void> stopRecording() async {
    if (_currentProcess == null) {
      return;
    }
    final p = _currentProcess;
    try {
      p?.stdin.add("q".codeUnits);
      await p?.stdin.flush();
      await p?.stdin.close();
      Future.delayed(Duration(seconds: 1), () {
        final hasTerm = p?.kill();
        print("recording stopped, pid: ${p?.pid}, ${hasTerm}");
      });
    } catch (e) {
      print(e);
      debugPrintStack();
    } finally {
      p?.kill();
    }

    _currentProcess = null;
  }

  @override

  /// ffmpeg -rtsp_transport tcp -i rtsp://... -c copy -f mp4 output.mp4
  Future<void> recordRealtime(Cam cam, String filePath) async {
    if (cam.camType == CamType.rtsp.index) {
      final rtspUrl = getRtSpStreamUrl(cam, mainStream: false);
      return recordUrl(rtspUrl, filePath);
    } else {
      throw UnimplementedError();
    }
  }

  Future<void> recordUrl(String url, String filePath) async {
    print("保存$url 到 $filePath");
    await stopRecording();
    _currentProcess = await Process.start(
        binPath,
        [
          "-rtsp_transport",
          "tcp",
          "-i",
          url.replaceAll("&", "^&"),
          "-c",
          "copy",
          "-f",
          "mp4",
          filePath
        ],
        runInShell: true,
        mode: ProcessStartMode.normal);
    if (_currentProcess != null) {
      stdout.addStream(_currentProcess!.stdout);
      stderr.addStream(_currentProcess!.stderr);
    }
  }
}

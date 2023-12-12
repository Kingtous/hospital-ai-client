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

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:hospital_ai_client/base/interfaces/interfaces.dart';
import 'package:hospital_ai_client/base/models/dao/cam.dart';
import 'package:hospital_ai_client/constants.dart';
import 'package:path/path.dart';

abstract class BaseFilePicker {
  Future<String?> saveFile({String? fileName, List<String>? exts});
}

class FilePickerImpl extends BaseFilePicker {
  @override
  Future<String?> saveFile({String? fileName, List<String>? exts}) async {
    final f = await FilePicker.platform
        .saveFile(
        dialogTitle: "保存文件到", allowedExtensions: exts, fileName: fileName);
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

class MediaRecordFs {
  late final Cam cam;
  late final DateTime dt;
  late final FileSystemEntity f;
}

class RecordModel {
  late final Future<void> inited;
  late List<MediaRecordFs> recs;

  RecordModel() {
    recs = [];
  }

  Future<List<MediaRecordFs>> refresh() async {
    print("刷新录制列表");
    final dir = await getRecorderHistoryFolder();
    final s = await dir.list(recursive: true).toList();
    Map<int, DateTime> m = Map();
    Map<int, FileSystemEntity> fm = Map();
    recs.clear();
    for (final video in s) {
      try {
        final videoName = basenameWithoutExtension(video.path);
        final meta = videoName.split('-');
        if (meta.length < 2) {
          print("⚠ ${meta}无效");
          video.delete();
          continue;
        }
        final id = int.tryParse(meta[0]);
        final dtDecoded = String.fromCharCodes(base64.decode(meta.sublist(1).join('-')));
        final dt =
            DateTime.tryParse(dtDecoded);
        print("$id $dtDecoded");
        if (id == null || dt == null) {
          print("⚠ ${meta}无效, $id, $dtDecoded");
          video.delete();
          continue;
        }
        m[id] = dt;
        fm[id] = video;
      } catch (e) {
        print("$e");
        video.delete();
      }
    }
    final ids = m.entries.map((e) => e.key).toList();
    final cams = await appDB.camDao.getCamByIds(ids);
    for (final entry in m.entries) {
      final c = cams.where((cam) => cam.id == entry.key).firstOrNull;
      if (c != null) {
        recs.add(MediaRecordFs()
          ..cam = c
          ..dt = entry.value
          ..f = fm[entry.key]!);
      }
    }
    return recs;
  }
}

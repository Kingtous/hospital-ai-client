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

import 'package:bruno/bruno.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:hospital_ai_client/base/interfaces/interfaces.dart';
import 'package:hospital_ai_client/base/models/dao/cam.dart';
import 'package:hospital_ai_client/base/models/record_model.dart';
import 'package:hospital_ai_client/constants.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:path/path.dart' as p;

class RecordHistoryPage extends StatefulWidget {
  const RecordHistoryPage({super.key});

  @override
  State<RecordHistoryPage> createState() => _RecordHistoryPageState();
}

class _RecordHistoryPageState extends State<RecordHistoryPage> {
  late Future<Directory> recorderHistoryDir;
  late RxList<Cam> selectedCams = RxList<Cam>();
  late Rx<MediaRecordFs?> selectedMediaFile = Rx(null);
  late Player player;
  late VideoController controller;
  // Rx
  late Rx<DateTime?> selectedDate = Rx(null);

  @override
  void initState() {
    super.initState();
    recorderHistoryDir = getRecorderHistoryFolder();
    recordModel.refresh();
    selectedMediaFile = Rx(null);
    player = Player(
        configuration: const PlayerConfiguration(bufferSize: 16 * 1024 * 1024));
    controller = VideoController(player);
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  void loadVideo() async {
    final wc = WeakReference(context);
    final entry = selectedFile.value;
    if (entry == null) {
      return;
    }
    if (!await entry.exists()) {
      if (wc.target != null) {
        BrnToast.show("该文件不存在", wc.target!);
      }
      return;
    }
    await player.stop();
    await player.open(Media(entry.uri.toString()), play: true);
    // await player.play();
    print("playing ${entry.uri.toString()}");
    print(player.stream.playlist);
  }

  Iterable<MediaRecordFs> getFilteredList() {}

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: kBgColor),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              margin: EdgeInsets.all(16.0),
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12), color: Colors.white),
              child: Column(
                children: [
                  const Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text(
                          '录制列表',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              color: kTextColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Obx(
                      () {
                        final list = getFilteredList().toList();
                        return ListView.builder(
                          itemBuilder: (context, index) {
                            final item = list[index];
                            return Container(
                              padding: const EdgeInsets.all(2.0),
                              margin: const EdgeInsets.all(2.0),
                              child: Obx(
                                () => Button(
                                  style: item == selectedMediaFile.value
                                      ? ButtonStyle(
                                          backgroundColor:
                                              ButtonState.all(kHighlightColor),
                                          border:
                                              ButtonState.all(BorderSide.none))
                                      : ButtonStyle(
                                          border:
                                              ButtonState.all(BorderSide.none)),
                                  child: Tooltip(
                                    message: item.path,
                                    child: Row(
                                      children: [
                                        Icon(FluentIcons.video),
                                        SizedBox(
                                          width: 4.0,
                                        ),
                                        Expanded(
                                            child: Text(
                                          p.basename(
                                            item.path,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: kTextStyle,
                                          textAlign: TextAlign.start,
                                        )),
                                        GestureDetector(
                                          onTap: () => onDeleteRecord(item),
                                          child: Icon(
                                            FluentIcons.delete,
                                            color: Colors.red,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  onPressed: () {
                                    if (selectedFile.value == item) {
                                      return;
                                    }
                                    selectedFile.value = item;
                                    loadVideo();
                                  },
                                ),
                              ),
                            );
                          },
                          itemCount: list.length,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12.0)),
              margin: EdgeInsets.all(16.0),
              child: Column(
                children: [Expanded(child: Video(controller: controller))],
              ),
            ),
          ),
        ],
      ),
    );
    ;
  }

  onDeleteRecord(FileSystemEntity entry) async {
    if (entry.existsSync()) {
      entry.deleteSync();
      BrnToast.show("已删除", context);
    }
    if (selectedFile.value == entry) {
      selectedFile.value = null;
    }
    setState(() {});
  }
}

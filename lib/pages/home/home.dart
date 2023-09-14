import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:hospital_ai_client/pages/devices/devices.dart';
import 'package:hospital_ai_client/pages/video/video.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var index = 0.obs;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => NavigationView(
        appBar: const NavigationAppBar(title: Text('视频监控报警平台')),
        pane: NavigationPane(
            onChanged: (idx) {
              index.value = idx;
            },
            selected: index.value,
            items: [
              PaneItem(
                  icon: const Icon(Icons.home),
                  body: const VideoHomePage(),
                  title: const Text('主页')),
              PaneItem(
                  icon: const Icon(Icons.camera_alt_outlined),
                  body: const DevicesPage(),
                  title: const Text('摄像头设置'))
            ]),
        // content: VideoHomePage(),
      ),
    );
  }
}

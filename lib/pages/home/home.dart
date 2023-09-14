import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';
import 'package:hospital_ai_client/pages/video/video.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: const NavigationAppBar(title: Text('视频监控报警平台')),
      pane: NavigationPane(items: [
        PaneItem(
            icon: const Icon(Icons.home),
            body: const VideoHomePage(),
            title: const Text('主页'))
      ]),
      // content: VideoHomePage(),
    );
  }
}

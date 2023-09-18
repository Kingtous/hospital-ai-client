import 'package:fluent_ui/fluent_ui.dart';
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
            displayMode: PaneDisplayMode.minimal,
            onChanged: (idx) {
              index.value = idx;
            },
            selected: index.value,
            items: [
              PaneItem(
                  icon: const Icon(FluentIcons.screen),
                  body: const VideoHomePage(),
                  title: const Text('监控大屏')),
              PaneItem(
                  icon: const Icon(FluentIcons.camera),
                  body: const DevicesPage(),
                  title: const Text('摄像头设置'))
            ]),
        // content: VideoHomePage(),
      ),
    );
  }
}

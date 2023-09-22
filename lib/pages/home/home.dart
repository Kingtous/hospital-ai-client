import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/state_manager.dart';
import 'package:hospital_ai_client/base/interfaces/interfaces.dart';
import 'package:hospital_ai_client/components/header.dart';
import 'package:hospital_ai_client/pages/devices/devices.dart';
import 'package:hospital_ai_client/pages/devices/roles.dart';
import 'package:hospital_ai_client/pages/users/manage.dart';
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
    return Column(
      children: [
        const Row(
          children: [Expanded(child: AppHeader())],
        ),
        Expanded(
          child: Obx(
            () => NavigationView(
              pane: NavigationPane(
                  displayMode: PaneDisplayMode.compact,
                  size: const NavigationPaneSize(openMaxWidth: 150.0),
                  onChanged: (idx) {
                    index.value = idx;
                  },
                  selected: index.value,
                  items: [
                    PaneItemSeparator(),
                    PaneItem(
                        icon: const Icon(FluentIcons.screen),
                        body: const VideoHomePage(),
                        title: const Text('监控大屏')),
                    if (userModel.isAdmin)
                    PaneItemSeparator(),
                    if (userModel.isAdmin)
                    PaneItem(
                        icon: const Icon(FluentIcons.camera),
                        body: const DevicesPage(),
                        title: const Text('摄像头管理')),
                    if (userModel.isAdmin)
                    PaneItem(
                        icon: const Icon(FluentIcons.people),
                        body: const UserManagePage(),
                        title: const Text('人员管理')),
                    if (userModel.isAdmin)
                    PaneItem(
                        icon: const Icon(FluentIcons.device_run),
                        body: const DeviceRolePage(),
                        title: const Text('职责管理'))
                  ]),
              // content: VideoHomePage(),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:fluent_ui/fluent_ui.dart';
import 'package:hospital_ai_client/base/interfaces/interfaces.dart';
import 'package:hospital_ai_client/base/models/dao/cam.dart';
import 'package:hospital_ai_client/components/video_control.dart';
import 'package:hospital_ai_client/components/video_widget.dart';
import 'package:media_kit_video/media_kit_video.dart';

class FullScreenLive extends StatefulWidget {
  final Cam cam;
  const FullScreenLive({super.key, required this.cam});

  @override
  State<FullScreenLive> createState() => _FullScreenLiveState();
}

class _FullScreenLiveState extends State<FullScreenLive> {
  VideoController? controller;

  @override
  void initState() {
    super.initState();
    // final player = videoModel.getPlayablePlayer(widget.id);
    // if (player != null) {
    //   controller = VideoController(player);
    // }
  }

  @override
  Widget build(BuildContext context) {
    final controller = this.controller;
    return NavigationView(
        appBar: NavigationAppBar(title: Text('设备详情 ${widget.cam.name}')),
        content: Row(
          children: [
            Flexible(
              flex: 3,
              child: Column(
                children: [
                  Expanded(
                    child: controller == null
                        ? const Center(
                            child: Text('未找到源，请重试'),
                          )
                        : Video(
                            controller: controller,
                            controls: (state) => VideoControl2(
                                state: state,
                                cam: widget.cam,
                                type: LiveType.fullscreen),
                          ),
                  ),
                ],
              ),
            ),
            const Flexible(
                child: Column(
              children: [Text('meta')],
            ))
          ],
        ));
  }
}

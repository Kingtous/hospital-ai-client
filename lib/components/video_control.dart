import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/state_manager.dart';
import 'package:hospital_ai_client/base/interfaces/interfaces.dart';
import 'package:hospital_ai_client/components/video_widget.dart';
import 'package:media_kit_video/media_kit_video.dart';

class VideoControl extends StatelessWidget {
  final VideoState state;
  final String deviceId;
  const VideoControl(
      {super.key,
      required this.state,
      required this.deviceId,
      required LiveType type});

  @override
  Widget build(BuildContext context) {
    var isHovered = false.obs;
    return StatefulBuilder(builder: (context, setState) {
      return MouseRegion(
        onExit: (_) => isHovered.value = false,
        onEnter: (_) => isHovered.value = true,
        onHover: (_) => isHovered.value = true,
        child: Obx(
          () => Offstage(
            offstage: !isHovered.value,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$deviceId', style: TextStyle(
                  color: Colors.white,
                ),),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Button(
                          child: const Text('刷新'),
                          onPressed: () async {
                            videoModel.get(deviceId)?.reload();
                          }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:hospital_ai_client/base/interfaces/interfaces.dart';
import 'package:hospital_ai_client/base/models/camera_model.dart';
import 'package:hospital_ai_client/components/video_control.dart';
import 'package:media_kit_video/media_kit_video.dart';

enum LiveType { thumbnail, fullscreen }

class VideoLive extends StatefulWidget {
  final String id;
  final double? width;
  final double? height;
  final LiveType type;
  const VideoLive({super.key, required this.id, this.width, this.height, required this.type});

  @override
  State<VideoLive> createState() => _VideoLiveState();
}

class _VideoLiveState extends State<VideoLive> {
  late final VideoController controller;
  bool isExist = false;
  RxBool isHovered = false.obs;

  @override
  void initState() {
    super.initState();
    final player = videoModel.get(widget.id);
    if (player != null && player is CanPlayViaPlayer) {
      isExist = true;
      controller = VideoController(player.player);
      controller.player.play();
    }
  }

  @override
  void dispose() {
    if (isExist) {
      controller.player.pause();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (evt) {
        isHovered.value = true;
      },
      onHover: (evt) {
        isHovered.value = true;
      },
      onExit: (evt) {
        isHovered.value = false;
      },
      child: Obx(
        () => Container(
          decoration: BoxDecoration(
            color: isHovered.value ? Colors.blue : Colors.transparent,
          ),
          padding: const EdgeInsets.all(2.0),
          child: !isExist
              ? Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                  ),
                  child: const Center(
                    child: Text('画面丢失'),
                  ))
              : SizedBox(
                  width: widget.width,
                  height: widget.height,
                  child: Video(
                    controller: controller,
                    width: widget.width,
                    height: widget.height,
                    controls: (state) =>
                        VideoControl(state: state, deviceId: widget.id, type: widget.type),
                  ),
                ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';
import 'package:hospital_ai_client/base/interfaces/interfaces.dart';
import 'package:hospital_ai_client/base/models/camera_model.dart';
import 'package:hospital_ai_client/base/models/dao/cam.dart';
import 'package:hospital_ai_client/components/video_control.dart';
import 'package:hospital_ai_client/constants.dart';
import 'package:media_kit_video/media_kit_video.dart';

enum LiveType { thumbnail, fullscreen }

class VideoLive extends StatefulWidget {
  final Cam cam;
  final double? width;
  final double? height;
  final LiveType type;
  const VideoLive(
      {super.key,
      required this.cam,
      this.width,
      this.height,
      required this.type});

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
    final player = videoModel.get(widget.cam);
    if (player != null && player is CanPlayViaPlayer) {
      isExist = true;
      controller = VideoController(player.player,
          configuration: VideoControllerConfiguration(
              hwdec: widget.type == LiveType.thumbnail ? "no" : null,
              enableHardwareAcceleration:
                  widget.type == LiveType.thumbnail ? false : true));
      Future.delayed(Duration.zero, () async {
        if (player is RTSPCamera) {
          if (!player.inited) {
            await player.init();
          }
        }
        await player.reload();
        await player.startPlay();
      });
    }
  }

  @override
  void dispose() {
    if (isExist) {
      videoModel.get(widget.cam)?.stop();
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
      child: Container(
        decoration: const BoxDecoration(
          color: kBlueColor,
        ),
        padding: const EdgeInsets.all(1.0),
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
                  // width: widget.width,
                  // height: widget.height,
                  // 不用开启
                  wakelock: false,
                  pauseUponEnteringBackgroundMode: true,
                  resumeUponEnteringForegroundMode: true,
                  controls: (state) => VideoControl(
                      state: state, cam: widget.cam, type: widget.type),
                ),
              ),
      ),
    );
  }
}

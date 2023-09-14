import 'package:json_annotation/json_annotation.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
part 'camera_model.g.dart';

abstract interface class PlayableDevice {
  // playable id
  String get id;

  Future<void> startPlay();
  // 重试
  Future<void> reload();

  Future<void> pause();

  Future<void> stop();

  Future<void> dispose();
}

@JsonSerializable()
class RTSPCamera implements PlayableDevice {
  late final String rtspUrl;
  late final String id;
  @JsonKey(includeFromJson: false)
  late final Player player;
  @JsonKey(includeFromJson: false)
  var isPlaying = false;

  RTSPCamera(this.id, {required this.rtspUrl}) {
    assert(rtspUrl.startsWith('rtsp://'));
    player = Player();
    player.add(Media(rtspUrl));
    player.open(Playlist([Media(rtspUrl)]), play: false);
    // no sound needed.
    player.setVolume(0.0);
    player.setPlaylistMode(PlaylistMode.loop);
  }

  @override
  Future<void> dispose() {
    return player.dispose();
  }

  @override
  Future<void> pause() async {
    await player.pause();
  }

  @override
  Future<void> reload() async {
    await player.next();
  }

  @override
  Future<void> startPlay() async {
    await player.play();
  }

  /// Connect the generated [_$PersonFromJson] function to the `fromJson`
  /// factory.
  factory RTSPCamera.fromJson(Map<String, dynamic> json) =>
      _$RTSPCameraFromJson(json);

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$RTSPCameraToJson(this);
  
  @override
  Future<void> stop() async {
    await player.stop();
  }
}

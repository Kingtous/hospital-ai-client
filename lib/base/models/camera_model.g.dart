// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'camera_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RTSPCamera _$RTSPCameraFromJson(Map<String, dynamic> json) => RTSPCamera(
      json['id'] as String,
      rtspUrl: json['rtspUrl'] as String,
    );

Map<String, dynamic> _$RTSPCameraToJson(RTSPCamera instance) =>
    <String, dynamic>{
      'rtspUrl': instance.rtspUrl,
      'id': instance.id,
    };

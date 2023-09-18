import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' hide Tooltip;
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_ai_client/base/interfaces/interfaces.dart';
import 'package:hospital_ai_client/base/models/camera_model.dart';

/// 设备管理页
class DevicesPage extends StatefulWidget {
  const DevicesPage({super.key});

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  @override
  Widget build(BuildContext context) {
    videoModel.playerMap.values.toList(growable: false);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '设备列表',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Button(
                  onPressed: _addDevice,
                  child: const Row(
                    children: [
                      Icon(FluentIcons.add),
                      SizedBox(
                        width: 4.0,
                      ),
                      Text('添加摄像头')
                    ],
                  ))
            ],
          ),
          const SizedBox(
            height: 8.0,
          ),
          Expanded(child: Obx(() {
            final keys = videoModel.playerMap.keys.toList();
            return ListView.builder(
              itemBuilder: (context, index) => CamRecordDeviceItem(
                  key: ValueKey(keys[index]),
                  device: videoModel.playerMap[keys[index]]!),
              itemCount: keys.length,
            );
          }))
        ],
      ),
    );
  }

  void _addDevice() {
    // 默认rtsp
    RTSPCamera.addNewDevice(context);
  }
}

class CamRecordDeviceItem extends StatelessWidget {
  final PlayableSource device;
  const CamRecordDeviceItem({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return Expander(
        header: _buildTile(context), content: _buildContent(context));
  }

  Widget _buildTile(BuildContext context) {
    return Row(
      children: [
        const Icon(FluentIcons.camera),
        const SizedBox(
          width: 16.0,
        ),
        Text("${device.id}"),
        Expanded(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Button(
                child: const Tooltip(
                  message: '查看画面',
                  child: Icon(FluentIcons.play),
                ),
                onPressed: () {
                  context
                      .pushNamed('player', pathParameters: {'id': "${device.id}"});
                })
          ],
        ))
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    if (device is GUIConfigurable) {
      return (device as GUIConfigurable).buildForm(context);
    } else {
      return const Row(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('该设备暂无配置项'),
          )
        ],
      );
    }
  }
}

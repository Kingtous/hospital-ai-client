import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_ai_client/base/interfaces/interfaces.dart';
import 'package:hospital_ai_client/base/models/camera_model.dart';
import 'package:hospital_ai_client/base/models/dao/cam.dart';
import 'package:hospital_ai_client/base/models/dao/room.dart';
import 'package:hospital_ai_client/components/loading.dart';
import 'package:hospital_ai_client/constants.dart';

/// 设备管理页
class DevicesPage extends StatefulWidget {
  const DevicesPage({super.key});

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  final selected = Rx<Room?>(null);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: videoModel.getRooms(),
        builder: (context, data) {
          if (!data.hasData) {
            return const Loading();
          }
          final rooms = data.data!;
          return Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(color: kBgColor),
              ),
              Row(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.all(16.0),
                          width: 200,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(kRadius),
                              color: Colors.white),
                          child: RoomList(
                            selected: selected,
                            rooms: rooms,
                            onRoomAdded: () {
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(child: CameraInRoomPage(room: selected)),
                ],
              ),
            ],
          );
        });
  }
}

class RoomList extends StatelessWidget {
  final Rx<Room?> selected;
  final List<Room> rooms;
  final VoidCallback onRoomAdded;
  final FlyoutController controller = FlyoutController();
  RoomList(
      {super.key,
      required this.selected,
      required this.rooms,
      required this.onRoomAdded});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '组别',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(
          height: 10.0,
        ),
        ...rooms.map((e) => SizedBox(
              height: 40,
              width: double.infinity,
              child: Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => Button(
                          style: ButtonStyle(
                              shadowColor:
                                  ButtonState.all(const Color(0xFFE0EDFF)),
                              padding: ButtonState.all(
                                  const EdgeInsets.only(left: 12.0)),
                              border: ButtonState.all(BorderSide.none),
                              backgroundColor: ButtonState.all(
                                  selected.value != e
                                      ? Colors.white
                                      : kHighlightColor)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(e.roomName),
                                  GestureDetector(
                                    child: const Icon(FluentIcons.delete),
                                    onTap: () async {
                                      await videoModel.deleteRoom(e);
                                      if (selected.value == e) {
                                        selected.value = null;
                                      }
                                      onRoomAdded();
                                    },
                                  )
                                ],
                              ).paddingOnly(right: 8.0),
                            ],
                          ),
                          onPressed: () {
                            selected.value = e;
                          }),
                    ),
                  ),
                ],
              ),
            )),
        FlyoutTarget(
          controller: controller,
          child: Button(
              style: ButtonStyle(border: ButtonState.all(BorderSide.none)),
              onPressed: _toggleAdd,
              child: const Text(
                '+新增组别',
                style: TextStyle(color: kBlueColor),
              )),
        )
      ],
    ).paddingAll(16.0);
  }

  void _toggleAdd() {
    final roomName = "".obs;
    controller.showFlyout(
        placementMode: FlyoutPlacementMode.bottomCenter,
        builder: (context) => Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(kRadius)),
              width: 250.0,
              child: Row(
                children: [
                  Expanded(
                      child: TextBox(
                    onChanged: (value) => roomName.value = value,
                    onSubmitted: (value) => roomName.value = value,
                    prefix: const Text('组名').paddingOnly(left: 4.0),
                  )),
                  const SizedBox(
                    width: 8.0,
                  ),
                  Button(
                      child: const Text('添加组'),
                      onPressed: () {
                        _addRoom(context, roomName.value);
                      })
                ],
              ),
            ));
  }

  void _addRoom(BuildContext context, String value) async {
    if (value.isEmpty) {
      warning(context, '组名不能为空');
      return;
    }
    Navigator.of(context).pop();
    await videoModel.addRoom(Room(null, value));
    onRoomAdded();
  }
}

class CameraInRoomPage extends StatefulWidget {
  final Rx<Room?> room;
  const CameraInRoomPage({super.key, required this.room});

  @override
  State<CameraInRoomPage> createState() => _CameraInRoomPageState();
}

class _CameraInRoomPageState extends State<CameraInRoomPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, right: 16.0, bottom: 16.0),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(kRadius), color: Colors.white),
        child: Obx(
          () => widget.room.value == null
              ? const Center(
                  child: Text('请选择左侧组别查看组别内的摄像头'),
                )
              : FutureBuilder(
                  future: roomModel.getAllCamsByRoom(widget.room.value!),
                  builder: (context, data) {
                    print(data);
                    if (!data.hasData) {
                      return const Loading();
                    }
                    final cams = data.data!;
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '设备列表 ${widget.room.value?.roomName}',
                                style: const TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          Row(
                            children: [
                              Button(
                                  onPressed: () =>
                                      _addDevice(widget.room.value!),
                                  child: const Row(
                                    children: [
                                      Icon(FluentIcons.add),
                                      SizedBox(
                                        width: 4.0,
                                      ),
                                      Text('添加摄像头')
                                    ],
                                  )),
                            ],
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Expanded(
                              child: CameraTable(
                                  room: widget.room.value!,
                                  cams: cams,
                                  onCamUpdate: () {
                                    setState(() {});
                                  })),
                        ],
                      ),
                    );
                  }),
        ),
      ),
    );
  }

  void _addDevice(Room room) async {
    // 默认rtsp
    await RTSPCamera.addNewDevice(context, room);
    setState(() {});
  }
}

class CameraTable extends StatefulWidget {
  final Room room;
  final List<Cam> cams;
  final VoidCallback onCamUpdate;
  const CameraTable(
      {super.key,
      required this.room,
      required this.cams,
      required this.onCamUpdate});

  @override
  State<CameraTable> createState() => _CameraTableState();
}

class _CameraTableState extends State<CameraTable> {
  static const kCameraProperties = <String>[
    '摄像头编号',
    '摄像头名称',
    '摄像头类型',
    '流地址',
    '开启报警',
    '操作'
  ];

  Color getColor(int idx) {
    return idx % 2 == 0 ? kTableGreyColor : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return _buildTable(widget.cams);
  }

  _toggleDelete(Cam cam) {
    videoModel.deleteCam(cam).then((value) {
      widget.onCamUpdate();
    });
  }

  _updateDevice(Cam cam) async {
    await RTSPCamera.updateDevice(context, cam);
    setState(() {});
  }

  Widget _buildTable(List<Cam> list) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                genRow(
                    kCameraProperties
                        .map((e) => Text(e))
                        .toList(growable: false),
                    true,
                    0),
                ...list.map((e) => genRow([
                      SelectableText('${e.id}'),
                      SelectableText(e.name),
                      SelectableText(CamType.values[e.camType].toHumanString()),
                      Row(
                        children: [
                          Expanded(
                              child: SelectableText(
                                  "${e.host}:${e.port} 通道${e.channelId}")),
                          // FlyoutTarget(
                          //   controller: FlyoutController(),
                          //   child: Button(
                          //     child: Icon(FluentIcons.edit),
                          //     onPressed: () {},
                          //   ),
                          // ),
                          // SizedBox(
                          //   width: 16.0,
                          // )
                        ],
                      ),
                      Row(
                        children: [
                          ToggleSwitch(
                              checked: e.enableAlert,
                              onChanged: (enable) {
                                videoModel
                                    .updateCam(e..enableAlert = enable)
                                    .then((value) {
                                  setState(() {});
                                });
                              }),
                        ],
                      ),
                      Row(
                        children: [
                          FilledButton(
                            onPressed: () => _updateDevice(e),
                            style: ButtonStyle(
                                backgroundColor: ButtonState.all(Colors.blue)),
                            child: const Text('更新'),
                          ),
                          SizedBox(width: 10,),
                          FilledButton(
                            onPressed: () => _toggleDelete(e),
                            style: ButtonStyle(
                                backgroundColor: ButtonState.all(Colors.red)),
                            child: const Text('删除'),
                          )
                        ],
                      ),
                    ], false, list.indexOf(e) + 1))
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget genRow(List<Widget> cells, bool isHeader, int index) {
    assert(cells.length == kCameraProperties.length);
    return Container(
      decoration: BoxDecoration(color: getColor(index)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            flex: 1,
            child: Row(
              children: [Expanded(child: cells[0])],
            ),
          ),
          Flexible(
            flex: 1,
            child: Row(
              children: [Expanded(child: cells[1])],
            ),
          ),
          Flexible(
            flex: 1,
            child: Row(
              children: [Expanded(child: cells[2])],
            ),
          ),
          Flexible(
            flex: 1,
            child: Row(
              children: [Expanded(child: cells[3])],
            ),
          ),
          Flexible(
            flex: 1,
            child: Row(
              children: [Expanded(child: cells[4])],
            ),
          ),
          Flexible(
            flex: 1,
            child: Row(
              children: [Expanded(child: cells[5])],
            ),
          ),
        ],
      ).paddingSymmetric(horizontal: 12.0, vertical: 9.0),
    );
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
        Text(device.id),
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
                      .pushNamed('player', pathParameters: {'id': device.id});
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

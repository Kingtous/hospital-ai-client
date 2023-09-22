// Copyright 2023 a1147
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
import 'package:get/state_manager.dart';
import 'package:hospital_ai_client/base/interfaces/interfaces.dart';
import 'package:hospital_ai_client/base/models/dao/area.dart';
import 'package:hospital_ai_client/base/models/dao/cam.dart';
import 'package:hospital_ai_client/base/models/dao/room.dart';
import 'package:hospital_ai_client/constants.dart';

class DeviceRolePage extends StatefulWidget {
  const DeviceRolePage({super.key});

  @override
  State<DeviceRolePage> createState() => _DeviceRolePageState();
}

class _DeviceRolePageState extends State<DeviceRolePage> {
  Rx<Area?> idx = Rx(null);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final roles = roleModel.list;
    return Container(
      decoration: BoxDecoration(color: kBgColor),
      child: Row(
        children: [
          SizedBox(
            width: 200,
            child: RolesList(
              list: roles,
              onRoleToggled: _onRoleToggled,
              selected: idx,
            ),
          ),
          Expanded(
            child: RolesAreaPrivPage(role: idx),
          )
        ],
      ),
    );
  }

  _onRoleToggled(Area area) {
    idx.value = area;
  }
}

class RolesList extends StatelessWidget {
  final RxList<Area> list;
  final Rx<Area?> selected;
  final Function(Area) onRoleToggled;
  final FlyoutController controller = FlyoutController();
  RolesList(
      {super.key,
      required this.list,
      required this.onRoleToggled,
      required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(kRadius), color: Colors.white),
      margin: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '用户角色',
            style: TextStyle(
                fontSize: 14.0,
                color: Color(0xFF415B73),
                fontWeight: FontWeight.w700),
          ),
          Expanded(
            child: Obx(
              () => Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 10.0,
                  ),
                  ...list.map(
                    (element) => SizedBox(
                      height: 40,
                      width: double.infinity,
                      child: Button(
                          style: ButtonStyle(
                              shadowColor: ButtonState.all(Color(0xFFE0EDFF)),
                              padding:
                                  ButtonState.all(EdgeInsets.only(left: 12.0)),
                              border: ButtonState.all(BorderSide.none),
                              backgroundColor: ButtonState.all(
                                  selected.value != element
                                      ? Colors.white
                                      : kHighlightColor)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(element.areaName),
                            ],
                          ),
                          onPressed: () => onRoleToggled(element)),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    child: FlyoutTarget(
                      controller: controller,
                      child: Button(
                          style: ButtonStyle(
                              border: ButtonState.all(BorderSide.none),
                              padding:
                                  ButtonState.all(EdgeInsets.only(left: 12.0))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "+新建角色",
                                style: TextStyle(color: kBlueColor),
                              )
                            ],
                          ),
                          onPressed: _toggleNewArea),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ).paddingSymmetric(horizontal: 8.0, vertical: 16.0),
    );
  }

  _toggleNewArea() {
    final roleName = "".obs;
    controller.showFlyout(
        placementMode: FlyoutPlacementMode.bottomCenter,
        builder: (context) => Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(kRadius)),
              width: 250.0,
              child: Row(
                children: [
                  Expanded(
                      child: TextBox(
                    onChanged: (value) => roleName.value = value,
                    onSubmitted: (value) => roleName.value = value,
                    prefix: Text('名称').paddingOnly(left: 4.0),
                  )),
                  SizedBox(
                    width: 8.0,
                  ),
                  Button(
                      child: Text('添加角色'),
                      onPressed: () {
                        _addRole(context, roleName.value);
                      })
                ],
              ),
            ));
  }

  _addRole(BuildContext context, String areaName) async {
    if (areaName.isEmpty) {
      warning(context, '角色名不能为空');
      return;
    }
    Navigator.of(context).pop();
    await roleModel.addRole(areaName);
  }
}

class RolesAreaPrivPage extends StatefulWidget {
  final Rx<Area?> role;
  const RolesAreaPrivPage({super.key, required this.role});

  @override
  State<RolesAreaPrivPage> createState() => _RolesAreaPrivPageState();
}

class _RolesAreaPrivPageState extends State<RolesAreaPrivPage> {
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
          margin: EdgeInsets.only(top: 16.0, bottom: 16.0, right: 16.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(kRadius),
              color: Colors.white),
          child: widget.role.value == null
              ? Center(
                  child: Text('点击左侧角色进行配置'),
                )
              : _buildTable()),
    );
  }

  Widget _buildTable() {
    return Container(
      height: double.infinity,
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.role.value!.areaName}',
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(
            height: 8.0,
          ),
          Text(
            '请勾选可见内容',
            style: TextStyle(fontSize: 14),
          ),
          SizedBox(
            height: 8.0,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: FutureBuilder(
                  future: Future.wait([
                    videoModel.getAllCams(),
                    roleModel.getAllRels(),
                    roomModel.getAllRooms()
                  ]),
                  builder: (context, data) {
                    if (!data.hasData) {
                      return ProgressRing();
                    } else {
                      final cams = data.data!;
                      return _buildCheckBoxes(cams[0] as List<Cam>,
                          cams[1] as List<RoomCam>, cams[2] as List<Room>);
                    }
                  }),
            ),
          ),
          SizedBox(
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                    width: 100,
                    child:
                        FilledButton(child: Text('保存'), onPressed: _toggleSave))
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCheckBoxes(
      List<Cam> cams, List<RoomCam> rels, List<Room> rooms) {
    Map<Room, List<Cam>> m = Map();
    print(rels);
    print(rooms);
    print(cams);
    for (final rel in rels) {
      final room =
          rooms.where((element) => element.id == rel.roomId).firstOrNull;
      if (room == null) {
        continue;
      }
      final cam = cams.where((element) => element.id == rel.camId).firstOrNull;
      if (cam == null) {
        continue;
      }
      if (m.containsKey(room)) {
        m[room]!.add(cam);
      } else {
        m[room] = [cam];
      }
    }
    return Column(
      children: [
        ...m.entries.map((entry) => Column(
              children: [
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: kBgColor,
                  ),
                  child: Row(
                    children: [
                      Text('${entry.key.roomName}').paddingOnly(left: 4.0)
                    ],
                  ),
                ),
                SizedBox(
                  height: 4.0,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        children: [
                          ...entry.value.map((e) => Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Checkbox(
                                  checked: false,
                                  onChanged: (s) {
                                    // todo
                                  },
                                  content: Text("${e.name}"),
                                ),
                              ))
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 16.0,
                )
              ],
            ))
      ],
    );
  }

  void _toggleSave() {}
}

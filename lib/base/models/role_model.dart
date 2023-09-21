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

import 'package:get/state_manager.dart';
import 'package:hospital_ai_client/base/interfaces/interfaces.dart';
import 'package:hospital_ai_client/base/models/dao/area.dart';
import 'package:hospital_ai_client/base/models/dao/cam.dart';
import 'package:hospital_ai_client/base/models/dao/room.dart';
import 'package:hospital_ai_client/base/models/dao/user.dart';

/// 虽然叫Area，但是是角色权限
class RoleModel {
  final RxList<Area> _list = RxList();
  RxList<Area> get list => _list;

  RoleModel();

  Future<void> init() async {
    await refresh();
  }

  Future<void> addRole(String roleName) async {
    await appDB.areaDao.insertArea(Area(null, roleName));
    await refresh();
  }

  Future<List<Area>> getAllRoles() async {
    return await appDB.areaDao.findAllAreas();
  }

  Future<void> refresh() async {
    _list.value = await appDB.areaDao.findAllAreas();
  }

  // Future<List<Cam>> getAllCameras(int id) async {
  //   final iter = _list.where((p0) => p0.id == id);
  //   if (iter.isNotEmpty) {
  //     return const [];
  //   } else {
  //     Area a = iter.first;
  //     return appDB.camDao.findCamsByAreaId(a.id!);
  //   }
  // }

  Future<List<User>> getAllUsers(int areaId) async {
    final iter = _list.where((p0) => p0.id == areaId);
    if (iter.isNotEmpty) {
      return const [];
    } else {
      return appDB.areaUserDao.findAllAreaUsersByArea(areaId);
    }
  }

  Future<List<RoomCam>> getAllRels() async {
    return appDB.roomDao.getAll();
  }
}

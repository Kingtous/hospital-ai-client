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

class AreaModel {
  final RxList<Area> _list = RxList();
  RxList<Area> get list => _list;

  AreaModel();

  Future<void> init() async {
    await refresh();
  }

  Future<void> addArea(String areaName) async {
    await appDB.areaDao.insertArea(Area(null, areaName));
    await refresh();
  }

  Future<void> refresh() async {
    _list.value = await appDB.areaDao.findAllAreas();
  }

  Future<List<Cam>> getAllCameras(int id) async {
    final iter = _list.where((p0) => p0.id == id);
    if (iter.isNotEmpty) {
      return const [];
    } else {
      Area a = iter.first;
      return appDB.camDao.findCamsByAreaId(a.id!);
    }
  }
}

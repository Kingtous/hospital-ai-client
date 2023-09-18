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

import 'package:floor/floor.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:hospital_ai_client/base/interfaces/interfaces.dart';
import 'package:hospital_ai_client/base/models/dao/area.dart';

enum CamType { rtsp }

@Entity(tableName: 'cam', foreignKeys: [
  ForeignKey(
      childColumns: ['area_id'],
      parentColumns: ['id'],
      entity: Area,
      onDelete: ForeignKeyAction.cascade)
])
class Cam {
  @PrimaryKey(autoGenerate: true)
  int? id;
  final String name;

  @ColumnInfo(name: 'area_id')
  final int areaId;

  final String url;

  @ColumnInfo(name: 'cam_type')
  final int camType;

  Cam(this.id, this.name, this.areaId, this.url, this.camType);
}

@dao
abstract class CamDao {
  @Query('SELECT * FROM cam WHERE area_id = :areaId')
  Future<List<Cam>> findCamsByAreaId(int areaId);

  @insert
  @protected
  Future<int> insertCam(Cam cam);

  @delete
  Future<void> deleteCam(Cam cam);

  @update
  Future<void> updateCam(Cam cam);

  @transaction
  Future<void> addCam(Cam cam, Area area) async {
    assert(area.id != null);
    final camId = await insertCam(cam);
    await appDB.areaUserDao.insertAreaUser(AreaCam(null, area.id!, camId));
  }
}

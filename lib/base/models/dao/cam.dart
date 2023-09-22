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
import 'package:hospital_ai_client/base/models/dao/room.dart';

enum CamType { unknown, rtsp }

@Entity(tableName: 'cam', foreignKeys: [
  ForeignKey(
      childColumns: ['room_id'],
      parentColumns: ['id'],
      entity: Room,
      onDelete: ForeignKeyAction.cascade)
])
class Cam {
  @PrimaryKey(autoGenerate: true)
  int? id;
  String name;

  @ColumnInfo(name: 'room_id')
  int roomId;

  String url;

  @ColumnInfo(name: 'enable_alert')
  bool enableAlert;

  @ColumnInfo(name: 'cam_type')
  int camType;

  Cam(this.id, this.name, this.roomId, this.url, this.camType,
      this.enableAlert);

  @override
  int get hashCode => id ?? -1;

  @override
  bool operator ==(Object other) => other is Cam && other.id == id;
}

@dao
abstract class CamDao {
  @Query('SELECT * FROM cam WHERE room_id = :roomId')
  Future<List<Cam>> findCamsByRoomId(int roomId);

  @Query('SELECT * FROM cam')
  Future<List<Cam>> getAll();

  @Query('SELECT * FROM cam where id = :id LIMIT 1')
  Future<List<Cam>> getCamById(int id);

  @Query('SELECT * FROM cam where id IN (:ids)')
  Future<List<Cam>> getCamByIds(List<int> ids);

  @insert
  @protected
  Future<int> insertCam(Cam cam);

  @delete
  Future<void> deleteCam(Cam cam);

  @update
  Future<void> updateCam(Cam cam);

  @insert
  Future<int> insertRoomCam(RoomCam r);

  @transaction
  Future<int> addCam(Cam cam, Room room) async {
    assert(room.id != null);
    final camId = await insertCam(cam);
    return await insertRoomCam(RoomCam(null, room.id!, camId));
  }
}

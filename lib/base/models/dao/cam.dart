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
import 'package:hospital_ai_client/base/models/dao/room.dart';

enum CamType { unknown, rtsp }

extension ToString on CamType {
  @override
  String toHumanString() {
    if (this == CamType.unknown) {
      return '未知';
    } else {
      return 'RTSP';
    }
  }
}

@Entity(tableName: 'recorder')
class Recorder {
  @PrimaryKey(autoGenerate: true)
  int? id;

  @ColumnInfo(name: 'name')
  String recorderName;

  String ip;
  int port;
  String u;
  String p;
  Recorder(this.id, this.recorderName, this.ip, this.port, this.u, this.p);
}

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

  // 通道号
  @ColumnInfo(name: 'channel_id')
  int channelId;

  // // NVR录像机ID
  // @ColumnInfo(name: 'recorder_id')
  // int recorderId;

  String host;
  int port;

  @ColumnInfo(name: 'auth_user')
  String authUser;
  String password;

  @ColumnInfo(name: 'enable_alert')
  bool enableAlert;

  @ColumnInfo(name: 'cam_type')
  int camType;

  Cam(this.id, this.name, this.roomId, this.channelId,
      this.camType, this.enableAlert, this.authUser, this.password, this.port, this.host);

  @override
  int get hashCode => id ?? -1;

  @override
  bool operator ==(Object other) => other is Cam && other.id == id;
}

@dao
abstract class RecorderDao {
  @Query('SELECT * FROM recorder WHERE id = :id')
  Future<List<Recorder>> getRecorder(int id);

  @insert
  Future<int> addRecorder(Recorder recorder);

  @delete
  Future<int> deleteRecorder(Recorder recorder);
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

  @Query(
      'SELECT * FROM cam where id IN (SELECT DISTINCT cam_id FROM rel_area_cam WHERE area_id IN (SELECT DISTINCT area_id FROM rel_area_user WHERE user_id = :userId))')
  Future<List<Cam>> getAllowedCamByUserId(int userId);
}

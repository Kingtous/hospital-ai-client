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
import 'package:hospital_ai_client/base/models/dao/cam.dart';

@Entity(tableName: 'room')
class Room {
  @PrimaryKey(autoGenerate: true)
  int? id;

  @ColumnInfo(name: 'room_name')
  String roomName;

  Room(this.id, this.roomName);
}

@Entity(tableName: 'rel_room_cam', foreignKeys: [
  ForeignKey(
      childColumns: ['room_id'],
      parentColumns: ['id'],
      entity: Room,
      onDelete: ForeignKeyAction.cascade),
  ForeignKey(
      childColumns: ['cam_id'],
      parentColumns: ['id'],
      entity: Cam,
      onDelete: ForeignKeyAction.cascade)
])
class RoomCam {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  @ColumnInfo(name: 'room_id')
  final int roomId;

  @ColumnInfo(name: 'cam_id')
  final int camId;

  RoomCam(this.id, this.roomId, this.camId);
}

@dao
abstract class RoomDao {
  @insert
  Future<int> insertRoom(Room r);

  @delete
  Future<void> deleteRoom(Room r);

  @Query('SELECT * FROM room')
  Future<List<Room>> getRooms();

  @Query('SELECT * FROM room WHERE id = :id')
  Future<List<Room>> getRoomById(int id);

  @insert
  Future<int> insertRoomCam(RoomCam r);

  @delete
  Future<void> deleteRoomCam(RoomCam r);

  @Query('SELECT * FROM rel_room_cam WHERE room_id = :roomId')
  Future<List<RoomCam>> getCamIdsByRoom(int roomId);

  @Query(
      'SELECT * FROM cam WHERE id IN (SELECT cam_id FROM rel_room_cam WHERE room_id = :roomId)')
  Future<List<Cam>> getCamsByRoom(int roomId);

  @Query('SELECT * FROM rel_room_cam')
  Future<List<RoomCam>> getAll();
}

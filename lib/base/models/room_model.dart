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

import 'package:hospital_ai_client/base/interfaces/interfaces.dart';
import 'package:hospital_ai_client/base/models/dao/cam.dart';
import 'package:hospital_ai_client/base/models/dao/room.dart';

class RoomModel {
  Future<List<Room>> getAllRooms() {
    return appDB.roomDao.getRooms();
  }

  Future<Room> addRoom(String roomName) async {
    final room = Room(null, roomName);
    int id = await appDB.roomDao.insertRoom(room);
    return room..id = id;
  }

  Future<void> deleteRoom(Room room) async {
    await appDB.roomDao.deleteRoom(room);
  }

  Future<List<Cam>> getAllCamsByRoom(Room room) async {
    return await appDB.roomDao.getCamsByRoom(room.id!);
  }
}

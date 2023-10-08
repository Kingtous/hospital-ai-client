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

import 'dart:async';
import 'dart:typed_data';
import 'package:floor/floor.dart';
import 'package:hospital_ai_client/base/models/dao/alerts.dart';
import 'package:hospital_ai_client/base/models/dao/area.dart';
import 'package:hospital_ai_client/base/models/dao/cam.dart';
import 'package:hospital_ai_client/base/models/dao/room.dart';
import 'package:hospital_ai_client/base/models/dao/user.dart';
import 'package:hospital_ai_client/constants.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'db.g.dart';

@Database(
    version: kDbVersion,
    entities: [Area, Cam, User, AreaUser, AreaCam, Room, RoomCam, Alerts, Recorder])
abstract class AppDB extends FloorDatabase {
  AreaDao get areaDao;
  CamDao get camDao;
  AreaUserDao get areaUserDao;
  AreaCamDao get areaCamDao;
  UserDao get userDao;
  RoomDao get roomDao;
  AlertDao get alertDao;
  @Deprecated('暂时不用')
  RecorderDao get recorderDao;
}

final kMigrations = <Migration>[
];

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
import 'package:hospital_ai_client/base/models/dao/user.dart';

const kAreaKey = 'kArea';

@Entity(tableName: 'area')
class Area {
  @PrimaryKey(autoGenerate: true)
  int? id;
  @ColumnInfo(name: 'area_name')
  final String areaName;
  Area(this.id, this.areaName);

  @override
  String toString() {
    return "$id $areaName";
  }

  @override
  bool operator ==(Object other) {
    if (other is Area) {
      return id == other.id && this.areaName == other.areaName;
    } else {
      return false;
    }
  }
}

@Entity(tableName: 'rel_area_user', foreignKeys: [
  ForeignKey(
      childColumns: ['area_id'],
      parentColumns: ['id'],
      entity: Area,
      onDelete: ForeignKeyAction.cascade),
  ForeignKey(
      childColumns: ['user_id'],
      parentColumns: ['id'],
      entity: User,
      onDelete: ForeignKeyAction.cascade)
])
class AreaUser {
  @PrimaryKey(autoGenerate: true)
  int? id;

  @ColumnInfo(name: 'area_id')
  final int areaId;

  @ColumnInfo(name: 'user_id')
  final int userId;

  AreaUser(this.id, this.userId, this.areaId);

  @override
  String toString() {
    return "$id $userId $areaId";
  }
}

@Entity(tableName: 'rel_area_cam', foreignKeys: [
  ForeignKey(
      childColumns: ['area_id'],
      parentColumns: ['id'],
      entity: Area,
      onDelete: ForeignKeyAction.cascade),
  ForeignKey(
      childColumns: ['cam_id'],
      parentColumns: ['id'],
      entity: Cam,
      onDelete: ForeignKeyAction.cascade),
])
class AreaCam {
  @PrimaryKey(autoGenerate: true)
  int? id;

  @ColumnInfo(name: 'area_id')
  final int areaId;

  @ColumnInfo(name: 'cam_id')
  final int camId;

  AreaCam(this.id, this.areaId, this.camId);
}

@dao
abstract class AreaDao {
  @Query('SELECT * FROM area')
  Future<List<Area>> findAllAreas();

  @insert
  Future<int> insertArea(Area area);

  @delete
  Future<void> deleteArea(Area area);
}

@dao
abstract class AreaUserDao {
  @Query(
      'SELECT * from cam where id IN (SELECT cam_id FROM rel_area_cam where area_id=:areaId)')
  Future<List<Cam>> findAllCamUsersByRole(int areaId);

  @Query(
      'SELECT * from users where id IN (SELECT user_id FROM rel_area_user where area_id=:areaId)')
  Future<List<User>> findAllAreaUsersByArea(int areaId);

  @Query(
      'SELECT * from area where id IN (SELECT area_id FROM rel_area_user where user_id=:userId)')
  Future<List<Area>> findAllAreasByUser(int userId);

  @Query('SELECT * FROM rel_area_user where user_id=:userId')
  Future<List<AreaUser>> findAllAreaUsersByUser(int userId);

  @delete
  Future<void> deleteAreaUser(AreaUser area);

  @delete
  Future<void> deleteAreaUsers(List<AreaUser> area);

  @insert
  Future<List<int>> insertAreaUser(List<AreaUser> rels);

  @transaction
  Future<int> setRoles(User user, Iterable<Area> roles) async {
    final rels = await findAllAreaUsersByUser(user.id!);
    await deleteAreaUsers(rels);
    return (await insertAreaUser(
            roles.map((e) => AreaUser(null, user.id!, e.id!)).toList()))
        .length;
  }
}

@dao
abstract class AreaCamDao {
  @Query('SELECT * FROM rel_area_user')
  Future<List<AreaUser>> findAllAreaUsers();

  @Query(
      'select * from area where id IN (SELECT area_id FROM rel_area_user where user_id=:userId)')
  Future<List<Area>> findAllAreaUsersByUser(int userId);

  @insert
  Future<int> insertAreaUser(AreaUser area);

  @delete
  Future<void> deleteAreaUser(AreaUser area);
}

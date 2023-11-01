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

import 'dart:typed_data';
import 'package:floor/floor.dart';
import 'package:hospital_ai_client/base/models/dao/cam.dart';

enum AlertType { unknown, whiteShirt, other }

extension ToString on AlertType {
  String toHumanString() {
    switch (this) {
      case AlertType.unknown:
        return '未知';
      case AlertType.whiteShirt:
        return '未穿白大褂';
      case AlertType.other:
        return '其他';
      default:
        return '';
    }
  }
}

@Entity(tableName: 'alerts', foreignKeys: [
  ForeignKey(
      childColumns: ['cam_id'],
      parentColumns: ['id'],
      entity: Cam,
      onDelete: ForeignKeyAction.cascade)
])
class Alerts {
  @PrimaryKey(autoGenerate: true)
  int? id;

  @ColumnInfo(name: 'create_at')
  final int createAt;

  @ColumnInfo(name: 'img')
  final Uint8List? img;

  @ColumnInfo(name: 'alert_type')
  final int alertType;

  @ColumnInfo(name: 'cam_id')
  final int camId;

  @ColumnInfo(name: 'cam_name')
  final String camName;

  @ColumnInfo(name: 'room_id')
  final int roomId;

  @ColumnInfo(name: 'room_name')
  final String roomName;

  Alerts(this.id, this.createAt, this.img, this.camId, this.alertType,
      this.camName, this.roomId, this.roomName);
}

@dao
abstract class AlertDao {
  @insert
  Future<int> insertAlert(Alerts a);

  @delete
  Future<int> deleteAlert(Alerts a);

  @Query('SELECT * FROM alerts WHERE create_at BETWEEN :st AND :ed')
  Future<List<Alerts>> getAlertsFromTo(int st, int ed);

  @Query('SELECT * FROM alerts WHERE create_at >= :st')
  Future<List<Alerts>> getAlertsFrom(int st);

  
  // @ColumnInfo(name: 'create_at')
  // final int createAt;

  // @ColumnInfo(name: 'img')
  // final Uint8List img;

  // @ColumnInfo(name: 'alert_type')
  // final int alertType;

  // @ColumnInfo(name: 'cam_id')
  // final int camId;

  // @ColumnInfo(name: 'cam_name')
  // final String camName;

  // @ColumnInfo(name: 'room_id')
  // final int roomId;

  // @ColumnInfo(name: 'room_name')
  // final String roomName;

  @Query(
      'SELECT create_at, id, alert_type, cam_id, cam_name, room_id, room_name FROM alerts WHERE create_at >= :st')
  Future<List<Alerts>> getAlertsFromNoImg(int st);

  @Query('DELETE FROM alerts WHERE create_at <= :st')
  Future<int?> deleteAlertsBefore(int st);

  @Query(
      'SELECT * FROM alerts WHERE (create_at BETWEEN :st AND :ed) AND (cam_id IN (:cams))')
  Future<List<Alerts>> getAlertsInCamsFrom(List<int> cams, int st, int ed);

  @Query("DELETE FROM alerts WHERE create_at < datetime('now', '-15 days')")
  Future<int?> deleteOldAlerts();

  @Query('select create_at, id, alert_type, cam_id, cam_name, room_id, room_name FROM alerts where alert_type = 1')
  Future<List<Alerts>> getAlertsTypeNoImg();
}

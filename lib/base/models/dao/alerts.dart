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

@Entity(
  tableName: 'alerts',
)
class Alerts {
  @PrimaryKey(autoGenerate: true)
  int? id;

  @ColumnInfo(name: 'create_at')
  final int createAt;

  @ColumnInfo(name: 'img')
  final Uint8List img;

  @ColumnInfo(name: 'alert_type')
  final int alertType;

  @ColumnInfo(name: 'cam_id')
  final int camId;

  Alerts(this.id, this.createAt, this.img, this.camId, this.alertType);
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

  @Query('DELETE FROM alerts WHERE create_at <= :st')
  Future<void> deleteAlertsBefore(int st);
}

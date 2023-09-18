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

const kAreaKey = 'kArea';

@Entity(tableName: 'area')
class Area {
  @PrimaryKey(autoGenerate: true)
  int? id;
  @ColumnInfo(name: 'area_name')
  final String areaName;
  Area(this.areaName);
}

@dao
abstract class AreaDao {
  @Query('SELECT * FROM area')
  Future<List<Area>> findAllAreas();

  @insert
  Future<void> insertArea(Area area);
}

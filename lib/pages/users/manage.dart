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

import 'package:data_table_2/data_table_2.dart';
import 'package:fluent_ui/fluent_ui.dart';
// import 'package:flutter/material.dart' hide FilledButton, ButtonStyle;
import 'package:hospital_ai_client/base/interfaces/interfaces.dart';
import 'package:hospital_ai_client/base/models/dao/area.dart';
import 'package:hospital_ai_client/base/models/dao/user.dart';

class UserManagePage extends StatefulWidget {
  const UserManagePage({super.key});

  @override
  State<UserManagePage> createState() => _UserManagePageState();
}

class _UserManagePageState extends State<UserManagePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 8.0,
                ),
                Text(
                  '人员管理',
                  style: TextStyle(fontSize: 26),
                ),
                SizedBox(
                  height: 16.0,
                ),
                Expanded(child: UserTable())
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 用户表
class UserTable extends StatefulWidget {
  const UserTable({super.key});

  @override
  State<UserTable> createState() => _UserTableState();
}

class _UserTableState extends State<UserTable> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: userModel.getAllUsers(),
        builder: (context, data) {
          if (!data.hasData) {
            return Center(
              child: ProgressRing(),
            );
          }
          final users = data.data!;
          return Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '用户成员表',
                          style: TextStyle(fontSize: 20.0),
                        ),
                        Expanded(
                          child: CommandBar(
                              mainAxisAlignment: MainAxisAlignment.end,
                              primaryItems: [
                                CommandBarButton(
                                    onPressed: _onAdd,
                                    icon: Icon(FluentIcons.add),
                                    label: Text('添加人员'))
                              ]),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: buildUsers(users)),
                      ],
                    )
                  ],
                ),
              ),
            ],
          );
        });
  }

  void _onAdd() {}

  Widget buildUsers(List<User> users) {
    return Column(
      children: [
        ...users.map((user) => Row(
              children: [
                Expanded(child: UserTile(user: user)),
              ],
            ))
      ],
    );
  }
}

class UserTile extends StatelessWidget {
  final User user;
  const UserTile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Text('${user.id}'),
          flex: 3,
        ),
        Flexible(
          child: Text('${user.userName}'),
          flex: 3,
        ),
        Expanded(
          child: _buildOperBtns(),
          flex: 2,
        )
      ],
    );
  }

  Widget _buildOperBtns() {
    return Row(
      children: [
        Button(child: Text('修改密码'), onPressed: _toggleChangePassword),
        SizedBox(
          width: 2.0,
        ),
        FilledButton(child: Text('修改职责'), onPressed: _toggleEditAreas),
        SizedBox(
          width: 2.0,
        ),
        FilledButton(
          child: Text('删除用户'),
          onPressed: _toggleDeleteUser,
          style: ButtonStyle(backgroundColor: ButtonState.all(Colors.red)),
        ),
      ],
    );
  }

  _toggleChangePassword() {}

  _toggleEditAreas() {}

  _toggleDeleteUser() {

  }
}

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

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';

class UserManagePage extends StatefulWidget {
  const UserManagePage({super.key});

  @override
  State<UserManagePage> createState() => _UserManagePageState();
}

class _UserManagePageState extends State<UserManagePage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '用户管理',
          style: TextStyle(fontSize: 26),
        ),
        Expanded(child: UserTable())
      ],
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
    return Column(
      children: [
        CommandBar(primaryItems: [
          CommandBarButton(onPressed: _onAdd, icon: Icon(FluentIcons.add))
        ])
      ],
    );
  }

  void _onAdd() {
  }
}

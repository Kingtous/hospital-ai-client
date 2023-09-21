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

import 'package:crypto/crypto.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:get/get.dart';
// import 'package:flutter/material.dart' hide FilledButton, ButtonStyle;
import 'package:hospital_ai_client/base/interfaces/interfaces.dart';
import 'package:hospital_ai_client/base/models/dao/area.dart';
import 'package:hospital_ai_client/base/models/dao/user.dart';
import 'package:hospital_ai_client/constants.dart';

class UserManagePage extends StatefulWidget {
  const UserManagePage({super.key});

  @override
  State<UserManagePage> createState() => _UserManagePageState();
}

class _UserManagePageState extends State<UserManagePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: kBgColor),
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
  List<String> kTableColumnNames = ['编号', '姓名', '手机号', '角色', '操作'];

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
          return Column(
            children: [
              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FilledButton(
                        onPressed: _onAdd,
                        style: ButtonStyle(
                            backgroundColor: ButtonState.all(kBlueColor)),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Row(
                            children: [
                              Icon(FluentIcons.add_bookmark),
                              SizedBox(
                                width: 8.0,
                              ),
                              Text('添加账号'),
                            ],
                          ),
                        )),
                    SizedBox(
                      width: 20.0,
                    ),
                    SizedBox(
                        width: 320,
                        child: TextBox(
                          prefix:
                              Icon(FluentIcons.search).marginOnly(left: 8.0),
                          placeholder: '请输入员工姓名、登录账号进行搜索',
                        ))
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: Colors.white),
                  margin: EdgeInsets.only(top: 16.0),
                  child: buildUsers(users),
                ),
              )
            ],
          );
        });
  }

  void _onAdd() {
    showDialog(
        context: context,
        builder: (context) => AddUserDialog(
              onAddUser: (user, areas) async {
                final res = await userModel.registerWithRoles(
                    user.userName, user.passwordMd5, user.phone, areas);
                setState(() {});
                if (res == null) {
                  warning(context, '添加失败');
                  return false;
                } else {
                  success(context, '添加成功');
                  return true;
                }
              },
            ));
  }

  void _onEditPassword() {
    // showDialog(
    //     context: context,
    //     builder: (context) => AddUserDialog(
    //           onAddUser: (user, areas) async {
    //             final res = await userModel.registerWithRoles(
    //                 user.userName, user.passwordMd5, user.phone, areas);
    //             if (res == null) {
    //               warning(context, '添加失败');
    //             } else {
    //               success(context, '添加成功');
    //             }
    //           },
    //         ));
  }

  Color getColor(int index) {
    return index % 2 == 0 ? kTableGreyColor : Colors.white;
  }

  Widget buildUsers(List<User> users) {
    List<Widget> rows = [];
    for (var i = 0; i < users.length; i++) {
      final user = users[i];
      rows.add(UserTile(
        user: user,
        bgColor: getColor(i + 1),
        onUserDelete: () async {
          await userModel.deleteUser(user);
          setState(() {});
        },
        onUserEditPassword: () {
          // TODO: 用户修改密码
        },
        onConfigureRoles: () {
          // TODO: 配置权限
        },
      ));
    }

    return rows.isEmpty
        ? Center(
            child: Text('无账号'),
          )
        : SingleChildScrollView(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        decoration: BoxDecoration(color: kTableGreyColor),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ...kTableColumnNames.map((e) => Expanded(
                                child: Text('$e').paddingOnly(left: 4.0)))
                          ],
                        ),
                      ),
                      ...rows
                    ],
                  ).paddingAll(16.0),
                ),
              ],
            ),
          );
  }
}

class UserTile extends StatelessWidget {
  final User user;
  final Color bgColor;
  final VoidCallback onUserDelete;
  final VoidCallback onUserEditPassword;
  final VoidCallback onConfigureRoles;
  const UserTile(
      {super.key,
      required this.user,
      required this.bgColor,
      required this.onUserDelete,
      required this.onUserEditPassword,
      required this.onConfigureRoles});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(color: bgColor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Text('${user.id}').paddingOnly(left: 4.0),
            flex: 1,
          ),
          Expanded(
            child: Text(
              '${user.userName}',
              textAlign: TextAlign.start,
            ).paddingOnly(left: 4.0),
            flex: 1,
          ),
          Expanded(
            child: Text('${user.phone}').paddingOnly(left: 4.0),
            flex: 1,
          ),
          Expanded(
            child: _buildOperRoleBtn(),
            flex: 1,
          ),
          Expanded(
            child: _buildOperBtns(),
            flex: 1,
          )
        ],
      ),
    );
  }

  Widget _buildOperRoleBtn() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        FilledButton(
            child: Text('配置角色'),
            onPressed:
                user.phone == kDefaultAdminName ? null : _toggleEditAreas),
      ],
    );
  }

  Widget _buildOperBtns() {
    return Wrap(
      children: [
        Button(child: Text('修改密码'), onPressed: _toggleChangePassword),
        SizedBox(
          width: 4.0,
        ),
        FilledButton(
          child: Text('删除用户'),
          onPressed: user.phone == kDefaultAdminName ? null : _toggleDeleteUser,
          style: ButtonStyle(
              backgroundColor: ButtonState.all(
                  user.phone == kDefaultAdminName ? Colors.grey : Colors.red)),
        ),
      ],
    );
  }

  _toggleChangePassword() {
    onUserEditPassword.call();
  }

  _toggleEditAreas() {
    onConfigureRoles.call();
  }

  _toggleDeleteUser() {
    onUserDelete.call();
  }
}

class AddUserDialog extends StatelessWidget {
  final RxSet<Area> roles = RxSet<Area>();
  final Rx<User> user = Rx<User>(User(null, "", "", ""));
  final Future<bool> Function(User, List<Area> roles) onAddUser;
  AddUserDialog({super.key, required this.onAddUser});

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('新增账号'),
        ],
      ),
      constraints: BoxConstraints.tight(Size(540, 420)),
      content: _buildDialog(context),
      actions: [
        FilledButton(child: Text('保存'), onPressed: () => _onStore(context)),
        Button(
          child: Text('取消'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }

  _onStore(BuildContext context) async {
    if (user.value.phone.isEmpty ||
        user.value.userName.isEmpty ||
        user.value.passwordMd5.isEmpty) {
      warning(context, '姓名/手机号/密码不能为空');
      return;
    }
    if (roles.isEmpty) {
      warning(context, '角色不能为空');
      return;
    }
    final res = await onAddUser.call(user.value, roles.toList(growable: false));
    if (res) {
      Navigator.of(context).pop();
    }
  }

  Widget _buildDialog(BuildContext context) {
    return SizedBox(
      width: 540,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              SizedBox(
                  width: 100,
                  child: Text(
                    '姓名',
                    textAlign: TextAlign.end,
                  )),
              SizedBox(
                width: 16.0,
              ),
              Expanded(child: TextBox(
                onChanged: (v) {
                  user.value.userName = v;
                },
              )),
              SizedBox(
                width: 69.0,
              ),
            ],
          ),
          SizedBox(
            height: 16.0,
          ),
          Row(
            children: [
              SizedBox(
                  width: 100, child: Text('手机号', textAlign: TextAlign.end)),
              SizedBox(
                width: 16.0,
              ),
              Expanded(child: TextBox(
                onChanged: (v) {
                  user.value.phone = v;
                },
              )),
              SizedBox(
                width: 69.0,
              ),
            ],
          ),
          SizedBox(
            height: 16.0,
          ),
          Row(
            children: [
              SizedBox(
                  width: 100, child: Text('原始密码', textAlign: TextAlign.end)),
              SizedBox(
                width: 16.0,
              ),
              Expanded(child: TextBox(
                onChanged: (v) {
                  // 这里用的明文
                  user.value.passwordMd5 = v;
                },
              )),
              SizedBox(
                width: 69.0,
              ),
            ],
          ),
          SizedBox(
            height: 16.0,
          ),
          FutureBuilder(
              future: roleModel.getAllRoles(),
              builder: (context, data) {
                if (!data.hasData) {
                  return ProgressBar();
                }
                final allRoles = data.data!;
                return Row(
                  children: [
                    SizedBox(
                        width: 100,
                        child: Text(
                          '角色',
                          textAlign: TextAlign.end,
                        )),
                    SizedBox(
                      width: 16.0,
                    ),
                    Expanded(
                        child: Obx(
                      () => Wrap(
                        spacing: 20,
                        children: allRoles
                            .map((role) => Checkbox(
                                checked: roles.contains(role),
                                content: Text('${role.areaName}'),
                                onChanged: (r) {
                                  r = r ?? false;
                                  if (r) {
                                    roles.add(role);
                                  } else {
                                    roles.remove(role);
                                  }
                                }))
                            .toList(),
                      ),
                    ))
                  ],
                );
              })
        ],
      ),
    );
  }
}

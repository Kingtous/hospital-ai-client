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
      decoration: const BoxDecoration(color: kBgColor),
      padding: const EdgeInsets.all(16.0),
      child: const Row(
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
            return const Center(
              child: ProgressRing(),
            );
          }
          final users = data.data!;
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
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
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
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
                    const SizedBox(
                      width: 20.0,
                    ),
                    SizedBox(
                        width: 320,
                        child: TextBox(
                          prefix:
                              const Icon(FluentIcons.search).marginOnly(left: 8.0),
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
                  margin: const EdgeInsets.only(top: 16.0),
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
          showDialog(
              context: context,
              builder: (context) => UserChangePasswordDialog(
                    user: user,
                  ));
        },
        onConfigureRoles: () {
          // TODO: 配置权限
          showDialog(
              context: context,
              barrierDismissible: true,
              dismissWithEsc: true,
              builder: (context) => UserRoleDialog(
                    user: user,
                  ));
        },
      ));
    }

    return rows.isEmpty
        ? const Center(
            child: Text('无账号'),
          )
        : SingleChildScrollView(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        decoration: const BoxDecoration(color: kTableGreyColor),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ...kTableColumnNames.map((e) => Expanded(
                                child: Text(e).paddingOnly(left: 4.0)))
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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(color: bgColor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Text('${user.id}').paddingOnly(left: 4.0),
          ),
          Expanded(
            flex: 1,
            child: Text(
              user.userName,
              textAlign: TextAlign.start,
            ).paddingOnly(left: 4.0),
          ),
          Expanded(
            flex: 1,
            child: Text(user.phone).paddingOnly(left: 4.0),
          ),
          Expanded(
            flex: 1,
            child: _buildOperRoleBtn(),
          ),
          Expanded(
            flex: 1,
            child: _buildOperBtns(),
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
            onPressed:
                user.phone == kDefaultAdminName ? null : _toggleEditAreas,
            child: const Text('配置角色')),
      ],
    );
  }

  Widget _buildOperBtns() {
    return Wrap(
      children: [
        Button(onPressed: _toggleChangePassword, child: const Text('修改密码')),
        const SizedBox(
          width: 4.0,
        ),
        FilledButton(
          onPressed: user.phone == kDefaultAdminName ? null : _toggleDeleteUser,
          style: ButtonStyle(
              backgroundColor: ButtonState.all(
                  user.phone == kDefaultAdminName ? Colors.grey : Colors.red)),
          child: const Text('删除用户'),
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
      title: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('新增账号'),
        ],
      ),
      constraints: BoxConstraints.tight(const Size(540, 420)),
      content: _buildDialog(context),
      actions: [
        FilledButton(child: const Text('保存'), onPressed: () => _onStore(context)),
        Button(
          child: const Text('取消'),
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
              const SizedBox(
                  width: 100,
                  child: Text(
                    '姓名',
                    textAlign: TextAlign.end,
                  )),
              const SizedBox(
                width: 16.0,
              ),
              Expanded(child: TextBox(
                onChanged: (v) {
                  user.value.userName = v;
                },
              )),
              const SizedBox(
                width: 69.0,
              ),
            ],
          ),
          const SizedBox(
            height: 16.0,
          ),
          Row(
            children: [
              const SizedBox(
                  width: 100, child: Text('手机号', textAlign: TextAlign.end)),
              const SizedBox(
                width: 16.0,
              ),
              Expanded(child: TextBox(
                onChanged: (v) {
                  user.value.phone = v;
                },
              )),
              const SizedBox(
                width: 69.0,
              ),
            ],
          ),
          const SizedBox(
            height: 16.0,
          ),
          Row(
            children: [
              const SizedBox(
                  width: 100, child: Text('原始密码', textAlign: TextAlign.end)),
              const SizedBox(
                width: 16.0,
              ),
              Expanded(child: TextBox(
                onChanged: (v) {
                  // 这里用的明文
                  user.value.passwordMd5 = v;
                },
              )),
              const SizedBox(
                width: 69.0,
              ),
            ],
          ),
          const SizedBox(
            height: 16.0,
          ),
          FutureBuilder(
              future: roleModel.getAllRoles(),
              builder: (context, data) {
                if (!data.hasData) {
                  return const ProgressBar();
                }
                final allRoles = data.data!;
                return Row(
                  children: [
                    const SizedBox(
                        width: 100,
                        child: Text(
                          '角色',
                          textAlign: TextAlign.end,
                        )),
                    const SizedBox(
                      width: 16.0,
                    ),
                    Expanded(
                        child: Obx(
                      () => Wrap(
                        spacing: 20,
                        runSpacing: 4,
                        children: allRoles
                            .map((role) => Checkbox(
                                checked: roles.contains(role),
                                content: Text(role.areaName),
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

class UserChangePasswordDialog extends StatelessWidget {
  final User user;
  final RxString originPassword = "".obs;
  final RxString password = "".obs;
  final RxString repeatPassword = "".obs;
  UserChangePasswordDialog({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      child: ContentDialog(
        title: const Text('修改密码'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 8.0,
            ),
            userModel.user?.userName == kDefaultAdminName
                ? const Offstage()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('原密码'),
                      SizedBox(
                          width: 200,
                          child: TextBox(
                            onChanged: (v) {
                              originPassword.value = v;
                            },
                          ))
                    ],
                  ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('新密码'),
                SizedBox(
                    width: 200,
                    child: TextBox(
                      onChanged: (s) {
                        password.value = s;
                      },
                    ))
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('确认密码'),
                SizedBox(
                    width: 200,
                    child: TextBox(
                      onChanged: (s) {
                        repeatPassword.value = s;
                      },
                    ))
              ],
            ),
          ],
        ),
        actions: [
          FilledButton(
              child: const Text('提交'),
              onPressed: () async {
                if (repeatPassword.value != password.value) {
                  warning(context, '两次输入密码不一致');
                  return;
                }
                if (password.value.isEmpty) {
                  warning(context, '密码不能为空');
                  return;
                }
                if (userModel.isAdmin) {
                  unawaited(userModel.updatePassword(user, password.value));
                } else {
                  final res = await userModel.updatePasswordAsUser(
                      originPassword.value, user, password.value);
                  if (!res) {
                    warning(context, '原密码验证失败');
                    return;
                  }
                }

                Navigator.pop(context);
              }),
          Button(
              child: const Text('取消'),
              onPressed: () {
                Navigator.pop(context);
              })
        ],
      ),
    );
  }
}

class UserRoleDialog extends StatelessWidget {
  final User user;
  const UserRoleDialog({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      child: ContentDialog(
        title: const Text('权限编辑'),
        content: FutureBuilder(
            future: Future.wait(
                [roleModel.getAllRoles(), roleModel.getRolesByUser(user)]),
            builder: (context, data) {
              if (!data.hasData) {
                return const ProgressBar();
              } else {
                var [allRoles, currentRoles] = data.data!;
                final currentRolesObx = currentRoles.obs;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...allRoles
                        .map((e) => Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Row(
                                children: [
                                  Obx(
                                    () => Checkbox(
                                      checked: currentRolesObx.contains(e),
                                      onChanged: (v) {
                                        v = v ?? false;
                                        if (v) {
                                          currentRolesObx.add(e);
                                        } else {
                                          currentRolesObx.remove(e);
                                        }
                                      },
                                      content: Text(e.areaName),
                                    ),
                                  )
                                ],
                              ),
                            ))
                        .toList(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FilledButton(
                            child: const Text('提交'),
                            onPressed: () async {
                              final res = await roleModel.setRoles(
                                  user, currentRolesObx);
                              if (res) {
                                success(context, '修改角色成功');
                                Navigator.pop(context);
                              } else {
                                warning(context, '失败');
                              }
                            }),
                        const SizedBox(
                          width: 4.0,
                        ),
                        Button(
                            child: const Text('取消'),
                            onPressed: () {
                              Navigator.pop(context);
                            })
                      ],
                    )
                  ],
                );
              }
            }),
      ),
    );
  }
}

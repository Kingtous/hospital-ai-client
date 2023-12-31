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
import 'dart:io';
import 'dart:typed_data';

import 'package:bruno/bruno.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
// import 'package:flutter/material.dart' hide FilledButton, ButtonStyle;
import 'package:hospital_ai_client/base/interfaces/interfaces.dart';
import 'package:hospital_ai_client/base/models/dao/alerts.dart';
import 'package:hospital_ai_client/base/models/dao/area.dart';
import 'package:hospital_ai_client/base/models/dao/user.dart';
import 'package:hospital_ai_client/components/table.dart';
import 'package:hospital_ai_client/constants.dart';
import 'package:path/path.dart' hide context;

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
  String inputText = "";
  List<User> selectedUsers = [];
  bool flag = true;

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
          if (flag) {
            selectedUsers = data.data!;
            flag = false;
          }

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
                    RawKeyboardListener(
                      focusNode: FocusNode(),
                      onKey: (RawKeyEvent event) {
                        if (event.logicalKey == LogicalKeyboardKey.enter) {
                          _selectUsers(inputText).then((value) {
                            setState(() {
                              selectedUsers = value;
                            });
                          });
                        }
                      },
                      child: Row(
                        children: [
                          SizedBox(
                              width: 320,
                              child: TextBox(
                                prefix: const Icon(FluentIcons.search)
                                    .marginOnly(left: 8.0),
                                placeholder: '请输入员工姓名、登录账号进行搜索',
                                controller:
                                    TextEditingController(text: inputText),
                                onChanged: (s) {
                                  inputText = s;
                                },
                              )),
                          SizedBox(
                            width: 5,
                          ),
                          GestureDetector(
                            onTap: () {
                              inputText = '';
                              setState(() {
                                userModel
                                    .getAllUsers()
                                    .then((value) => selectedUsers = value);
                              });
                              print("object");
                            },
                            child: Icon(FluentIcons.delete),
                          ),
                        ],
                      ),
                    ),
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
                  child: buildUsers(selectedUsers),
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

  Future<List<User>> _selectUsers(String text) async {
    List<User> res = await userModel.searchByNameOrPhone(text);
    print(selectedUsers.length);
    return res;
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
                            ...kTableColumnNames.map((e) =>
                                Expanded(child: Text(e).paddingOnly(left: 4.0)))
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
      style: kContentDialogStyle,
      // title: ,
      constraints: BoxConstraints.tight(const Size(540, 420)),
      content: Frame(
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('新增账号'),
            ],
          ),
          content: Column(
            children: [
              Expanded(child: _buildDialog(context)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: FilledButton(
                        child: const Text('保存'),
                        onPressed: () => _onStore(context)),
                  ),
                  SizedBox(
                    width: 16.0,
                  ),
                  Expanded(
                    child: Button(
                      child: const Text('取消'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  )
                ],
              )
            ],
          )),
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
                        child: Wrap(
                      spacing: 20,
                      runSpacing: 4,
                      children: allRoles
                          .map((role) => Obx(
                                () => Checkbox(
                                    checked: roles.contains(role),
                                    content: Text(role.areaName),
                                    onChanged: (r) {
                                      r = r ?? false;
                                      if (r) {
                                        roles.add(role);
                                      } else {
                                        roles.remove(role);
                                      }
                                    }),
                              ))
                          .toList(),
                    ))
                  ],
                );
              })
        ],
      ),
    );
  }
}

class AlertDetailDialog extends StatelessWidget {
  final int id;
  const AlertDetailDialog({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      style: kContentDialogStyle,
      constraints: BoxConstraints.loose(Size(1000, 500)),
      content: Container(
        child: Frame(
            title: Text('报警详情'),
            content: FutureBuilder(
                future: alertsModel.getFullAlerts(id),
                builder: (context, data) {
                  if (!data.hasData) {
                    return Center(
                        child: SizedBox(
                            width: 100,
                            height: 100,
                            child: const ProgressRing()));
                  } else {
                    final alert = data.data!;
                    final t =
                        DateTime.fromMillisecondsSinceEpoch(alert.createAt);
                    return Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.black,
                                  border: Border.all(color: Colors.red)),
                              child: Image.memory(
                                alert.img ?? Uint8List(0),
                                width: 500,
                                height: 300,
                                errorBuilder: (context, _, st) {
                                  return Container();
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 32.0,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('报警科室：${alert.camName}',
                                    style: kTextStyle),
                                SizedBox(
                                  height: 16.0,
                                ),
                                Text.rich(TextSpan(children: [
                                  TextSpan(text: '报警类型：', style: kTextStyle),
                                  TextSpan(
                                      text:
                                          '${AlertType.values[alert.alertType].toHumanString()}',
                                      style: kTextStyle.copyWith(
                                          color: Colors.red)),
                                ])),
                                SizedBox(
                                  height: 16.0,
                                ),
                                Text(
                                    '报警时间：${t.year}年${t.month}年${t.day}日 ${t.hour}时${t.minute}分${t.second}秒',
                                    style: kTextStyle),
                                SizedBox(
                                  height: 8.0,
                                ),
                                Row(children: [
                                  Button(
                                      child: Text('导出'),
                                      onPressed: () {
                                        if (alert.img == null) {
                                          return;
                                        }
                                        filePicker
                                            .saveFile(
                                                fileName:
                                                    "${alert.camName}-${AlertType.values[alert.alertType].toHumanString()}-${t.year}年${t.month}年${t.day}日 ${t.hour}时${t.minute}分${t.second}秒.png")
                                            .then((path) {
                                          if (path == null) {
                                            return;
                                          }
                                          final f = File(path);
                                          if (!f.existsSync()) {
                                            f.createSync(recursive: true);
                                          }
                                          f.writeAsBytes(alert.img!);
                                          BrnToast.show('已保存至${path}', context);
                                        });
                                      })
                                ])
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  }
                })),
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
    return ContentDialog(
        // width: 500,
        // height: 500,
        // color: Colors.white,
        style: kContentDialogStyle,
        constraints: BoxConstraints.loose(Size(500, 400)),
        content: Container(
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(12.0)),
          child: Frame(
            title: const Text('修改密码'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 16.0,
                ),
                userModel.user?.userName == kDefaultAdminName
                    ? const Offstage()
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 80, child: const Text('原始密码')),
                          const SizedBox(
                            width: 8.0,
                          ),
                          SizedBox(
                              width: 200,
                              child: TextBox(
                                onChanged: (v) {
                                  originPassword.value = v;
                                },
                              ))
                        ],
                      ),
                SizedBox(
                  height: 16.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 80, child: const Text('新密码')),
                    const SizedBox(
                      width: 8.0,
                    ),
                    SizedBox(
                        width: 200,
                        child: TextBox(
                          onChanged: (s) {
                            password.value = s;
                          },
                        ))
                  ],
                ),
                SizedBox(
                  height: 16.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 80, child: const Text('确认密码')),
                    const SizedBox(
                      width: 8.0,
                    ),
                    SizedBox(
                        width: 200,
                        child: TextBox(
                          onChanged: (s) {
                            repeatPassword.value = s;
                          },
                        ))
                  ],
                ),
                SizedBox(
                  height: 16.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 140,
                      height: 34,
                      child: FilledButton(
                          child: Center(child: const Text('提交')),
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
                              unawaited(userModel.updatePassword(
                                  user, password.value));
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
                    ),
                    SizedBox(
                      width: 30,
                    ),
                    SizedBox(
                      width: 140,
                      height: 34,
                      child: Button(
                          child: Center(child: const Text('取消')),
                          onPressed: () {
                            Navigator.pop(context);
                          }),
                    )
                  ],
                )
              ],
            ),
          ),
        ));
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
        style: kContentDialogStyle,
        constraints: BoxConstraints.tight(Size(400, 500)),
        // title: ,
        content: Frame(
          title: const Text('角色配置'),
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
                      Expanded(
                        child: ListView(
                          children: [
                            ...allRoles
                                .map((e) => Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Row(
                                        children: [
                                          Obx(
                                            () => Checkbox(
                                              checked:
                                                  currentRolesObx.contains(e),
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
                          ],
                        ),
                      ),
                      Row(
                        // mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: FilledButton(
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
                          ),
                          const SizedBox(
                            width: 16.0,
                          ),
                          Expanded(
                            child: Button(
                                child: const Text('取消'),
                                onPressed: () {
                                  Navigator.pop(context);
                                }),
                          )
                        ],
                      )
                    ],
                  );
                }
              }),
        ),
      ),
    );
  }
}

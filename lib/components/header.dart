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
import 'package:get/get.dart';
import 'package:hospital_ai_client/base/interfaces/interfaces.dart';
import 'package:hospital_ai_client/constants.dart';
import 'package:hospital_ai_client/pages/users/manage.dart';
import 'package:window_manager/window_manager.dart';

class AppHeader extends StatefulWidget {
  final bool isLanding;
  const AppHeader({super.key, this.isLanding = false});

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> {
  @override
  Widget build(BuildContext context) {
    return DragToMoveArea(
      child: Container(
        height: kHeaderHeight,
        decoration: BoxDecoration(color: Colors.blue),
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Row(
            children: [
              const Icon(
                FluentIcons.security_camera,
                color: Colors.white,
              ),
              const SizedBox(
                width: 16.0,
              ),
              const Text(
                '慧眼AI管理平台',
                style: TextStyle(color: Colors.white),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!widget.isLanding)
                    const AppHeaderAvatar(),
                    WindowCaptionButton.minimize(
                      brightness: Brightness.dark,
                      onPressed: () {
                        windowManager.minimize();
                      },
                    ),
                    WindowCaptionButton.maximize(
                      brightness: Brightness.dark,
                      onPressed: () async {
                        if (await windowManager.isMaximized()) {
                          windowManager.unmaximize();
                        } else {
                          windowManager.maximize();
                        }
                      },
                    ),
                    WindowCaptionButton.close(
                        brightness: Brightness.dark,
                        onPressed: () {
                          windowManager.close();
                        })
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class AppHeaderAvatar extends StatefulWidget {
  const AppHeaderAvatar({super.key});

  @override
  State<AppHeaderAvatar> createState() => _AppHeaderAvatarState();
}

class _AppHeaderAvatarState extends State<AppHeaderAvatar> {
  final controller = FlyoutController();
  @override
  Widget build(BuildContext context) {
    final user = userModel.user;
    final isHovered = false.obs;
    return user == null
        ? const Offstage()
        : Obx(
            () => MouseRegion(
              onEnter: (_) => isHovered.value = true,
              onExit: (_) => isHovered.value = false,
              onHover: (_) {
                isHovered.value = true;
                _onAvatarClicked();
              },
              child: FlyoutTarget(
                controller: controller,
                child: GestureDetector(
                  onTap: _onAvatarClicked,
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: isHovered.value
                            ? Colors.grey.withAlpha(75)
                            : Colors.grey.withAlpha(50)),
                    child: Row(
                      children: [
                        const Icon(
                          FluentIcons.user_event,
                          color: Colors.white,
                        ),
                        const SizedBox(
                          width: 8.0,
                        ),
                        Text(
                          '${user.userName} 您好',
                          style: const TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onAvatarClicked() {
    controller.showFlyout(
        dismissOnPointerMoveAway: true,
        builder: (context) => MenuFlyout(
              items: [
                MenuFlyoutItem(text: const Text('登出'), onPressed: _logout),
                MenuFlyoutItem(
                    text: const Text('修改密码'), onPressed: _changePassword)
              ],
            ));
  }

  void _logout() {
    userModel.logout(context);
  }

  void _changePassword() {
    showDialog(
        context: context,
        builder: (context) => UserChangePasswordDialog(user: userModel.user!));
  }
}

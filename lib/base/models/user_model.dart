import 'package:crypto/crypto.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_ai_client/base/interfaces/interfaces.dart';
import 'package:hospital_ai_client/base/models/dao/user.dart';
import 'package:hospital_ai_client/constants.dart';

class UserModel {
  // 当前登录的用户
  User? _user;
  User? get user => _user;

  bool get isLogin => _user != null;
  set user(User? user) {
    _user = user;
  }

  Future<void> init() async {
    // create super admin
    final admin = await appDB.userDao.getUserByUserName(kDefaultAdminName);
    if (admin == null) {
      await appDB.userDao.createUser(User(null, kDefaultAdminName,
          md5.convert(kDefaultAdminPassword.codeUnits).toString()));
    }
  }

  // 登录
  Future<bool> login(String userName, String password) async {
    final user = await appDB.userDao.getUserByUserName(userName);
    if (user == null) {
      return false;
    }
    final md5String = md5.convert(password.codeUnits).toString();
    if (user.passwordMd5 == md5String) {
      _user = user;
      return true;
    } else {
      return false;
    }
  }

  // 注册
  Future<User?> register(String userName, String password) async {
    if (!isLogin) {
      return null;
    }
    if (_user!.userName != kDefaultAdminName) {
      return null;
    }
    final user =
        User(null, userName, md5.convert(password.codeUnits).toString());
    final userId = await appDB.userDao.createUser(user);
    return user..id = userId;
  }

  Future<void> logout(BuildContext context) async {
    _user = null;
    context.goNamed('login');
  }
}

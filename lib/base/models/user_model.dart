import 'package:crypto/crypto.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_ai_client/base/interfaces/interfaces.dart';
import 'package:hospital_ai_client/base/models/dao/area.dart';
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

  bool get isAdmin => isLogin ? _user?.phone == kDefaultAdminName : false;

  Future<void> init() async {
    // create super admin
    final admin = await appDB.userDao.getUserByUserName(kDefaultAdminName);
    if (admin == null) {
      await appDB.userDao.createUser(User(
          null,
          kDefaultAdminName,
          kDefaultAdminName,
          md5.convert(kDefaultAdminPassword.codeUnits).toString()));
    }
  }

  // 登录
  Future<bool> login(String phone, String password) async {
    final user = await appDB.userDao.getUserByPhone(phone);
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

  Future<List<User>> getAllUsers() async {
    return appDB.userDao.getUsers();
  }

  // 注册
  Future<User?> register(String userName, String password, String phone) async {
    if (!isLogin) {
      return null;
    }
    if (_user!.userName != kDefaultAdminName) {
      return null;
    }
    final user =
        User(null, userName, phone, md5.convert(password.codeUnits).toString());
    final userId = await appDB.userDao.createUser(user);
    return user..id = userId;
  }

  Future<User?> registerWithRoles(
      String userName, String password, String phone, List<Area> roles) async {
    if (!isLogin) {
      return null;
    }
    if (_user!.userName != kDefaultAdminName) {
      return null;
    }
    final user =
        User(null, userName, phone, md5.convert(password.codeUnits).toString());
    final userId = await appDB.userDao.createUserWithRoles(user, roles);
    return user..id = userId;
  }

  Future<List<User>> searchByNameOrPhone(String text) async{
    List<User> res = [];
    res.addAll(await appDB.userDao.getAllUserByUserNameOrPhone(text) );
    return res;
  }

  Future<void> updateUser(User user) async {
    await appDB.userDao.updateUser(user);
  }

  Future<void> updatePassword(User user, String password) async {
    final md5Str = md5.convert(password.codeUnits).toString();
    await appDB.userDao.updateUser(user..passwordMd5 = md5Str);
  }

  Future<bool> updatePasswordAsUser(
      String originPassword, User user, String password) async {
    if (user.passwordMd5 != md5.convert(originPassword.codeUnits).toString()) {
      return false;
    }
    final md5Str = md5.convert(password.codeUnits).toString();
    await appDB.userDao.updateUser(user..passwordMd5 = md5Str);
    return true;
  }

  Future<void> logout(BuildContext context) async {
    _user = null;
    context.goNamed('login');
  }

  Future<bool> deleteUser(User user) async {
    return (await appDB.userDao.deleteUser(user)) > 0;
  }
}

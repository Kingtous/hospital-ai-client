import 'package:floor/floor.dart';
import 'package:hospital_ai_client/base/models/dao/area.dart';

@Entity(tableName: 'users')
class User {
  @PrimaryKey(autoGenerate: true)
  int? id;
  @ColumnInfo(name: 'user_name')
  String userName;
  @ColumnInfo(name: 'phone')
  String phone;
  @ColumnInfo(name: 'pwd_md5')
  String passwordMd5;

  User(this.id, this.userName, this.phone, this.passwordMd5);
}

@dao
abstract class UserDao {
  @Query('select * from users')
  Future<List<User>> getUsers();

  @Query('select * from users where id = :id')
  Future<void> getUser(int id);

  @Query('select * from users where user_name = :userName')
  Future<User?> getUserByUserName(String userName);
  @Query('select * from users where phone = :phone')
  Future<User?> getUserByPhone(String phone);

  @Query("SELECT * FROM users WHERE user_name LIKE '%' || :text || '%' OR phone LIKE '%' || :text || '%'")
  Future<List<User>> getAllUserByUserNameOrPhone(String text);


  @update
  Future<void> updateUser(User user);

  @insert
  Future<int> createUser(User user);

  @insert
  Future<int> insertAreaUser(AreaUser area);

  Future<void> insertAreaUsers(List<AreaUser> rels) async {
    await Future.wait(rels.map((e) => insertAreaUser(e)));
  }

  @transaction
  Future<int> createUserWithRoles(User user, List<Area> areas) async {
    final userId = await createUser(user);
    await insertAreaUsers(areas
        .map((e) => AreaUser(null, userId, e.id!))
        .toList(growable: false));
    return userId;
  }

  @delete
  Future<int> deleteUser(User user);
}

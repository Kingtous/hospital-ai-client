import 'package:floor/floor.dart';

@Entity(tableName: 'users')
class User {
  @PrimaryKey(autoGenerate: true)
  int? id;
  @ColumnInfo(name: 'user_name')
  final String userName;
  @ColumnInfo(name: 'pwd_md5')
  final String passwordMd5;

  User(this.id, this.userName, this.passwordMd5);
}

@dao
abstract class UserDao {
  @Query('select * from users')
  Future<List<User>> getUsers();

  @Query('select * from users where id = :id')
  Future<void> getUser(int id);

  @Query('select * from users where user_name = :userName')
  Future<User?> getUserByUserName(String userName);

  @insert
  Future<int> createUser(User user);

  @delete
  Future<void> deleteUser(User user);
}

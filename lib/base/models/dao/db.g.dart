// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

// ignore: avoid_classes_with_only_static_members
class $FloorAppDB {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDBBuilder databaseBuilder(String name) => _$AppDBBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDBBuilder inMemoryDatabaseBuilder() => _$AppDBBuilder(null);
}

class _$AppDBBuilder {
  _$AppDBBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$AppDBBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$AppDBBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<AppDB> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDB();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDB extends AppDB {
  _$AppDB([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  AreaDao? _areaDaoInstance;

  CamDao? _camDaoInstance;

  AreaUserDao? _areaUserDaoInstance;

  AreaCamDao? _areaCamDaoInstance;

  UserDao? _userDaoInstance;

  RoomDao? _roomDaoInstance;

  AlertDao? _alertDaoInstance;

  RecorderDao? _recorderDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 2,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `area` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `area_name` TEXT NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `cam` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `name` TEXT NOT NULL, `room_id` INTEGER NOT NULL, `channel_id` INTEGER NOT NULL, `host` TEXT NOT NULL, `port` INTEGER NOT NULL, `auth_user` TEXT NOT NULL, `password` TEXT NOT NULL, `enable_alert` INTEGER NOT NULL, `cam_type` INTEGER NOT NULL, FOREIGN KEY (`room_id`) REFERENCES `room` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `users` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `user_name` TEXT NOT NULL, `phone` TEXT NOT NULL, `pwd_md5` TEXT NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `rel_area_user` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `area_id` INTEGER NOT NULL, `user_id` INTEGER NOT NULL, FOREIGN KEY (`area_id`) REFERENCES `area` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE, FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `rel_area_cam` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `area_id` INTEGER NOT NULL, `cam_id` INTEGER NOT NULL, FOREIGN KEY (`area_id`) REFERENCES `area` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE, FOREIGN KEY (`cam_id`) REFERENCES `cam` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `room` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `room_name` TEXT NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `rel_room_cam` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `room_id` INTEGER NOT NULL, `cam_id` INTEGER NOT NULL, FOREIGN KEY (`room_id`) REFERENCES `room` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE, FOREIGN KEY (`cam_id`) REFERENCES `cam` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `alerts` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `create_at` INTEGER NOT NULL, `img` BLOB, `alert_type` INTEGER NOT NULL, `cam_id` INTEGER NOT NULL, `cam_name` TEXT NOT NULL, `room_id` INTEGER NOT NULL, `room_name` TEXT NOT NULL, FOREIGN KEY (`cam_id`) REFERENCES `cam` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `recorder` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `name` TEXT NOT NULL, `ip` TEXT NOT NULL, `port` INTEGER NOT NULL, `u` TEXT NOT NULL, `p` TEXT NOT NULL)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  AreaDao get areaDao {
    return _areaDaoInstance ??= _$AreaDao(database, changeListener);
  }

  @override
  CamDao get camDao {
    return _camDaoInstance ??= _$CamDao(database, changeListener);
  }

  @override
  AreaUserDao get areaUserDao {
    return _areaUserDaoInstance ??= _$AreaUserDao(database, changeListener);
  }

  @override
  AreaCamDao get areaCamDao {
    return _areaCamDaoInstance ??= _$AreaCamDao(database, changeListener);
  }

  @override
  UserDao get userDao {
    return _userDaoInstance ??= _$UserDao(database, changeListener);
  }

  @override
  RoomDao get roomDao {
    return _roomDaoInstance ??= _$RoomDao(database, changeListener);
  }

  @override
  AlertDao get alertDao {
    return _alertDaoInstance ??= _$AlertDao(database, changeListener);
  }

  @override
  RecorderDao get recorderDao {
    return _recorderDaoInstance ??= _$RecorderDao(database, changeListener);
  }
}

class _$AreaDao extends AreaDao {
  _$AreaDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _areaInsertionAdapter = InsertionAdapter(
            database,
            'area',
            (Area item) =>
                <String, Object?>{'id': item.id, 'area_name': item.areaName}),
        _areaDeletionAdapter = DeletionAdapter(
            database,
            'area',
            ['id'],
            (Area item) =>
                <String, Object?>{'id': item.id, 'area_name': item.areaName});

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Area> _areaInsertionAdapter;

  final DeletionAdapter<Area> _areaDeletionAdapter;

  @override
  Future<List<Area>> findAllAreas() async {
    return _queryAdapter.queryList('SELECT * FROM area',
        mapper: (Map<String, Object?> row) =>
            Area(row['id'] as int?, row['area_name'] as String));
  }

  @override
  Future<int> insertArea(Area area) {
    return _areaInsertionAdapter.insertAndReturnId(
        area, OnConflictStrategy.abort);
  }

  @override
  Future<int> deleteArea(Area area) {
    return _areaDeletionAdapter.deleteAndReturnChangedRows(area);
  }
}

class _$CamDao extends CamDao {
  _$CamDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _camInsertionAdapter = InsertionAdapter(
            database,
            'cam',
            (Cam item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'room_id': item.roomId,
                  'channel_id': item.channelId,
                  'host': item.host,
                  'port': item.port,
                  'auth_user': item.authUser,
                  'password': item.password,
                  'enable_alert': item.enableAlert ? 1 : 0,
                  'cam_type': item.camType
                }),
        _roomCamInsertionAdapter = InsertionAdapter(
            database,
            'rel_room_cam',
            (RoomCam item) => <String, Object?>{
                  'id': item.id,
                  'room_id': item.roomId,
                  'cam_id': item.camId
                }),
        _camUpdateAdapter = UpdateAdapter(
            database,
            'cam',
            ['id'],
            (Cam item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'room_id': item.roomId,
                  'channel_id': item.channelId,
                  'host': item.host,
                  'port': item.port,
                  'auth_user': item.authUser,
                  'password': item.password,
                  'enable_alert': item.enableAlert ? 1 : 0,
                  'cam_type': item.camType
                }),
        _camDeletionAdapter = DeletionAdapter(
            database,
            'cam',
            ['id'],
            (Cam item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'room_id': item.roomId,
                  'channel_id': item.channelId,
                  'host': item.host,
                  'port': item.port,
                  'auth_user': item.authUser,
                  'password': item.password,
                  'enable_alert': item.enableAlert ? 1 : 0,
                  'cam_type': item.camType
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Cam> _camInsertionAdapter;

  final InsertionAdapter<RoomCam> _roomCamInsertionAdapter;

  final UpdateAdapter<Cam> _camUpdateAdapter;

  final DeletionAdapter<Cam> _camDeletionAdapter;

  @override
  Future<List<Cam>> findCamsByRoomId(int roomId) async {
    return _queryAdapter.queryList('SELECT * FROM cam WHERE room_id = ?1',
        mapper: (Map<String, Object?> row) => Cam(
            row['id'] as int?,
            row['name'] as String,
            row['room_id'] as int,
            row['channel_id'] as int,
            row['cam_type'] as int,
            (row['enable_alert'] as int) != 0,
            row['auth_user'] as String,
            row['password'] as String,
            row['port'] as int,
            row['host'] as String),
        arguments: [roomId]);
  }

  @override
  Future<List<Cam>> getAll() async {
    return _queryAdapter.queryList('SELECT * FROM cam',
        mapper: (Map<String, Object?> row) => Cam(
            row['id'] as int?,
            row['name'] as String,
            row['room_id'] as int,
            row['channel_id'] as int,
            row['cam_type'] as int,
            (row['enable_alert'] as int) != 0,
            row['auth_user'] as String,
            row['password'] as String,
            row['port'] as int,
            row['host'] as String));
  }

  @override
  Future<List<Cam>> getCamById(int id) async {
    return _queryAdapter.queryList('SELECT * FROM cam where id = ?1 LIMIT 1',
        mapper: (Map<String, Object?> row) => Cam(
            row['id'] as int?,
            row['name'] as String,
            row['room_id'] as int,
            row['channel_id'] as int,
            row['cam_type'] as int,
            (row['enable_alert'] as int) != 0,
            row['auth_user'] as String,
            row['password'] as String,
            row['port'] as int,
            row['host'] as String),
        arguments: [id]);
  }

  @override
  Future<List<Cam>> getCamByIds(List<int> ids) async {
    const offset = 1;
    final _sqliteVariablesForIds =
        Iterable<String>.generate(ids.length, (i) => '?${i + offset}')
            .join(',');
    return _queryAdapter.queryList(
        'SELECT * FROM cam where id IN (' + _sqliteVariablesForIds + ')',
        mapper: (Map<String, Object?> row) => Cam(
            row['id'] as int?,
            row['name'] as String,
            row['room_id'] as int,
            row['channel_id'] as int,
            row['cam_type'] as int,
            (row['enable_alert'] as int) != 0,
            row['auth_user'] as String,
            row['password'] as String,
            row['port'] as int,
            row['host'] as String),
        arguments: [...ids]);
  }

  @override
  Future<List<Cam>> getAllowedCamByUserId(int userId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM cam where id IN (SELECT DISTINCT cam_id FROM rel_area_cam WHERE area_id IN (SELECT DISTINCT area_id FROM rel_area_user WHERE user_id = ?1))',
        mapper: (Map<String, Object?> row) => Cam(row['id'] as int?, row['name'] as String, row['room_id'] as int, row['channel_id'] as int, row['cam_type'] as int, (row['enable_alert'] as int) != 0, row['auth_user'] as String, row['password'] as String, row['port'] as int, row['host'] as String),
        arguments: [userId]);
  }

  @override
  Future<int> insertCam(Cam cam) {
    return _camInsertionAdapter.insertAndReturnId(
        cam, OnConflictStrategy.abort);
  }

  @override
  Future<int> insertRoomCam(RoomCam r) {
    return _roomCamInsertionAdapter.insertAndReturnId(
        r, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateCam(Cam cam) async {
    await _camUpdateAdapter.update(cam, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteCam(Cam cam) async {
    await _camDeletionAdapter.delete(cam);
  }

  @override
  Future<int> addCam(
    Cam cam,
    Room room,
  ) async {
    if (database is sqflite.Transaction) {
      return super.addCam(cam, room);
    } else {
      return (database as sqflite.Database)
          .transaction<int>((transaction) async {
        final transactionDatabase = _$AppDB(changeListener)
          ..database = transaction;
        return transactionDatabase.camDao.addCam(cam, room);
      });
    }
  }

  @override
  Future<List<String>> getCamNames() async {
    return _queryAdapter.queryList('SELECT name FROM cam',
      mapper: (Map<String, Object?> row) => row.values.first as String,);
  }
}

class _$AreaUserDao extends AreaUserDao {
  _$AreaUserDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _areaUserInsertionAdapter = InsertionAdapter(
            database,
            'rel_area_user',
            (AreaUser item) => <String, Object?>{
                  'id': item.id,
                  'area_id': item.areaId,
                  'user_id': item.userId
                }),
        _areaUserDeletionAdapter = DeletionAdapter(
            database,
            'rel_area_user',
            ['id'],
            (AreaUser item) => <String, Object?>{
                  'id': item.id,
                  'area_id': item.areaId,
                  'user_id': item.userId
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<AreaUser> _areaUserInsertionAdapter;

  final DeletionAdapter<AreaUser> _areaUserDeletionAdapter;

  @override
  Future<List<Cam>> findAllCamUsersByRole(int areaId) async {
    return _queryAdapter.queryList(
        'SELECT * from cam where id IN (SELECT cam_id FROM rel_area_cam where area_id=?1)',
        mapper: (Map<String, Object?> row) => Cam(row['id'] as int?, row['name'] as String, row['room_id'] as int, row['channel_id'] as int, row['cam_type'] as int, (row['enable_alert'] as int) != 0, row['auth_user'] as String, row['password'] as String, row['port'] as int, row['host'] as String),
        arguments: [areaId]);
  }

  @override
  Future<List<Cam>> findAllCamUsersByRoles(List<int> areaIds) async {
    const offset = 1;
    final _sqliteVariablesForAreaIds =
        Iterable<String>.generate(areaIds.length, (i) => '?${i + offset}')
            .join(',');
    return _queryAdapter.queryList(
        'SELECT * from cam where id IN (SELECT cam_id FROM rel_area_cam where area_id IN (' +
            _sqliteVariablesForAreaIds +
            '))',
        mapper: (Map<String, Object?> row) => Cam(row['id'] as int?, row['name'] as String, row['room_id'] as int, row['channel_id'] as int, row['cam_type'] as int, (row['enable_alert'] as int) != 0, row['auth_user'] as String, row['password'] as String, row['port'] as int, row['host'] as String),
        arguments: [...areaIds]);
  }

  @override
  Future<List<User>> findAllAreaUsersByArea(int areaId) async {
    return _queryAdapter.queryList(
        'SELECT * from users where id IN (SELECT user_id FROM rel_area_user where area_id=?1)',
        mapper: (Map<String, Object?> row) => User(row['id'] as int?, row['user_name'] as String, row['phone'] as String, row['pwd_md5'] as String),
        arguments: [areaId]);
  }

  @override
  Future<List<Area>> findAllAreasByUser(int userId) async {
    return _queryAdapter.queryList(
        'SELECT * from area where id IN (SELECT area_id FROM rel_area_user where user_id=?1)',
        mapper: (Map<String, Object?> row) => Area(row['id'] as int?, row['area_name'] as String),
        arguments: [userId]);
  }

  @override
  Future<List<AreaUser>> findAllAreaUsersByUser(int userId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM rel_area_user where user_id=?1',
        mapper: (Map<String, Object?> row) => AreaUser(
            row['id'] as int?, row['user_id'] as int, row['area_id'] as int),
        arguments: [userId]);
  }

  @override
  Future<List<int>> insertAreaUser(List<AreaUser> rels) {
    return _areaUserInsertionAdapter.insertListAndReturnIds(
        rels, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteAreaUser(AreaUser area) async {
    await _areaUserDeletionAdapter.delete(area);
  }

  @override
  Future<void> deleteAreaUsers(List<AreaUser> area) async {
    await _areaUserDeletionAdapter.deleteList(area);
  }

  @override
  Future<int> setRoles(
    User user,
    Iterable<Area> roles,
  ) async {
    if (database is sqflite.Transaction) {
      return super.setRoles(user, roles);
    } else {
      return (database as sqflite.Database)
          .transaction<int>((transaction) async {
        final transactionDatabase = _$AppDB(changeListener)
          ..database = transaction;
        return transactionDatabase.areaUserDao.setRoles(user, roles);
      });
    }
  }
}

class _$AreaCamDao extends AreaCamDao {
  _$AreaCamDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _areaCamInsertionAdapter = InsertionAdapter(
            database,
            'rel_area_cam',
            (AreaCam item) => <String, Object?>{
                  'id': item.id,
                  'area_id': item.areaId,
                  'cam_id': item.camId
                }),
        _areaCamDeletionAdapter = DeletionAdapter(
            database,
            'rel_area_cam',
            ['id'],
            (AreaCam item) => <String, Object?>{
                  'id': item.id,
                  'area_id': item.areaId,
                  'cam_id': item.camId
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<AreaCam> _areaCamInsertionAdapter;

  final DeletionAdapter<AreaCam> _areaCamDeletionAdapter;

  @override
  Future<List<AreaCam>> findAllAreaCams() async {
    return _queryAdapter.queryList('SELECT * FROM rel_area_cam',
        mapper: (Map<String, Object?> row) => AreaCam(
            row['id'] as int?, row['area_id'] as int, row['cam_id'] as int));
  }

  @override
  Future<List<AreaCam>> findAreaCamsByArea(int areaId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM rel_area_cam WHERE area_id = ?1',
        mapper: (Map<String, Object?> row) => AreaCam(
            row['id'] as int?, row['area_id'] as int, row['cam_id'] as int),
        arguments: [areaId]);
  }

  @override
  Future<List<Cam>> findAllCamsByArea(int areaId) async {
    return _queryAdapter.queryList(
        'select * from cam where id IN (SELECT cam_id FROM rel_area_cam where area_id=?1)',
        mapper: (Map<String, Object?> row) => Cam(row['id'] as int?, row['name'] as String, row['room_id'] as int, row['channel_id'] as int, row['cam_type'] as int, (row['enable_alert'] as int) != 0, row['auth_user'] as String, row['password'] as String, row['port'] as int, row['host'] as String),
        arguments: [areaId]);
  }

  @override
  Future<int> insertAreaCam(AreaCam rel) {
    return _areaCamInsertionAdapter.insertAndReturnId(
        rel, OnConflictStrategy.abort);
  }

  @override
  Future<List<int>> insertAreaCams(List<AreaCam> rel) {
    return _areaCamInsertionAdapter.insertListAndReturnIds(
        rel, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteAreaCam(AreaCam rel) async {
    await _areaCamDeletionAdapter.delete(rel);
  }

  @override
  Future<void> deleteAreaCams(List<AreaCam> rel) async {
    await _areaCamDeletionAdapter.deleteList(rel);
  }

  @override
  Future<bool> setAreaCamForArea(
    Area area,
    List<Cam> cams,
  ) async {
    if (database is sqflite.Transaction) {
      return super.setAreaCamForArea(area, cams);
    } else {
      return (database as sqflite.Database)
          .transaction<bool>((transaction) async {
        final transactionDatabase = _$AppDB(changeListener)
          ..database = transaction;
        return transactionDatabase.areaCamDao.setAreaCamForArea(area, cams);
      });
    }
  }
}

class _$UserDao extends UserDao {
  _$UserDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _userInsertionAdapter = InsertionAdapter(
            database,
            'users',
            (User item) => <String, Object?>{
                  'id': item.id,
                  'user_name': item.userName,
                  'phone': item.phone,
                  'pwd_md5': item.passwordMd5
                }),
        _areaUserInsertionAdapter = InsertionAdapter(
            database,
            'rel_area_user',
            (AreaUser item) => <String, Object?>{
                  'id': item.id,
                  'area_id': item.areaId,
                  'user_id': item.userId
                }),
        _userUpdateAdapter = UpdateAdapter(
            database,
            'users',
            ['id'],
            (User item) => <String, Object?>{
                  'id': item.id,
                  'user_name': item.userName,
                  'phone': item.phone,
                  'pwd_md5': item.passwordMd5
                }),
        _userDeletionAdapter = DeletionAdapter(
            database,
            'users',
            ['id'],
            (User item) => <String, Object?>{
                  'id': item.id,
                  'user_name': item.userName,
                  'phone': item.phone,
                  'pwd_md5': item.passwordMd5
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<User> _userInsertionAdapter;

  final InsertionAdapter<AreaUser> _areaUserInsertionAdapter;

  final UpdateAdapter<User> _userUpdateAdapter;

  final DeletionAdapter<User> _userDeletionAdapter;

  @override
  Future<List<User>> getUsers() async {
    return _queryAdapter.queryList('select * from users',
        mapper: (Map<String, Object?> row) => User(
            row['id'] as int?,
            row['user_name'] as String,
            row['phone'] as String,
            row['pwd_md5'] as String));
  }

  @override
  Future<void> getUser(int id) async {
    await _queryAdapter
        .queryNoReturn('select * from users where id = ?1', arguments: [id]);
  }

  @override
  Future<User?> getUserByUserName(String userName) async {
    return _queryAdapter.query('select * from users where user_name = ?1',
        mapper: (Map<String, Object?> row) => User(
            row['id'] as int?,
            row['user_name'] as String,
            row['phone'] as String,
            row['pwd_md5'] as String),
        arguments: [userName]);
  }

  @override
  Future<User?> getUserByPhone(String phone) async {
    return _queryAdapter.query('select * from users where phone = ?1',
        mapper: (Map<String, Object?> row) => User(
            row['id'] as int?,
            row['user_name'] as String,
            row['phone'] as String,
            row['pwd_md5'] as String),
        arguments: [phone]);
  }

  @override
  Future<int> createUser(User user) {
    return _userInsertionAdapter.insertAndReturnId(
        user, OnConflictStrategy.abort);
  }

  @override
  Future<int> insertAreaUser(AreaUser area) {
    return _areaUserInsertionAdapter.insertAndReturnId(
        area, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateUser(User user) async {
    await _userUpdateAdapter.update(user, OnConflictStrategy.abort);
  }

  @override
  Future<int> deleteUser(User user) {
    return _userDeletionAdapter.deleteAndReturnChangedRows(user);
  }

  @override
  Future<int> createUserWithRoles(
    User user,
    List<Area> areas,
  ) async {
    if (database is sqflite.Transaction) {
      return super.createUserWithRoles(user, areas);
    } else {
      return (database as sqflite.Database)
          .transaction<int>((transaction) async {
        final transactionDatabase = _$AppDB(changeListener)
          ..database = transaction;
        return transactionDatabase.userDao.createUserWithRoles(user, areas);
      });
    }
  }
}

class _$RoomDao extends RoomDao {
  _$RoomDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _roomInsertionAdapter = InsertionAdapter(
            database,
            'room',
            (Room item) =>
                <String, Object?>{'id': item.id, 'room_name': item.roomName}),
        _roomCamInsertionAdapter = InsertionAdapter(
            database,
            'rel_room_cam',
            (RoomCam item) => <String, Object?>{
                  'id': item.id,
                  'room_id': item.roomId,
                  'cam_id': item.camId
                }),
        _roomDeletionAdapter = DeletionAdapter(
            database,
            'room',
            ['id'],
            (Room item) =>
                <String, Object?>{'id': item.id, 'room_name': item.roomName}),
        _roomCamDeletionAdapter = DeletionAdapter(
            database,
            'rel_room_cam',
            ['id'],
            (RoomCam item) => <String, Object?>{
                  'id': item.id,
                  'room_id': item.roomId,
                  'cam_id': item.camId
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Room> _roomInsertionAdapter;

  final InsertionAdapter<RoomCam> _roomCamInsertionAdapter;

  final DeletionAdapter<Room> _roomDeletionAdapter;

  final DeletionAdapter<RoomCam> _roomCamDeletionAdapter;

  @override
  Future<List<Room>> getRooms() async {
    return _queryAdapter.queryList('SELECT * FROM room',
        mapper: (Map<String, Object?> row) =>
            Room(row['id'] as int?, row['room_name'] as String));
  }

  @override
  Future<List<Room>> getRoomById(int id) async {
    return _queryAdapter.queryList('SELECT * FROM room WHERE id = ?1',
        mapper: (Map<String, Object?> row) =>
            Room(row['id'] as int?, row['room_name'] as String),
        arguments: [id]);
  }

  @override
  Future<List<RoomCam>> getCamIdsByRoom(int roomId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM rel_room_cam WHERE room_id = ?1',
        mapper: (Map<String, Object?> row) => RoomCam(
            row['id'] as int?, row['room_id'] as int, row['cam_id'] as int),
        arguments: [roomId]);
  }

  @override
  Future<List<Cam>> getCamsByRoom(int roomId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM cam WHERE id IN (SELECT cam_id FROM rel_room_cam WHERE room_id = ?1)',
        mapper: (Map<String, Object?> row) => Cam(row['id'] as int?, row['name'] as String, row['room_id'] as int, row['channel_id'] as int, row['cam_type'] as int, (row['enable_alert'] as int) != 0, row['auth_user'] as String, row['password'] as String, row['port'] as int, row['host'] as String),
        arguments: [roomId]);
  }

  @override
  Future<List<RoomCam>> getAll() async {
    return _queryAdapter.queryList('SELECT * FROM rel_room_cam',
        mapper: (Map<String, Object?> row) => RoomCam(
            row['id'] as int?, row['room_id'] as int, row['cam_id'] as int));
  }

  @override
  Future<int> insertRoom(Room r) {
    return _roomInsertionAdapter.insertAndReturnId(r, OnConflictStrategy.abort);
  }

  @override
  Future<int> insertRoomCam(RoomCam r) {
    return _roomCamInsertionAdapter.insertAndReturnId(
        r, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteRoom(Room r) async {
    await _roomDeletionAdapter.delete(r);
  }

  @override
  Future<void> deleteRoomCam(RoomCam r) async {
    await _roomCamDeletionAdapter.delete(r);
  }
}

class _$AlertDao extends AlertDao {
  _$AlertDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _alertsInsertionAdapter = InsertionAdapter(
            database,
            'alerts',
            (Alerts item) => <String, Object?>{
                  'id': item.id,
                  'create_at': item.createAt,
                  'img': item.img,
                  'alert_type': item.alertType,
                  'cam_id': item.camId,
                  'cam_name': item.camName,
                  'room_id': item.roomId,
                  'room_name': item.roomName
                }),
        _alertsDeletionAdapter = DeletionAdapter(
            database,
            'alerts',
            ['id'],
            (Alerts item) => <String, Object?>{
                  'id': item.id,
                  'create_at': item.createAt,
                  'img': item.img,
                  'alert_type': item.alertType,
                  'cam_id': item.camId,
                  'cam_name': item.camName,
                  'room_id': item.roomId,
                  'room_name': item.roomName
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Alerts> _alertsInsertionAdapter;

  final DeletionAdapter<Alerts> _alertsDeletionAdapter;

  @override
  Future<List<Alerts>> getAlertsFromTo(
    int st,
    int ed,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM alerts WHERE create_at BETWEEN ?1 AND ?2',
        mapper: (Map<String, Object?> row) => Alerts(
            row['id'] as int?,
            row['create_at'] as int,
            row['img'] as Uint8List?,
            row['cam_id'] as int,
            row['alert_type'] as int,
            row['cam_name'] as String,
            row['room_id'] as int,
            row['room_name'] as String),
        arguments: [st, ed]);
  }

  @override
  Future<List<Alerts>> getAlertsFrom(int st) async {
    return _queryAdapter.queryList('SELECT * FROM alerts WHERE create_at >= ?1',
        mapper: (Map<String, Object?> row) => Alerts(
            row['id'] as int?,
            row['create_at'] as int,
            row['img'] as Uint8List?,
            row['cam_id'] as int,
            row['alert_type'] as int,
            row['cam_name'] as String,
            row['room_id'] as int,
            row['room_name'] as String),
        arguments: [st]);
  }

  @override
  Future<List<Alerts>> getAlertsFromNoImg(int st) async {
    return _queryAdapter.queryList(
        'SELECT create_at, id, alert_type, cam_id, cam_name, room_id, room_name FROM alerts WHERE create_at >= ?1',
        mapper: (Map<String, Object?> row) => Alerts(row['id'] as int?, row['create_at'] as int, row['img'] as Uint8List?, row['cam_id'] as int, row['alert_type'] as int, row['cam_name'] as String, row['room_id'] as int, row['room_name'] as String),
        arguments: [st]);
  }

  @override
  Future<int?> deleteAlertsBefore(int st) async {
    return _queryAdapter.query('DELETE FROM alerts WHERE create_at <= ?1',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [st]);
  }

  @override
  Future<List<Alerts>> getAlertsInCamsFrom(
    List<int> cams,
    int st,
    int ed,
  ) async {
    const offset = 3;
    final _sqliteVariablesForCams =
        Iterable<String>.generate(cams.length, (i) => '?${i + offset}')
            .join(',');
    return _queryAdapter.queryList(
        'SELECT * FROM alerts WHERE (create_at BETWEEN ?1 AND ?2) AND (cam_id IN (' +
            _sqliteVariablesForCams +
            '))',
        mapper: (Map<String, Object?> row) => Alerts(row['id'] as int?, row['create_at'] as int, row['img'] as Uint8List?, row['cam_id'] as int, row['alert_type'] as int, row['cam_name'] as String, row['room_id'] as int, row['room_name'] as String),
        arguments: [st, ed, ...cams]);
  }

  @override
  Future<int?> deleteOldAlerts() async {
    return _queryAdapter.query(
        'DELETE FROM alerts WHERE create_at < datetime(\'now\', \'-15 days\')',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<int> insertAlert(Alerts a) {
    return _alertsInsertionAdapter.insertAndReturnId(
        a, OnConflictStrategy.abort);
  }

  @override
  Future<int> deleteAlert(Alerts a) {
    return _alertsDeletionAdapter.deleteAndReturnChangedRows(a);
  }

  @override
  Future<List<Alerts>> getAlertsTypeNoImg() {
    return _queryAdapter.queryList(
        'SELECT create_at, id, alert_type, cam_id, cam_name, room_id, room_name FROM alerts WHERE alert_type = 1',
        mapper: (Map<String, Object?> row) => Alerts(row['id'] as int?, row['create_at'] as int, row['img'] as Uint8List?, row['cam_id'] as int, row['alert_type'] as int, row['cam_name'] as String, row['room_id'] as int, row['room_name'] as String));
  }
}

class _$RecorderDao extends RecorderDao {
  _$RecorderDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _recorderInsertionAdapter = InsertionAdapter(
            database,
            'recorder',
            (Recorder item) => <String, Object?>{
                  'id': item.id,
                  'name': item.recorderName,
                  'ip': item.ip,
                  'port': item.port,
                  'u': item.u,
                  'p': item.p
                }),
        _recorderDeletionAdapter = DeletionAdapter(
            database,
            'recorder',
            ['id'],
            (Recorder item) => <String, Object?>{
                  'id': item.id,
                  'name': item.recorderName,
                  'ip': item.ip,
                  'port': item.port,
                  'u': item.u,
                  'p': item.p
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Recorder> _recorderInsertionAdapter;

  final DeletionAdapter<Recorder> _recorderDeletionAdapter;

  @override
  Future<List<Recorder>> getRecorder(int id) async {
    return _queryAdapter.queryList('SELECT * FROM recorder WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Recorder(
            row['id'] as int?,
            row['name'] as String,
            row['ip'] as String,
            row['port'] as int,
            row['u'] as String,
            row['p'] as String),
        arguments: [id]);
  }

  @override
  Future<int> addRecorder(Recorder recorder) {
    return _recorderInsertionAdapter.insertAndReturnId(
        recorder, OnConflictStrategy.abort);
  }

  @override
  Future<int> deleteRecorder(Recorder recorder) {
    return _recorderDeletionAdapter.deleteAndReturnChangedRows(recorder);
  }
}

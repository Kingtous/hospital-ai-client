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

  UserDao? _userDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
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
            'CREATE TABLE IF NOT EXISTS `cam` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `name` TEXT NOT NULL, `area_id` INTEGER NOT NULL, `url` TEXT NOT NULL, `cam_type` INTEGER NOT NULL, FOREIGN KEY (`area_id`) REFERENCES `area` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `users` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `user_name` TEXT NOT NULL, `pwd_md5` TEXT NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `rel_area_user` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `area_id` INTEGER NOT NULL, `user_id` INTEGER NOT NULL, FOREIGN KEY (`area_id`) REFERENCES `area` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE, FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `rel_area_cam` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `area_id` INTEGER NOT NULL, `cam_id` INTEGER NOT NULL, FOREIGN KEY (`area_id`) REFERENCES `area` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, FOREIGN KEY (`cam_id`) REFERENCES `cam` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION)');

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
  UserDao get userDao {
    return _userDaoInstance ??= _$UserDao(database, changeListener);
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
  Future<void> deleteArea(Area area) async {
    await _areaDeletionAdapter.delete(area);
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
                  'area_id': item.areaId,
                  'url': item.url,
                  'cam_type': item.camType
                }),
        _camUpdateAdapter = UpdateAdapter(
            database,
            'cam',
            ['id'],
            (Cam item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'area_id': item.areaId,
                  'url': item.url,
                  'cam_type': item.camType
                }),
        _camDeletionAdapter = DeletionAdapter(
            database,
            'cam',
            ['id'],
            (Cam item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'area_id': item.areaId,
                  'url': item.url,
                  'cam_type': item.camType
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Cam> _camInsertionAdapter;

  final UpdateAdapter<Cam> _camUpdateAdapter;

  final DeletionAdapter<Cam> _camDeletionAdapter;

  @override
  Future<List<Cam>> findCamsByAreaId(int areaId) async {
    return _queryAdapter.queryList('SELECT * FROM cam WHERE area_id = ?1',
        mapper: (Map<String, Object?> row) => Cam(
            row['id'] as int?,
            row['name'] as String,
            row['area_id'] as int,
            row['url'] as String,
            row['cam_type'] as int),
        arguments: [areaId]);
  }

  @override
  Future<List<Cam>> getAll() async {
    return _queryAdapter.queryList('SELECT * FROM cam',
        mapper: (Map<String, Object?> row) => Cam(
            row['id'] as int?,
            row['name'] as String,
            row['area_id'] as int,
            row['url'] as String,
            row['cam_type'] as int));
  }

  @override
  Future<List<Cam>> getCamById(int id) async {
    return _queryAdapter.queryList('SELECT * FROM cam where id = ?1',
        mapper: (Map<String, Object?> row) => Cam(
            row['id'] as int?,
            row['name'] as String,
            row['area_id'] as int,
            row['url'] as String,
            row['cam_type'] as int),
        arguments: [id]);
  }

  @override
  Future<int> insertCam(Cam cam) {
    return _camInsertionAdapter.insertAndReturnId(
        cam, OnConflictStrategy.abort);
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
    Area area,
  ) async {
    if (database is sqflite.Transaction) {
      return super.addCam(cam, area);
    } else {
      return (database as sqflite.Database)
          .transaction<int>((transaction) async {
        final transactionDatabase = _$AppDB(changeListener)
          ..database = transaction;
        return transactionDatabase.camDao.addCam(cam, area);
      });
    }
  }
}

class _$AreaUserDao extends AreaUserDao {
  _$AreaUserDao(
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
  Future<List<Area>> findAllAreaUsersByUser(int areaId) async {
    return _queryAdapter.queryList(
        'select * from cam where id IN (SELECT cam_id FROM rel_area_cam where area_id=?1)',
        mapper: (Map<String, Object?> row) => Area(row['id'] as int?, row['area_name'] as String),
        arguments: [areaId]);
  }

  @override
  Future<int> insertAreaUser(AreaCam area) {
    return _areaCamInsertionAdapter.insertAndReturnId(
        area, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteAreaUser(AreaCam area) async {
    await _areaCamDeletionAdapter.delete(area);
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
                  'pwd_md5': item.passwordMd5
                }),
        _userDeletionAdapter = DeletionAdapter(
            database,
            'users',
            ['id'],
            (User item) => <String, Object?>{
                  'id': item.id,
                  'user_name': item.userName,
                  'pwd_md5': item.passwordMd5
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<User> _userInsertionAdapter;

  final DeletionAdapter<User> _userDeletionAdapter;

  @override
  Future<List<User>> getUsers() async {
    return _queryAdapter.queryList('select * from users',
        mapper: (Map<String, Object?> row) => User(row['id'] as int?,
            row['user_name'] as String, row['pwd_md5'] as String));
  }

  @override
  Future<void> getUser(int id) async {
    await _queryAdapter
        .queryNoReturn('select * from users where id = ?1', arguments: [id]);
  }

  @override
  Future<User?> getUserByUserName(String userName) async {
    return _queryAdapter.query('select * from users where user_name = ?1',
        mapper: (Map<String, Object?> row) => User(row['id'] as int?,
            row['user_name'] as String, row['pwd_md5'] as String),
        arguments: [userName]);
  }

  @override
  Future<int> createUser(User user) {
    return _userInsertionAdapter.insertAndReturnId(
        user, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteUser(User user) async {
    await _userDeletionAdapter.delete(user);
  }
}

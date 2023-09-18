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
            'CREATE TABLE IF NOT EXISTS `cam` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `name` TEXT NOT NULL, `area_id` INTEGER NOT NULL, FOREIGN KEY (`area_id`) REFERENCES `area` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE)');

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
                <String, Object?>{'id': item.id, 'area_name': item.areaName});

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Area> _areaInsertionAdapter;

  @override
  Future<List<Area>> findAllAreas() async {
    return _queryAdapter.queryList('SELECT * FROM area',
        mapper: (Map<String, Object?> row) => Area(row['area_name'] as String));
  }

  @override
  Future<void> insertArea(Area area) async {
    await _areaInsertionAdapter.insert(area, OnConflictStrategy.abort);
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
                  'area_id': item.areaId
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Cam> _camInsertionAdapter;

  @override
  Future<List<Cam>> findCamsByAreaId(int areaId) async {
    return _queryAdapter.queryList('SELECT * FROM cam WHERE area_id = ?1',
        mapper: (Map<String, Object?> row) =>
            Cam(row['name'] as String, row['area_id'] as int),
        arguments: [areaId]);
  }

  @override
  Future<void> insertCam(Cam cam) async {
    await _camInsertionAdapter.insert(cam, OnConflictStrategy.abort);
  }
}

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'fmoment.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE color_group (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        sort INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE color_card (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        desc TEXT,
        group_id INTEGER,
        create_time INTEGER NOT NULL,
        update_time INTEGER NOT NULL,
        FOREIGN KEY (group_id) REFERENCES color_group(id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE color_item (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        card_id INTEGER NOT NULL,
        hex TEXT NOT NULL,
        rgb_r INTEGER NOT NULL,
        rgb_g INTEGER NOT NULL,
        rgb_b INTEGER NOT NULL,
        hsl_h INTEGER NOT NULL,
        hsl_s INTEGER NOT NULL,
        hsl_l INTEGER NOT NULL,
        sort INTEGER DEFAULT 0,
        FOREIGN KEY (card_id) REFERENCES color_card(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE config (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // 插入默认分组
    await db.insert('color_group', {'name': '默认', 'sort': 0});
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Future migrations go here, e.g.:
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE color_card ADD COLUMN tags TEXT');
    // }
  }
}

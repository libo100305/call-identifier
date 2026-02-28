import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/contact.dart';
import '../models/identification_record.dart';

/// 数据库帮助类
/// 负责 SQLite 数据库的初始化、版本管理和 CRUD 操作
class DatabaseHelper {
  /// 数据库单例实例
  static final DatabaseHelper instance = DatabaseHelper._init();

  /// 数据库实例
  static Database? _database;

  /// 数据库名称
  static const String _databaseName = 'contact_identification.db';

  /// 数据库版本
  static const int _databaseVersion = 1;

  /// 私有构造函数，确保单例
  DatabaseHelper._init();

  /// 获取数据库实例
  /// 如果数据库未初始化，则先进行初始化
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  /// 初始化数据库
  /// 设置数据库路径、版本和回调函数
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// 数据库创建回调
  /// 创建初始表结构
  Future<void> _onCreate(Database db, int version) async {
    // 创建联系人表
    await db.execute('''
      CREATE TABLE contacts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone_number TEXT NOT NULL,
        company TEXT,
        position TEXT,
        email TEXT,
        address TEXT,
        note TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 创建识别记录表
    await db.execute('''
      CREATE TABLE identification_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        phone_number TEXT NOT NULL,
        contact_id INTEGER,
        contact_name TEXT,
        source TEXT NOT NULL,
        status TEXT NOT NULL,
        confidence REAL,
        screenshot_path TEXT,
        note TEXT,
        identified_at TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (contact_id) REFERENCES contacts (id) ON DELETE SET NULL
      )
    ''');

    // 创建电话号码索引，加速查询
    await db.execute('CREATE INDEX idx_contacts_phone ON contacts (phone_number)');
    await db.execute('CREATE INDEX idx_records_phone ON identification_records (phone_number)');
    await db.execute('CREATE INDEX idx_records_status ON identification_records (status)');
  }

  /// 数据库升级回调
  /// 处理数据库版本升级时的迁移逻辑
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 版本升级迁移逻辑
    if (oldVersion < newVersion) {
      // 未来版本升级时添加迁移代码
    }
  }

  // ==================== 联系人表操作 ====================

  /// 插入联系人
  /// 返回新插入记录的 ID
  Future<int> insertContact(Contact contact) async {
    final db = await database;
    return await db.insert('contacts', contact.toMap());
  }

  /// 批量插入联系人
  /// 使用事务提高批量插入性能
  Future<void> insertContacts(List<Contact> contacts) async {
    final db = await database;
    await db.transaction((txn) async {
      for (var contact in contacts) {
        await txn.insert('contacts', contact.toMap());
      }
    });
  }

  /// 更新联系人信息
  /// 返回受影响的行数
  Future<int> updateContact(Contact contact) async {
    final db = await database;
    return await db.update(
      'contacts',
      contact.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  /// 删除联系人
  /// 返回受影响的行数
  Future<int> deleteContact(int id) async {
    final db = await database;
    return await db.delete(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 根据 ID 获取联系人
  Future<Contact?> getContactById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'contacts',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Contact.fromMap(maps.first);
    }
    return null;
  }

  /// 根据电话号码获取联系人
  /// 支持模糊匹配
  Future<List<Contact>> getContactsByPhone(String phoneNumber) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'contacts',
      where: 'phone_number LIKE ?',
      whereArgs: ['%$phoneNumber%'],
    );

    return List.generate(maps.length, (i) {
      return Contact.fromMap(maps[i]);
    });
  }

  /// 获取所有联系人
  /// 支持分页和排序
  Future<List<Contact>> getAllContacts({
    int page = 1,
    int pageSize = 50,
    String sortBy = 'name',
    bool ascending = true,
  }) async {
    final db = await database;
    final offset = (page - 1) * pageSize;
    final order = ascending ? 'ASC' : 'DESC';

    final List<Map<String, dynamic>> maps = await db.query(
      'contacts',
      orderBy: '$sortBy $order',
      limit: pageSize,
      offset: offset,
    );

    return List.generate(maps.length, (i) {
      return Contact.fromMap(maps[i]);
    });
  }

  /// 搜索联系人
  /// 支持按姓名、电话、公司等多字段搜索
  Future<List<Contact>> searchContacts(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'contacts',
      where: 'name LIKE ? OR phone_number LIKE ? OR company LIKE ? OR email LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%', '%$query%'],
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) {
      return Contact.fromMap(maps[i]);
    });
  }

  /// 获取联系人总数
  Future<int> getContactsCount() async {
    final db = await database;
    return Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM contacts'),
    ) ?? 0;
  }

  // ==================== 识别记录表操作 ====================

  /// 插入识别记录
  /// 返回新插入记录的 ID
  Future<int> insertIdentificationRecord(IdentificationRecord record) async {
    final db = await database;
    return await db.insert('identification_records', record.toMap());
  }

  /// 批量插入识别记录
  Future<void> insertIdentificationRecords(List<IdentificationRecord> records) async {
    final db = await database;
    await db.transaction((txn) async {
      for (var record in records) {
        await txn.insert('identification_records', record.toMap());
      }
    });
  }

  /// 更新识别记录
  Future<int> updateIdentificationRecord(IdentificationRecord record) async {
    final db = await database;
    return await db.update(
      'identification_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  /// 删除识别记录
  Future<int> deleteIdentificationRecord(int id) async {
    final db = await database;
    return await db.delete(
      'identification_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 根据 ID 获取识别记录
  Future<IdentificationRecord?> getIdentificationRecordById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'identification_records',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return IdentificationRecord.fromMap(maps.first);
    }
    return null;
  }

  /// 获取所有识别记录
  /// 支持分页、筛选和排序
  Future<List<IdentificationRecord>> getIdentificationRecords({
    int page = 1,
    int pageSize = 50,
    String? status,
    String? phoneNumber,
    String sortBy = 'identified_at',
    bool ascending = false,
  }) async {
    final db = await database;
    final offset = (page - 1) * pageSize;
    final order = ascending ? 'ASC' : 'DESC';

    String? whereClause;
    List<dynamic>? whereArgs;

    if (status != null && phoneNumber != null) {
      whereClause = 'status = ? AND phone_number LIKE ?';
      whereArgs = [status, '%$phoneNumber%'];
    } else if (status != null) {
      whereClause = 'status = ?';
      whereArgs = [status];
    } else if (phoneNumber != null) {
      whereClause = 'phone_number LIKE ?';
      whereArgs = ['%$phoneNumber%'];
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'identification_records',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: '$sortBy $order',
      limit: pageSize,
      offset: offset,
    );

    return List.generate(maps.length, (i) {
      return IdentificationRecord.fromMap(maps[i]);
    });
  }

  /// 获取最近识别记录
  Future<List<IdentificationRecord>> getRecentRecords({int limit = 20}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'identification_records',
      orderBy: 'identified_at DESC',
      limit: limit,
    );

    return List.generate(maps.length, (i) {
      return IdentificationRecord.fromMap(maps[i]);
    });
  }

  /// 获取未匹配的识别记录
  Future<List<IdentificationRecord>> getUnmatchedRecords() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'identification_records',
      where: 'status = ?',
      whereArgs: ['UNMATCHED'],
      orderBy: 'identified_at DESC',
    );

    return List.generate(maps.length, (i) {
      return IdentificationRecord.fromMap(maps[i]);
    });
  }

  /// 获取识别记录总数
  Future<int> getIdentificationRecordsCount() async {
    final db = await database;
    return Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM identification_records'),
    ) ?? 0;
  }

  /// 获取各状态识别记录数量统计
  Future<Map<String, int>> getRecordStatusStats() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT status, COUNT(*) as count
      FROM identification_records
      GROUP BY status
    ''');

    return Map.fromEntries(
      results.map((e) => MapEntry(e['status'] as String, e['count'] as int)),
    );
  }

  /// 关闭数据库连接
  /// 通常在应用退出时调用
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:order/features/products/domain/entities/product.dart';
import 'package:order/features/products/domain/entities/category.dart';
import 'package:order/features/auth/domain/entities/waiter.dart';
import 'package:order/features/printing/domain/entities/printer_device.dart';
import 'package:order/features/settings/domain/entities/shop_config.dart';
import 'package:order/features/tables/domain/entities/table_entity.dart';
import 'package:order/features/tables/domain/entities/table_status.dart';
import 'package:order/features/orders/domain/entities/order.dart';
import 'package:order/features/orders/domain/entities/order_item.dart';
import 'package:order/features/products/domain/entities/department.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('local_storage.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 12,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
CREATE TABLE categories (
  id TEXT PRIMARY KEY,
  shopId TEXT NOT NULL,
  name TEXT NOT NULL
)
''');

    await db.execute('''
CREATE TABLE products (
  id TEXT PRIMARY KEY,
  shopId TEXT NOT NULL,
  categoryId TEXT NOT NULL,
  name TEXT NOT NULL,
  price REAL NOT NULL,
  department TEXT NOT NULL
)
''');

    await db.execute('''
CREATE TABLE waiters (
  id TEXT PRIMARY KEY,
  shopId TEXT NOT NULL,
  name TEXT NOT NULL,
  pin TEXT NOT NULL,
  isAdmin INTEGER NOT NULL DEFAULT 0
)
''');

    await db.execute('''
CREATE TABLE printers (
  id TEXT PRIMARY KEY,
  shopId TEXT NOT NULL,
  name TEXT NOT NULL,
  address TEXT NOT NULL,
  connectionType TEXT NOT NULL,
  role TEXT NOT NULL,
  paperSize INTEGER NOT NULL,
  isUtf8 INTEGER NOT NULL,
  isCp737 INTEGER NOT NULL,
  isDoubleSize INTEGER NOT NULL DEFAULT 0,
  isExtraBold INTEGER NOT NULL DEFAULT 0
)
''');

    await db.execute('''
CREATE TABLE shop_configs (
  id TEXT PRIMARY KEY,
  shopId TEXT NOT NULL,
  isSplitPrintingEnabled INTEGER NOT NULL,
  receiptHeader TEXT NOT NULL,
  receiptFooter TEXT NOT NULL,
  logoPath TEXT,
  stationName TEXT
)
''');

    await db.execute('''
CREATE TABLE sales_records (
  id TEXT PRIMARY KEY,
  shopId TEXT NOT NULL,
  productId TEXT NOT NULL,
  productName TEXT NOT NULL,
  quantity INTEGER NOT NULL,
  price REAL NOT NULL,
  timestamp INTEGER NOT NULL,
  orderType TEXT NOT NULL DEFAULT 'takeaway'
)
''');

    await db.execute('''
CREATE TABLE tables (
  id TEXT PRIMARY KEY,
  shopId TEXT NOT NULL,
  name TEXT NOT NULL,
  status TEXT NOT NULL,
  reservationTime TEXT,
  description TEXT
)
''');

    await db.execute('''
CREATE TABLE orders (
  id TEXT PRIMARY KEY,
  shopId TEXT NOT NULL,
  tableId TEXT NOT NULL,
  waiterId TEXT NOT NULL,
  status TEXT NOT NULL,
  total REAL NOT NULL,
  createdAt TEXT NOT NULL,
  updatedAt TEXT NOT NULL
)
''');

    await db.execute('''
CREATE TABLE order_items (
  id TEXT PRIMARY KEY,
  orderId TEXT NOT NULL,
  productId TEXT NOT NULL,
  productName TEXT NOT NULL,
  quantity INTEGER NOT NULL,
  priceAtOrder REAL NOT NULL,
  department TEXT NOT NULL,
  notes TEXT NOT NULL,
  printStatus TEXT NOT NULL,
  receiptOnly INTEGER NOT NULL DEFAULT 0
)
''');

    // Seed Data
    await _seedInitialData(db);
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
CREATE TABLE waiters (
  id TEXT PRIMARY KEY,
  shopId TEXT NOT NULL,
  name TEXT NOT NULL,
  pin TEXT NOT NULL
)
''');
      await db.insert('waiters', {'id': 'w_admin', 'shopId': 'local', 'name': 'Admin', 'pin': '1'});
    }
    if (oldVersion < 3) {
      await db.execute('''
CREATE TABLE printers (
  id TEXT PRIMARY KEY,
  shopId TEXT NOT NULL,
  name TEXT NOT NULL,
  address TEXT NOT NULL,
  connectionType TEXT NOT NULL,
  role TEXT NOT NULL,
  paperSize INTEGER NOT NULL,
  isUtf8 INTEGER NOT NULL,
  isCp737 INTEGER NOT NULL,
  isDoubleSize INTEGER NOT NULL DEFAULT 0,
  isExtraBold INTEGER NOT NULL DEFAULT 0
)
''');

      await db.execute('''
CREATE TABLE shop_configs (
  id TEXT PRIMARY KEY,
  shopId TEXT NOT NULL,
  isSplitPrintingEnabled INTEGER NOT NULL,
  receiptHeader TEXT NOT NULL,
  receiptFooter TEXT NOT NULL
)
''');
      await db.insert('shop_configs', {
        'id': 'local_config',
        'shopId': 'local',
        'isSplitPrintingEnabled': 0,
        'receiptHeader': 'Τοπικό Κατάστημα',
        'receiptFooter': 'Ευχαριστούμε!'
      });
    }
    if (oldVersion < 4) {
      try {
        await db.execute('ALTER TABLE printers ADD COLUMN isDoubleSize INTEGER NOT NULL DEFAULT 0');
      } catch (e) {
        // Ignore if column already exists
      }
    }
    if (oldVersion < 5) {
      await db.execute('''
CREATE TABLE sales_records (
  id TEXT PRIMARY KEY,
  shopId TEXT NOT NULL,
  productId TEXT NOT NULL,
  productName TEXT NOT NULL,
  quantity INTEGER NOT NULL,
  price REAL NOT NULL,
  timestamp INTEGER NOT NULL
)
''');
    }
    if (oldVersion < 6) {
      try {
        await db.execute('ALTER TABLE shop_configs ADD COLUMN logoPath TEXT');
      } catch (e) {
        // Ignore if column already exists
      }
    }
    if (oldVersion < 7) {
      try {
        await db.execute('ALTER TABLE printers ADD COLUMN isExtraBold INTEGER NOT NULL DEFAULT 0');
      } catch (e) {
        // Ignore if column already exists
      }
    }
    if (oldVersion < 8) {
      await db.execute('''
CREATE TABLE tables (
  id TEXT PRIMARY KEY,
  shopId TEXT NOT NULL,
  name TEXT NOT NULL,
  status TEXT NOT NULL,
  reservationTime TEXT,
  description TEXT
)
''');
    }
    if (oldVersion < 9) {
      await db.execute('''
CREATE TABLE orders (
  id TEXT PRIMARY KEY,
  shopId TEXT NOT NULL,
  tableId TEXT NOT NULL,
  waiterId TEXT NOT NULL,
  status TEXT NOT NULL,
  total REAL NOT NULL,
  createdAt TEXT NOT NULL,
  updatedAt TEXT NOT NULL
)
''');

      await db.execute('''
CREATE TABLE order_items (
  id TEXT PRIMARY KEY,
  orderId TEXT NOT NULL,
  productId TEXT NOT NULL,
  productName TEXT NOT NULL,
  quantity INTEGER NOT NULL,
  priceAtOrder REAL NOT NULL,
  department TEXT NOT NULL,
  notes TEXT NOT NULL,
  printStatus TEXT NOT NULL,
  receiptOnly INTEGER NOT NULL DEFAULT 0
)
''');
    }
    if (oldVersion < 10) {
      try {
        await db.execute('ALTER TABLE sales_records ADD COLUMN orderType TEXT NOT NULL DEFAULT "takeaway"');
      } catch (e) {
        // Ignore if column already exists
      }
    }
    if (oldVersion < 11) {
      try {
        await db.execute('ALTER TABLE shop_configs ADD COLUMN stationName TEXT');
      } catch (e) {
        // Ignore if column already exists
      }
    }
    if (oldVersion < 12) {
      try {
        await db.execute('ALTER TABLE waiters ADD COLUMN isAdmin INTEGER NOT NULL DEFAULT 0');
        // Make the first user an admin by default
        final waiters = await db.query('waiters', orderBy: 'id ASC', limit: 1);
        if (waiters.isNotEmpty) {
          await db.update('waiters', {'isAdmin': 1}, where: 'id = ?', whereArgs: [waiters.first['id']]);
        }
      } catch (e) {
        // Ignore if column already exists
      }
    }
  }

  Future<void> _seedInitialData(Database db) async {
    const shopId = 'local';
    // Seed initial admin user so they aren't locked out
    await db.insert('waiters', {'id': 'w_admin', 'shopId': shopId, 'name': 'Admin', 'pin': '1', 'isAdmin': 1});
  }

  Future<List<Category>> getCategories(String shopId) async {
    final db = await instance.database;
    final result = await db.query('categories', where: 'shopId = ?', whereArgs: [shopId]);
    return result.map((json) => Category.fromJson(json)).toList();
  }

  Future<List<Product>> getProducts(String shopId) async {
    final db = await instance.database;
    final result = await db.query('products', where: 'shopId = ?', whereArgs: [shopId]);
    return result.map((json) => Product.fromJson(json)).toList();
  }

  Future<List<Waiter>> getWaiters(String shopId) async {
    final db = await instance.database;
    final result = await db.query('waiters', where: 'shopId = ?', whereArgs: [shopId]);
    return result.map((json) {
      final map = Map<String, dynamic>.from(json);
      if (map['id'] == 'w_admin' || map['name'] == 'Admin') {
        map['isAdmin'] = true;
      } else if (map['isAdmin'] is int) {
        map['isAdmin'] = map['isAdmin'] == 1;
      }
      return Waiter.fromJson(map);
    }).toList();
  }

  Future<Waiter?> getWaiterByPin(String shopId, String pin) async {
    final db = await instance.database;
    final result = await db.query('waiters', where: 'shopId = ? AND pin = ?', whereArgs: [shopId, pin], limit: 1);
    if (result.isNotEmpty) {
      final map = Map<String, dynamic>.from(result.first);
      if (map['id'] == 'w_admin' || map['name'] == 'Admin') {
        map['isAdmin'] = true;
      } else if (map['isAdmin'] is int) {
        map['isAdmin'] = map['isAdmin'] == 1;
      }
      return Waiter.fromJson(map);
    }
    return null;
  }

  Future<void> addWaiter(Waiter waiter) async {
    final db = await instance.database;
    final map = waiter.toJson();
    if (map['id'] == 'w_admin' || map['name'] == 'Admin') {
      map['isAdmin'] = 1;
    } else {
      map['isAdmin'] = map['isAdmin'] == true ? 1 : 0;
    }
    await db.insert('waiters', map, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteWaiter(String id) async {
    final db = await instance.database;
    await db.delete('waiters', where: 'id = ?', whereArgs: [id]);
  }

  Future<Category?> getCategoryByName(String shopId, String name) async {
    final db = await instance.database;
    final result = await db.query('categories', where: 'shopId = ? AND name = ?', whereArgs: [shopId, name], limit: 1);
    if (result.isNotEmpty) {
      return Category.fromJson(result.first);
    }
    return null;
  }

  Future<void> addCategory(Category category) async {
    final db = await instance.database;
    await db.insert('categories', category.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> addProduct(Product product) async {
    final db = await instance.database;
    // Map department enum to string for SQLite if necessary
    // wait, Product has Department enum. toJson handles it.
    await db.insert('products', product.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> clearAll() async {
    final db = await instance.database;
    await db.delete('categories');
    await db.delete('products');
    await db.delete('waiters');
    await db.delete('printers');
  }

  Future<void> clearProductsAndCategories() async {
    final db = await instance.database;
    await db.delete('products');
    await db.delete('categories');
  }

  Future<List<PrinterDevice>> getPrinters(String shopId) async {
    final db = await instance.database;
    final result = await db.query('printers', where: 'shopId = ?', whereArgs: [shopId]);
    return result.map((json) {
      final map = Map<String, dynamic>.from(json);
      map['isUtf8'] = map['isUtf8'] == 1;
      map['isCp737'] = map['isCp737'] == 1;
      map['isDoubleSize'] = map['isDoubleSize'] == 1;
      map['isExtraBold'] = map['isExtraBold'] == 1;
      return PrinterDevice.fromJson(map);
    }).toList();
  }

  Future<void> addPrinter(PrinterDevice printer) async {
    final db = await instance.database;
    final map = printer.toJson();
    map['isUtf8'] = (map['isUtf8'] as bool) ? 1 : 0;
    map['isCp737'] = (map['isCp737'] as bool) ? 1 : 0;
    map['isDoubleSize'] = (map['isDoubleSize'] as bool) ? 1 : 0;
    map['isExtraBold'] = (map['isExtraBold'] as bool) ? 1 : 0;
    await db.insert('printers', map, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updatePrinter(PrinterDevice printer) async {
    final db = await instance.database;
    final map = printer.toJson();
    map['isUtf8'] = (map['isUtf8'] as bool) ? 1 : 0;
    map['isCp737'] = (map['isCp737'] as bool) ? 1 : 0;
    map['isDoubleSize'] = (map['isDoubleSize'] as bool) ? 1 : 0;
    map['isExtraBold'] = (map['isExtraBold'] as bool) ? 1 : 0;
    await db.update('printers', map, where: 'id = ?', whereArgs: [printer.id]);
  }

  Future<void> deletePrinter(String id) async {
    final db = await instance.database;
    await db.delete('printers', where: 'id = ?', whereArgs: [id]);
  }

  Future<ShopConfig?> getShopConfig(String shopId) async {
    final db = await instance.database;
    final result = await db.query('shop_configs', where: 'shopId = ?', whereArgs: [shopId], limit: 1);
    if (result.isNotEmpty) {
      final map = Map<String, dynamic>.from(result.first);
      map['isSplitPrintingEnabled'] = map['isSplitPrintingEnabled'] == 1;
      return ShopConfig.fromJson(map);
    }
    return null;
  }

  Future<void> updateShopConfig(ShopConfig config) async {
    final db = await instance.database;
    final map = config.toJson();
    map['isSplitPrintingEnabled'] = (map['isSplitPrintingEnabled'] as bool) ? 1 : 0;
    await db.insert('shop_configs', map, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // --- Sales Tracking ---
  
  Future<void> addSalesRecords(List<Map<String, dynamic>> records) async {
    final db = await instance.database;
    final batch = db.batch();
    for (final record in records) {
      batch.insert('sales_records', record, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> getSalesRecordsForDateRange(String shopId, int startMs, int endMs) async {
    final db = await instance.database;
    return await db.query(
      'sales_records',
      where: 'shopId = ? AND timestamp >= ? AND timestamp <= ?',
      whereArgs: [shopId, startMs, endMs],
    );
  }

  Future<List<Map<String, dynamic>>> getAllSalesRecords(String shopId) async {
    final db = await instance.database;
    return await db.query(
      'sales_records',
      where: 'shopId = ?',
      whereArgs: [shopId],
      orderBy: 'timestamp DESC',
    );
  }

  Future<void> deleteSalesRecordsForDateRange(String shopId, int startMs, int endMs) async {
    final db = await instance.database;
    await db.delete(
      'sales_records',
      where: 'shopId = ? AND timestamp >= ? AND timestamp <= ?',
      whereArgs: [shopId, startMs, endMs],
    );
  }

  // --- Tables ---

  RestaurantTable _parseTable(Map<String, dynamic> record) {
    final statusStr = record['status'] as String;
    final reservationTimeStr = record['reservationTime'] as String?;
    final description = record['description'] as String?;
    DateTime? reservationTime;
    if (reservationTimeStr != null && reservationTimeStr.isNotEmpty) {
      reservationTime = DateTime.tryParse(reservationTimeStr);
    }

    return RestaurantTable(
      id: record['id'] as String,
      shopId: record['shopId'] as String,
      name: record['name'] as String,
      status: TableStatus.fromString(
        statusStr,
        reservationTime: reservationTime,
        description: description,
      ),
    );
  }

  Map<String, dynamic> _tableToMap(RestaurantTable table) {
    final map = <String, dynamic>{
      'id': table.id,
      'shopId': table.shopId,
      'name': table.name,
      'status': table.status.value,
    };
    if (table.status case Reserved(:final reservationTime, :final description)) {
      map['reservationTime'] = reservationTime.toIso8601String();
      map['description'] = description;
    } else {
      map['reservationTime'] = null;
      map['description'] = null;
    }
    return map;
  }

  Future<List<RestaurantTable>> getTables(String shopId) async {
    final db = await instance.database;
    final result = await db.query(
      'tables',
      where: 'shopId = ?',
      whereArgs: [shopId],
      orderBy: 'name ASC',
    );
    return result.map(_parseTable).toList();
  }

  Future<void> addTable(RestaurantTable table) async {
    final db = await instance.database;
    await db.insert('tables', _tableToMap(table), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateTableStatus(String tableId, TableStatus status) async {
    final db = await instance.database;
    final map = <String, dynamic>{
      'status': status.value,
    };
    if (status case Reserved(:final reservationTime, :final description)) {
      map['reservationTime'] = reservationTime.toIso8601String();
      map['description'] = description;
    } else {
      map['reservationTime'] = null;
      map['description'] = null;
    }
    await db.update('tables', map, where: 'id = ?', whereArgs: [tableId]);
  }

  Future<void> deleteTable(String id) async {
    final db = await instance.database;
    await db.delete('tables', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateTableName(String tableId, String name) async {
    final db = await instance.database;
    await db.update('tables', {'name': name}, where: 'id = ?', whereArgs: [tableId]);
  }

  // --- Orders & Order Items ---

  Future<void> addOrder(Order order) async {
    final db = await instance.database;
    final map = <String, dynamic>{
      'id': order.id,
      'shopId': order.shopId,
      'tableId': order.tableId,
      'waiterId': order.waiterId,
      'status': order.status.name,
      'total': order.total,
      'createdAt': order.createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'updatedAt': order.updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
    await db.insert('orders', map, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Order?> getOrder(String orderId) async {
    final db = await instance.database;
    final result = await db.query('orders', where: 'id = ?', whereArgs: [orderId], limit: 1);
    if (result.isEmpty) return null;
    return _parseOrder(result.first, await getOrderItems(orderId));
  }

  Future<List<OrderItem>> getOrderItems(String orderId) async {
    final db = await instance.database;
    final result = await db.query('order_items', where: 'orderId = ?', whereArgs: [orderId]);
    return result.map(_parseOrderItem).toList();
  }

  Future<void> addOrderItem(OrderItem item) async {
    final db = await instance.database;
    final map = item.toJson();
    map['receiptOnly'] = item.receiptOnly ? 1 : 0;
    await db.insert('order_items', map, conflictAlgorithm: ConflictAlgorithm.replace);
    await _recalculateOrderTotal(item.orderId);
  }

  Future<void> removeOrderItem(String itemId) async {
    final db = await instance.database;
    final result = await db.query('order_items', where: 'id = ?', whereArgs: [itemId], limit: 1);
    if (result.isNotEmpty) {
      final orderId = result.first['orderId'] as String;
      await db.delete('order_items', where: 'id = ?', whereArgs: [itemId]);
      await _recalculateOrderTotal(orderId);
    }
  }

  Future<void> updateItemPrintStatus(String itemId, String printStatus) async {
    final db = await instance.database;
    await db.update('order_items', {'printStatus': printStatus}, where: 'id = ?', whereArgs: [itemId]);
  }

  Future<void> updateItemNotes(String itemId, String notes) async {
    final db = await instance.database;
    await db.update('order_items', {'notes': notes}, where: 'id = ?', whereArgs: [itemId]);
  }

  Future<void> updateItemReceiptOnly(String itemId, bool receiptOnly) async {
    final db = await instance.database;
    await db.update('order_items', {'receiptOnly': receiptOnly ? 1 : 0}, where: 'id = ?', whereArgs: [itemId]);
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    final db = await instance.database;
    await db.update('orders', {'status': status.name, 'updatedAt': DateTime.now().toIso8601String()}, where: 'id = ?', whereArgs: [orderId]);
  }

  Future<List<Order>> getOrdersByTable(String shopId, String tableId) async {
    final db = await instance.database;
    final result = await db.query(
      'orders',
      where: 'shopId = ? AND tableId = ? AND status != ? AND status != ?',
      whereArgs: [shopId, tableId, OrderStatus.completed.name, OrderStatus.cancelled.name],
    );
    final orders = <Order>[];
    for (var r in result) {
      final items = await getOrderItems(r['id'] as String);
      orders.add(_parseOrder(r, items));
    }
    return orders;
  }

  Future<List<Order>> getOrderHistoryByTable(String shopId, String tableId, int limit) async {
    final db = await instance.database;
    final result = await db.query(
      'orders',
      where: 'shopId = ? AND tableId = ? AND (status = ? OR status = ?)',
      whereArgs: [shopId, tableId, OrderStatus.completed.name, OrderStatus.cancelled.name],
      orderBy: 'createdAt DESC',
      limit: limit,
    );
    final orders = <Order>[];
    for (var r in result) {
      final items = await getOrderItems(r['id'] as String);
      orders.add(_parseOrder(r, items));
    }
    return orders;
  }

  Future<List<Order>> getActiveOrders(String shopId) async {
    final db = await instance.database;
    final result = await db.query(
      'orders',
      where: 'shopId = ? AND status != ? AND status != ?',
      whereArgs: [shopId, OrderStatus.completed.name, OrderStatus.cancelled.name],
    );
    final orders = <Order>[];
    for (var r in result) {
      final items = await getOrderItems(r['id'] as String);
      orders.add(_parseOrder(r, items));
    }
    return orders;
  }

  Future<void> _recalculateOrderTotal(String orderId) async {
    final items = await getOrderItems(orderId);
    double total = items.fold(0.0, (sum, item) => sum + (item.priceAtOrder * item.quantity));
    final db = await instance.database;
    await db.update('orders', {'total': total, 'updatedAt': DateTime.now().toIso8601String()}, where: 'id = ?', whereArgs: [orderId]);
  }

  Order _parseOrder(Map<String, dynamic> record, List<OrderItem> items) {
    return Order(
      id: record['id'] as String,
      shopId: record['shopId'] as String,
      tableId: record['tableId'] as String,
      waiterId: record['waiterId'] as String,
      status: OrderStatus.values.firstWhere((e) => e.name == record['status'], orElse: () => OrderStatus.pending),
      total: (record['total'] as num).toDouble(),
      createdAt: DateTime.tryParse(record['createdAt'] as String? ?? ''),
      updatedAt: DateTime.tryParse(record['updatedAt'] as String? ?? ''),
      items: items,
    );
  }

  OrderItem _parseOrderItem(Map<String, dynamic> record) {
    final map = Map<String, dynamic>.from(record);
    map['receiptOnly'] = (map['receiptOnly'] == 1);
    return OrderItem.fromJson(map);
  }
}

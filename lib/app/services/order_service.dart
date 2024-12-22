import '../models/orders.dart';
import '../../config/database.dart';

class OrderService {
  final Database _db;
  static final OrderService _instance = OrderService._internal(Database());

  OrderService._internal(this._db);

  factory OrderService() {
    return _instance;
  }

  Future<void> checkConnection() async {
    if (!_db.isConnected) {
      await _db.connect();
    }
  }

  Future<List<Order>> getAllOrders() async {
    await checkConnection();
    try {
      final results =
          await _db.query('SELECT * FROM orders WHERE deleted_at IS NULL');
      return results.map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data pesanan: ${e.toString()}');
    }
  }

  Future<Order?> getOrderById(int id) async {
    await checkConnection();
    try {
      final results = await _db.query(
        'SELECT * FROM orders WHERE id = @id AND deleted_at IS NULL',
        {'id': id},
      );
      return results.isNotEmpty ? Order.fromJson(results.first) : null;
    } catch (e) {
      throw Exception('Gagal mengambil data pesanan: ${e.toString()}');
    }
  }

  Future<Order?> createOrder(Order order) async {
    await checkConnection();
    try {
      final result = await _db.query(
        '''
      INSERT INTO orders (order_date, cust_id) 
      VALUES (@order_date, @cust_id) 
      RETURNING *
      ''',
        {
          'order_date': order.orderDate?.toIso8601String(),
          'cust_id': order.custId,
        },
      );
      return result.isNotEmpty ? Order.fromJson(result.first) : null;
    } catch (e) {
      // Tangkap error foreign key
      if (e.toString().contains('23503')) {
        throw Exception('Pelanggan dengan ID ${order.custId} tidak ditemukan.');
      }
      throw Exception('Gagal membuat data pesanan: ${e.toString()}');
    }
  }

  Future<Order?> updateOrder(int id, Order order) async {
    await checkConnection();
    try {
      final updates = <String, dynamic>{};
      final setClauses = <String>[];

      if (order.orderDate != null) {
        updates['order_date'] = order.orderDate?.toIso8601String();
        setClauses.add('order_date = @order_date');
      }
      if (order.custId != null) {
        updates['cust_id'] = order.custId;
        setClauses.add('cust_id = @cust_id');
      }

      if (setClauses.isEmpty) {
        throw Exception('Tidak ada data yang diupdate');
      }

      setClauses.add('updated_at = now()');
      updates['id'] = id;

      final result = await _db.query(
        '''
        UPDATE orders 
        SET ${setClauses.join(', ')}
        WHERE id = @id AND deleted_at IS NULL
        RETURNING *
        ''',
        updates,
      );
      return result.isNotEmpty ? Order.fromJson(result.first) : null;
    } catch (e) {
      throw Exception('Gagal memperbarui data pesanan: ${e.toString()}');
    }
  }

  Future<Order?> deleteOrder(int id) async {
    await checkConnection();
    try {
      final result = await _db.query(
        '''
        UPDATE orders 
        SET deleted_at = now() 
        WHERE id = @id AND deleted_at IS NULL
        RETURNING *
        ''',
        {'id': id},
      );
      return result.isNotEmpty ? Order.fromJson(result.first) : null;
    } catch (e) {
      throw Exception('Gagal menghapus data pesanan: ${e.toString()}');
    }
  }
}

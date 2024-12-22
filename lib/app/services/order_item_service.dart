import '../models/order_item.dart';
import '../../config/database.dart';

class OrderItemService {
  final Database _db;
  static final OrderItemService _instance =
      OrderItemService._internal(Database());

  OrderItemService._internal(this._db);

  factory OrderItemService() {
    return _instance;
  }

  Future<void> checkConnection() async {
    if (!_db.isConnected) {
      await _db.connect();
    }
  }

  Future<List<OrderItem>> getAllOrderItems() async {
    await checkConnection();
    try {
      final results =
          await _db.query('SELECT * FROM order_items WHERE deleted_at IS NULL');
      return results.map((json) => OrderItem.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data item pesanan: ${e.toString()}');
    }
  }

  Future<OrderItem?> getOrderItemById(int id) async {
    await checkConnection();
    try {
      final results = await _db.query(
        'SELECT * FROM order_items WHERE id = @id AND deleted_at IS NULL',
        {'id': id},
      );
      return results.isNotEmpty ? OrderItem.fromJson(results.first) : null;
    } catch (e) {
      throw Exception('Gagal mengambil data item pesanan: ${e.toString()}');
    }
  }

  Future<bool> checkOrderExists(int orderId) async {
    await checkConnection();
    final result = await _db.query(
      'SELECT id FROM orders WHERE id = @orderId AND deleted_at IS NULL',
      {'orderId': orderId},
    );
    return result.isNotEmpty;
  }

  Future<bool> checkProductExists(int prodId) async {
    await checkConnection();
    final result = await _db.query(
      'SELECT id FROM products WHERE id = @prodId AND deleted_at IS NULL',
      {'prodId': prodId},
    );
    return result.isNotEmpty;
  }

  Future<OrderItem?> createOrderItem(OrderItem orderItem) async {
    await checkConnection();
    try {
      final result = await _db.query(
        '''
        INSERT INTO order_items (order_id, prod_id, quantity, size, deleted_at)
        VALUES (@order_id, @prod_id, @quantity, @size, @deleted_at)
        RETURNING *
        ''',
        {
          'order_id': orderItem.orderId,
          'prod_id': orderItem.prodId,
          'quantity': orderItem.quantity,
          'size': orderItem.size,
          'deleted_at': null,
        },
      );
      return result.isNotEmpty ? OrderItem.fromJson(result.first) : null;
    } catch (e) {
      throw Exception('Gagal membuat data item pesanan: ${e.toString()}');
    }
  }

  Future<OrderItem?> updateOrderItem(int id, OrderItem orderItem) async {
    await checkConnection();
    try {
      final result = await _db.query(
        '''
      UPDATE order_items
      SET order_id = @order_id, 
          prod_id = @prod_id, 
          quantity = @quantity, 
          size = @size, 
          updated_at = now()
      WHERE id = @id AND deleted_at IS NULL
      RETURNING *
      ''',
        {
          'id': id,
          'order_id': orderItem.orderId,
          'prod_id': orderItem.prodId,
          'quantity': orderItem.quantity,
          'size': orderItem.size,
        },
      );
      return result.isNotEmpty ? OrderItem.fromJson(result.first) : null;
    } catch (e) {
      throw Exception('Gagal memperbarui data item pesanan: ${e.toString()}');
    }
  }

  Future<OrderItem?> deleteOrderItem(int id) async {
    await checkConnection();
    try {
      final result = await _db.query(
        '''
        UPDATE order_items 
        SET deleted_at = now() 
        WHERE id = @id AND deleted_at IS NULL
        RETURNING *
        ''',
        {'id': id},
      );
      return result.isNotEmpty ? OrderItem.fromJson(result.first) : null;
    } catch (e) {
      throw Exception('Gagal menghapus data item pesanan: ${e.toString()}');
    }
  }
}

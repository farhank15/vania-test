import 'package:vania/vania.dart';
import '../../services/order_service.dart';
import '../../models/orders.dart';
import '../../../utils/response.dart';

class OrderController extends Controller {
  final OrderService _service = OrderService();

  // GET /orders - Get all orders
  Future<Response> index() async {
    try {
      final orders = await _service.getAllOrders();
      return ResponseUtil.createSuccessResponse(
          'Data berhasil diambil', orders.map((o) => o.toJson()).toList());
    } catch (e) {
      return ResponseUtil.createErrorResponse(
          'Gagal mengambil data pesanan', e);
    }
  }

  // GET /orders/:id - Get order by ID
  Future<Response> show(Request request, dynamic id) async {
    try {
      if (id == null) {
        return ResponseUtil.createErrorResponse(
            'ID tidak valid', 'ID is required', 400);
      }

      final orderId = int.tryParse(id.toString());
      if (orderId == null) {
        return ResponseUtil.createErrorResponse(
            'Format ID tidak valid', 'ID must be a number', 400);
      }

      final order = await _service.getOrderById(orderId);
      if (order == null) {
        return ResponseUtil.createErrorResponse(
            'Data tidak ditemukan', 'Order not found', 404);
      }

      return ResponseUtil.createSuccessResponse(
          'Data berhasil ditemukan', order.toJson());
    } catch (e) {
      return ResponseUtil.createErrorResponse(
          'Gagal mengambil data pesanan', e);
    }
  }

  // POST /orders - Create new order
  Future<Response> store(Request request) async {
    try {
      final data = request.body;

      // Validasi input
      if (data['order_date'] == null || data['cust_id'] == null) {
        return ResponseUtil.createErrorResponse(
            'Validasi gagal', 'Field order_date dan cust_id wajib diisi', 400);
      }

      final order = Order(
        orderDate: DateTime.tryParse(data['order_date']),
        custId: data['cust_id'],
      );

      final newOrder = await _service.createOrder(order);
      if (newOrder == null) {
        return ResponseUtil.createErrorResponse('Gagal membuat data pesanan',
            'Terjadi kesalahan saat menyimpan data', 500);
      }

      return ResponseUtil.createSuccessResponse(
          'Data pesanan berhasil dibuat', newOrder.toJson(), 201);
    } catch (e) {
      // Tangkap pesan error dari service dan berikan respons informatif
      return ResponseUtil.createErrorResponse(
          'Gagal membuat data pesanan', e.toString());
    }
  }

  // PUT /orders/:id - Update order by ID
  Future<Response> update(Request request, dynamic id) async {
    try {
      if (id == null) {
        return ResponseUtil.createErrorResponse(
            'ID tidak ditemukan', 'ID is required', 400);
      }

      final orderId = int.tryParse(id.toString());
      if (orderId == null) {
        return ResponseUtil.createErrorResponse(
            'Format ID tidak valid', 'ID must be a number', 400);
      }

      final data = request.body;
      final order = Order(
        orderDate: data['order_date'] != null
            ? DateTime.tryParse(data['order_date'])
            : null,
        custId: data['cust_id'],
      );

      final updatedOrder = await _service.updateOrder(orderId, order);
      if (updatedOrder == null) {
        return ResponseUtil.createErrorResponse(
            'Gagal memperbarui data pesanan', 'Update failed', 400);
      }

      return ResponseUtil.createSuccessResponse(
          'Data pesanan berhasil diperbarui', updatedOrder.toJson());
    } catch (e) {
      return ResponseUtil.createErrorResponse(
          'Gagal memperbarui data pesanan', e);
    }
  }

  // DELETE /orders/:id - Delete order by ID
  Future<Response> destroy(Request request, dynamic id) async {
    try {
      if (id == null) {
        return ResponseUtil.createErrorResponse(
            'ID tidak ditemukan', 'ID is required', 400);
      }

      final orderId = int.tryParse(id.toString());
      if (orderId == null) {
        return ResponseUtil.createErrorResponse(
            'Format ID tidak valid', 'ID must be a number', 400);
      }

      final deletedOrder = await _service.deleteOrder(orderId);
      if (deletedOrder == null) {
        return ResponseUtil.createErrorResponse(
            'Gagal menghapus data pesanan', 'Deletion failed', 400);
      }

      return ResponseUtil.createSuccessResponse(
          'Data pesanan berhasil dihapus', deletedOrder.toJson());
    } catch (e) {
      return ResponseUtil.createErrorResponse(
          'Gagal menghapus data pesanan', e);
    }
  }
}

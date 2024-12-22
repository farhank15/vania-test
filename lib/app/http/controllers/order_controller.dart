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
      return ResponseUtil.createErrorResponse('Gagal mengambil data', e);
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
            'Data tidak ditemukan', 'not found', 404);
      }

      return ResponseUtil.createSuccessResponse(
          'Data berhasil ditemukan', order.toJson());
    } catch (e) {
      return ResponseUtil.createErrorResponse('Gagal mengambil data', e);
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

      // Validasi format tanggal
      final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$'); // Format YYYY-MM-DD
      if (!regex.hasMatch(data['order_date'])) {
        return ResponseUtil.createErrorResponse(
            'Validasi gagal',
            'Field order_date harus berupa format tanggal yang valid (YYYY-MM-DD)',
            400);
      }

      // Buat objek Order langsung dengan String untuk orderDate
      final order = Order(
        orderDate: data['order_date'], // Tidak perlu konversi DateTime
        custId: data['cust_id'],
      );

      final newOrder = await _service.createOrder(order);
      if (newOrder == null) {
        return ResponseUtil.createErrorResponse(
            'Gagal membuat data', 'Terjadi kesalahan saat menyimpan data', 500);
      }

      return ResponseUtil.createSuccessResponse(
          'Data berhasil dibuat', newOrder.toJson(), 201);
    } catch (e) {
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

      // Validasi format tanggal jika ada
      if (data['order_date'] != null) {
        final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
        if (!regex.hasMatch(data['order_date'])) {
          return ResponseUtil.createErrorResponse(
              'Validasi gagal',
              'Field order_date harus berupa format tanggal yang valid (YYYY-MM-DD)',
              400);
        }
      }

      final order = Order(
        orderDate: data['order_date'], // Langsung gunakan string
        custId: data['cust_id'],
      );

      final updatedOrder = await _service.updateOrder(orderId, order);
      if (updatedOrder == null) {
        return ResponseUtil.createErrorResponse(
            'Gagal memperbarui data', 'Update failed', 400);
      }

      return ResponseUtil.createSuccessResponse(
          'Data berhasil diperbarui', updatedOrder.toJson());
    } catch (e) {
      return ResponseUtil.createErrorResponse(
          'Gagal memperbarui data pesanan', e.toString());
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
            'Gagal menghapus data', 'Deletion failed', 400);
      }

      return ResponseUtil.createSuccessResponse(
          'Data berhasil dihapus', deletedOrder.toJson());
    } catch (e) {
      return ResponseUtil.createErrorResponse('Gagal menghapus data', e);
    }
  }
}

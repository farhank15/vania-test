import 'package:vania/vania.dart';
import '../../services/order_item_service.dart';
import '../../models/order_item.dart';
import '../../../utils/response.dart';

class OrderItemController extends Controller {
  final OrderItemService _service = OrderItemService();

  // GET /order-items - Get all order items
  Future<Response> index() async {
    try {
      final items = await _service.getAllOrderItems();
      return ResponseUtil.createSuccessResponse(
          'Data berhasil diambil', items.map((item) => item.toJson()).toList());
    } catch (e) {
      return ResponseUtil.createErrorResponse(
          'Gagal mengambil data', e.toString());
    }
  }

  // GET /order-items/:id - Get order item by ID
  Future<Response> show(Request request, dynamic id) async {
    try {
      if (id == null) {
        return ResponseUtil.createErrorResponse(
            'ID tidak valid', 'ID harus diisi', 400);
      }

      final itemId = int.tryParse(id.toString());
      if (itemId == null) {
        return ResponseUtil.createErrorResponse(
            'Format ID tidak valid', 'ID harus berupa angka', 400);
      }

      final item = await _service.getOrderItemById(itemId);
      if (item == null) {
        return ResponseUtil.createErrorResponse('Data tidak ditemukan',
            'Order item dengan ID $itemId tidak ditemukan', 404);
      }

      return ResponseUtil.createSuccessResponse(
          'Data berhasil ditemukan', item.toJson());
    } catch (e) {
      return ResponseUtil.createErrorResponse(
          'Gagal mengambil data', e.toString());
    }
  }

  // POST /order-items - Create new order item
// POST /order-items - Create new order item
  Future<Response> store(Request request) async {
    try {
      final data = request.body;

      // Validasi input
      if (data['order_id'] == null ||
          data['prod_id'] == null ||
          data['quantity'] == null ||
          data['size'] == null) {
        return ResponseUtil.createErrorResponse('Validasi gagal',
            'Field order_id, prod_id, quantity, dan size wajib diisi', 400);
      }

      // Validasi tipe data
      if (data['order_id'] is! int ||
          data['prod_id'] is! int ||
          data['quantity'] is! int ||
          data['size'] is! int) {
        return ResponseUtil.createErrorResponse(
            'Validasi gagal',
            'Field order_id, prod_id, quantity, dan size harus berupa angka',
            400);
      }

      // Cek keberadaan order_id dan prod_id di database
      final isOrderExists = await _service.checkOrderExists(data['order_id']);
      final isProductExists =
          await _service.checkProductExists(data['prod_id']);

      if (!isOrderExists && !isProductExists) {
        return ResponseUtil.createErrorResponse(
            'Gagal membuat data',
            'Order ID ${data['order_id']} dan Product ID ${data['prod_id']} tidak ditemukan',
            400);
      }
      if (!isOrderExists) {
        return ResponseUtil.createErrorResponse('Gagal membuat data',
            'Order ID ${data['order_id']} tidak ditemukan', 400);
      }
      if (!isProductExists) {
        return ResponseUtil.createErrorResponse('Gagal membuat data',
            'Product ID ${data['prod_id']} tidak ditemukan', 400);
      }

      final orderItem = OrderItem(
        orderId: data['order_id'],
        prodId: data['prod_id'],
        quantity: data['quantity'],
        size: data['size'],
      );

      final newItem = await _service.createOrderItem(orderItem);
      if (newItem == null) {
        return ResponseUtil.createErrorResponse(
            'Gagal membuat data', 'Terjadi kesalahan saat menyimpan data', 500);
      }

      return ResponseUtil.createSuccessResponse(
          'Data berhasil dibuat', newItem.toJson(), 201);
    } catch (e) {
      return ResponseUtil.createErrorResponse(
          'Gagal membuat data', e.toString());
    }
  }

  // PUT /order-items/:id - Update order item by ID
  Future<Response> update(Request request, dynamic id) async {
    try {
      if (id == null) {
        return ResponseUtil.createErrorResponse(
            'ID tidak ditemukan', 'ID harus diisi', 400);
      }

      final itemId = int.tryParse(id.toString());
      if (itemId == null) {
        return ResponseUtil.createErrorResponse(
            'Format ID tidak valid', 'ID harus berupa angka', 400);
      }

      final data = request.body;
      if (data['order_id'] == null ||
          data['prod_id'] == null ||
          data['quantity'] == null ||
          data['size'] == null) {
        return ResponseUtil.createErrorResponse('Validasi gagal',
            'Field order_id, prod_id, quantity, dan size wajib diisi', 400);
      }

      final orderItem = OrderItem(
        orderId: data['order_id'],
        prodId: data['prod_id'],
        quantity: data['quantity'],
        size: data['size'],
      );

      final updatedItem = await _service.updateOrderItem(itemId, orderItem);
      if (updatedItem == null) {
        return ResponseUtil.createErrorResponse('Gagal memperbarui data',
            'Order item dengan ID $itemId tidak ditemukan', 404);
      }

      return ResponseUtil.createSuccessResponse(
          'Data berhasil diperbarui', updatedItem.toJson());
    } catch (e) {
      return ResponseUtil.createErrorResponse(
          'Gagal memperbarui data', e.toString());
    }
  }

  // DELETE /order-items/:id - Delete order item by ID
  Future<Response> destroy(Request request, dynamic id) async {
    try {
      if (id == null) {
        return ResponseUtil.createErrorResponse(
            'ID tidak ditemukan', 'ID harus diisi', 400);
      }

      final itemId = int.tryParse(id.toString());
      if (itemId == null) {
        return ResponseUtil.createErrorResponse(
            'Format ID tidak valid', 'ID harus berupa angka', 400);
      }

      final deletedItem = await _service.deleteOrderItem(itemId);
      if (deletedItem == null) {
        return ResponseUtil.createErrorResponse('Gagal menghapus data',
            'Order item dengan ID $itemId tidak ditemukan', 404);
      }

      return ResponseUtil.createSuccessResponse(
          'Data berhasil dihapus', deletedItem.toJson());
    } catch (e) {
      return ResponseUtil.createErrorResponse(
          'Gagal menghapus data', e.toString());
    }
  }
}

import 'package:vania/vania.dart';
import '../../services/customer_service.dart';
import '../../models/customer.dart';
import '../../../utils/response.dart';
import '../validators/customers_validator.dart';

class CustomerController extends Controller {
  final CustomerService _service = CustomerService();

  // GET /customers - Get all customers
  Future<Response> index() async {
    try {
      final customers = await _service.getAllCustomers();
      return ResponseUtil.createSuccessResponse(
          'Data berhasil diambil', customers.map((c) => c.toJson()).toList());
    } catch (e) {
      return ResponseUtil.createErrorResponse('Gagal mengambil data', e);
    }
  }

  // GET /customers/:id - Get customer by ID
  Future<Response> show(Request request, dynamic id) async {
    try {
      if (id == null) {
        return ResponseUtil.createErrorResponse(
            'ID tidak valid', 'ID is required', 400);
      }

      final customerId = int.tryParse(id.toString());
      if (customerId == null) {
        return ResponseUtil.createErrorResponse(
            'Format ID tidak valid', 'ID must be a number', 400);
      }

      final customer = await _service.getCustomerById(customerId);
      if (customer == null) {
        return ResponseUtil.createErrorResponse(
            'Data tidak ditemukan', 'Customer not found', 404);
      }

      return ResponseUtil.createSuccessResponse(
          'Data berhasil ditemukan', customer.toJson());
    } catch (e) {
      return ResponseUtil.createErrorResponse('Gagal mengambil data', e);
    }
  }

  // POST /customers - Create new customer
  Future<Response> store(Request request) async {
    try {
      final data = request.body;

      // Validasi data menggunakan CustomersValidator
      final errors = CustomersValidator.validateCreate(data);
      if (errors.isNotEmpty) {
        return ResponseUtil.createErrorResponse('Validasi gagal', errors, 400);
      }

      final customer = Customer.fromJson(data);
      final newCustomer = await _service.createCustomer(customer);

      if (newCustomer == null) {
        return ResponseUtil.createErrorResponse('Gagal membuat data pelanggan',
            'Terjadi kesalahan saat menyimpan data', 500);
      }

      return ResponseUtil.createSuccessResponse(
          'Data pelanggan berhasil dibuat', newCustomer.toJson(), 201);
    } catch (e) {
      return ResponseUtil.createErrorResponse(
          'Gagal membuat data pelanggan', e);
    }
  }

  // PUT /customers/:id - Update customer by ID
  Future<Response> update(Request request, dynamic id) async {
    try {
      if (id == null) {
        return ResponseUtil.createErrorResponse(
            'ID tidak ditemukan', 'ID is required', 400);
      }

      final customerId = int.tryParse(id.toString());
      if (customerId == null) {
        return ResponseUtil.createErrorResponse(
            'Format ID tidak valid', 'ID must be a number', 400);
      }

      final data = request.body;
      final existingCustomer = await _service.getCustomerById(customerId);
      if (existingCustomer == null) {
        return ResponseUtil.createErrorResponse('Data tidak ditemukan',
            'Customer with ID $customerId not found', 404);
      }

      final customerToUpdate = Customer.fromJson({...data, 'id': customerId});
      final updatedCustomer =
          await _service.updateCustomer(customerId, customerToUpdate);

      if (updatedCustomer == null) {
        return ResponseUtil.createErrorResponse(
            'Gagal memperbarui data', 'Update failed', 400);
      }

      return ResponseUtil.createSuccessResponse(
          'Data berhasil diperbarui', updatedCustomer.toJson());
    } catch (e) {
      return ResponseUtil.createErrorResponse('Gagal memperbarui data', e);
    }
  }

  // DELETE /customers/:id - Delete customer by ID
  Future<Response> destroy(Request request, dynamic id) async {
    try {
      if (id == null) {
        return ResponseUtil.createErrorResponse(
            'ID tidak ditemukan', 'ID is required', 400);
      }

      final customerId = int.tryParse(id.toString());
      if (customerId == null) {
        return ResponseUtil.createErrorResponse(
            'Format ID tidak valid', 'ID must be a number', 400);
      }

      final existingCustomer = await _service.getCustomerById(customerId);
      if (existingCustomer == null) {
        return ResponseUtil.createErrorResponse('Data tidak ditemukan',
            'Customer with ID $customerId not found', 404);
      }

      final deletedCustomer = await _service.deleteCustomer(customerId);
      if (deletedCustomer == null) {
        return ResponseUtil.createErrorResponse(
            'Gagal menghapus data', 'Deletion failed', 400);
      }

      return ResponseUtil.createSuccessResponse(
          'Data berhasil dihapus', deletedCustomer.toJson());
    } catch (e) {
      return ResponseUtil.createErrorResponse('Gagal menghapus data', e);
    }
  }
}

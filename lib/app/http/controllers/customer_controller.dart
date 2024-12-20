import 'package:vania/vania.dart';
import '../../services/customer_service.dart';
import '../../models/customer.dart';

class CustomerController extends Controller {
  final CustomerService _service = CustomerService();

  Response _createErrorResponse(String message, dynamic error,
      [int code = 500]) {
    return Response.json(
        {'status': 'error', 'message': '$message: ${error.toString()}'}, code);
  }

  Response _createSuccessResponse(String message, dynamic data,
      [int code = 200]) {
    return Response.json(
        {'status': 'success', 'message': message, 'data': data}, code);
  }

  bool _validateRequiredFields(Map<String, dynamic> data) {
    if (data['cust_name']?.toString().isEmpty ?? true) {
      return false;
    }

    if (data['cust_telp']?.toString().isEmpty ?? true) {
      return false;
    }

    return true;
  }

  Customer _createCustomerFromData(Map<String, dynamic> data) {
    return Customer(
      id: data['id'],
      custName: data['cust_name'],
      custAddress: data['cust_address'],
      custCity: data['cust_city'],
      custState: data['cust_state'],
      custZip: data['cust_zip'],
      custCountry: data['cust_country'],
      custTelp: data['cust_telp'],
    );
  }

  // GET /customers - Get all customers
  Future<Response> index() async {
    try {
      final customers = await _service.getAllCustomers();
      return _createSuccessResponse('Data berhasil diambil',
          customers.map((customer) => customer.toJson()).toList());
    } catch (e) {
      return _createErrorResponse('Gagal mengambil data', e);
    }
  }

  // GET /customers/:id - Get customer by ID
  Future<Response> show(Request request, dynamic id) async {
    try {
      if (id == null) {
        return _createErrorResponse('ID tidak valid', 'ID is required', 400);
      }

      final customerId = id is int ? id : int.tryParse(id.toString());
      if (customerId == null) {
        return _createErrorResponse(
            'Format ID tidak valid', 'ID must be a number', 400);
      }

      final customer = await _service.getCustomerById(customerId);
      if (customer == null) {
        return _createErrorResponse(
            'Data tidak ditemukan', 'Customer not found', 404);
      }

      return _createSuccessResponse(
          'Data berhasil ditemukan', customer.toJson());
    } catch (e) {
      return _createErrorResponse('Gagal mengambil data', e);
    }
  }

  // POST /customers - Create new customer
  Future<Response> store(Request request) async {
    try {
      final Map<String, dynamic> data = request.body;

      // Validasi: Hapus atribut waktu yang tidak relevan
      data.remove('created_at');
      data.remove('updated_at');
      data.remove('deleted_at');

      // Validasi: Pastikan semua field wajib ada
      final List<String> requiredFields = [
        'cust_name',
        'cust_address',
        'cust_city',
        'cust_state',
        'cust_zip',
        'cust_country',
        'cust_telp'
      ];
      final missingFields = requiredFields
          .where(
              (field) => data[field] == null || data[field].toString().isEmpty)
          .toList();

      if (missingFields.isNotEmpty) {
        return _createErrorResponse('Data tidak lengkap',
            'Field berikut harus diisi: ${missingFields.join(', ')}', 400);
      }

      // Validasi: Format data
      if (!RegExp(r'^\d{5}$').hasMatch(data['cust_zip'] ?? '')) {
        return _createErrorResponse('Format tidak valid',
            'Kode pos (cust_zip) harus berupa angka 5 digit.', 400);
      }

      if (!RegExp(r'^\+?[0-9-]{7,15}$').hasMatch(data['cust_telp'] ?? '')) {
        return _createErrorResponse(
            'Format tidak valid',
            'Nomor telepon (cust_telp) harus berupa angka dengan format yang benar.',
            400);
      }

      data.remove('id');

      final customer = _createCustomerFromData(data);
      final newCustomer = await _service.createCustomer(customer);

      if (newCustomer == null) {
        return _createErrorResponse('Gagal membuat data pelanggan',
            'Terjadi kesalahan saat menyimpan data', 500);
      }

      return _createSuccessResponse(
          'Data pelanggan berhasil dibuat', newCustomer.toJson(), 201);
    } catch (e) {
      return _createErrorResponse('Gagal membuat data pelanggan', e, 500);
    }
  }

  // PUT /customers/:id - Update customer by ID
  Future<Response> update(Request request, dynamic id) async {
    try {
      // Validasi ID
      if (id == null) {
        return _createErrorResponse(
            'ID tidak ditemukan', 'ID is required', 400);
      }

      // Konversi dan validasi ID
      final customerId = id is int ? id : int.tryParse(id.toString());
      if (customerId == null) {
        return _createErrorResponse(
            'Format ID tidak valid', 'ID must be a number', 400);
      }

      final Map<String, dynamic> data = request.body;

      if (!_validateRequiredFields(data)) {
        return _createErrorResponse(
            'Data tidak lengkap', 'Name and phone number are required', 400);
      }

      final existingCustomer = await _service.getCustomerById(customerId);
      if (existingCustomer == null) {
        return _createErrorResponse('Data tidak ditemukan',
            'Customer with ID $customerId not found', 404);
      }

      final customerToUpdate = _createCustomerFromData({
        ...data,
        'id': customerId,
      });

      final updatedCustomer =
          await _service.updateCustomer(customerId, customerToUpdate);

      if (updatedCustomer == null) {
        return _createErrorResponse(
            'Gagal memperbarui data', 'Update failed', 400);
      }

      return _createSuccessResponse(
          'Data berhasil diperbarui', updatedCustomer.toJson());
    } catch (e) {
      return _createErrorResponse('Gagal memperbarui data', e);
    }
  }

  // DELETE /customers/:id - Delete customer by ID
  Future<Response> destroy(Request request, dynamic id) async {
    try {
      // Validasi ID
      if (id == null) {
        return _createErrorResponse(
            'ID tidak ditemukan', 'ID is required', 400);
      }

      // Konversi dan validasi ID
      final customerId = id is int ? id : int.tryParse(id.toString());
      if (customerId == null) {
        return _createErrorResponse(
            'Format ID tidak valid', 'ID must be a number', 400);
      }

      // Cek keberadaan customer
      final existingCustomer = await _service.getCustomerById(customerId);
      if (existingCustomer == null) {
        return _createErrorResponse('Data tidak ditemukan',
            'Customer with ID $customerId not found', 404);
      }

      // Lakukan delete
      final deletedCustomer = await _service.deleteCustomer(customerId);
      if (deletedCustomer == null) {
        return _createErrorResponse(
            'Gagal menghapus data', 'Deletion failed', 400);
      }

      return _createSuccessResponse(
          'Data berhasil dihapus', deletedCustomer.toJson());
    } catch (e) {
      return _createErrorResponse('Gagal menghapus data', e);
    }
  }
}

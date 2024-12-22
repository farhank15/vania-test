import 'package:vania/vania.dart';
import '../../services/vendor_service.dart';
import '../../models/vendor.dart';
import '../../../utils/response.dart';

class VendorController extends Controller {
  final VendorService _service = VendorService();

  // GET /vendors - Get all vendors
  Future<Response> index() async {
    try {
      final vendors = await _service.getAllVendors();
      return ResponseUtil.createSuccessResponse(
          'Data berhasil diambil', vendors.map((v) => v.toJson()).toList());
    } catch (e) {
      return ResponseUtil.createErrorResponse('Gagal mengambil data', e);
    }
  }

  // GET /vendors/:id - Get vendor by ID
  Future<Response> show(Request request, dynamic id) async {
    try {
      if (id == null) {
        return ResponseUtil.createErrorResponse(
            'ID tidak valid', 'ID is required', 400);
      }

      final vendorId = int.tryParse(id.toString());
      if (vendorId == null) {
        return ResponseUtil.createErrorResponse(
            'Format ID tidak valid', 'ID must be a number', 400);
      }

      final vendor = await _service.getVendorById(vendorId);
      if (vendor == null) {
        return ResponseUtil.createErrorResponse(
            'Data tidak ditemukan', 'Vendor not found', 404);
      }

      return ResponseUtil.createSuccessResponse(
          'Data berhasil ditemukan', vendor.toJson());
    } catch (e) {
      return ResponseUtil.createErrorResponse('Gagal mengambil data', e);
    }
  }

  // POST /vendors - Create new vendor
  Future<Response> store(Request request) async {
    try {
      final data = request.body;

      // Daftar field yang wajib diisi
      final requiredFields = [
        'vend_name',
        'vend_address',
        'vend_kota',
        'vend_state',
        'vend_zip',
        'vend_country'
      ];
      final missingFields = <String>[];

      // Periksa setiap field wajib
      for (final field in requiredFields) {
        if (data[field] == null || data[field].toString().trim().isEmpty) {
          missingFields.add(field);
        }
      }

      // Jika ada field yang belum diisi
      if (missingFields.isNotEmpty) {
        return ResponseUtil.createErrorResponse('Validasi gagal',
            'Field berikut wajib diisi: ${missingFields.join(', ')}', 400);
      }

      final vendor = Vendor(
        vendName: data['vend_name'],
        vendAddress: data['vend_address'],
        vendKota: data['vend_kota'],
        vendState: data['vend_state'],
        vendZip: data['vend_zip'],
        vendCountry: data['vend_country'],
      );

      final newVendor = await _service.createVendor(vendor);
      if (newVendor == null) {
        return ResponseUtil.createErrorResponse('Gagal membuat data vendor',
            'Terjadi kesalahan saat menyimpan data', 500);
      }

      return ResponseUtil.createSuccessResponse(
          'Data berhasil dibuat', newVendor.toJson(), 201);
    } catch (e) {
      return ResponseUtil.createErrorResponse('Gagal membuat data vendor', e);
    }
  }

  // PUT /vendors/:id - Update vendor by ID
  Future<Response> update(Request request, dynamic id) async {
    try {
      if (id == null) {
        return ResponseUtil.createErrorResponse(
            'ID tidak ditemukan', 'ID is required', 400);
      }

      final vendorId = int.tryParse(id.toString());
      if (vendorId == null) {
        return ResponseUtil.createErrorResponse(
            'Format ID tidak valid', 'ID must be a number', 400);
      }

      final data = request.body;
      final vendor = Vendor(
        vendName: data['vend_name'],
        vendAddress: data['vend_address'],
        vendKota: data['vend_kota'],
        vendState: data['vend_state'],
        vendZip: data['vend_zip'],
        vendCountry: data['vend_country'],
      );

      final updatedVendor = await _service.updateVendor(vendorId, vendor);
      if (updatedVendor == null) {
        return ResponseUtil.createErrorResponse(
            'Gagal memperbarui data', 'Update failed', 400);
      }

      return ResponseUtil.createSuccessResponse(
          'Data berhasil diperbarui', updatedVendor.toJson());
    } catch (e) {
      return ResponseUtil.createErrorResponse('Gagal memperbarui data', e);
    }
  }

  // DELETE /vendors/:id - Delete vendor by ID
// DELETE /vendors/:id - Soft delete vendor by ID
  Future<Response> destroy(Request request, dynamic id) async {
    try {
      if (id == null) {
        return ResponseUtil.createErrorResponse(
            'ID tidak ditemukan', 'ID is required', 400);
      }

      final vendorId = int.tryParse(id.toString());
      if (vendorId == null) {
        return ResponseUtil.createErrorResponse(
            'Format ID tidak valid', 'ID must be a number', 400);
      }

      final deletedVendor = await _service.deleteVendor(vendorId);
      if (deletedVendor == null) {
        return ResponseUtil.createErrorResponse(
            'Gagal menghapus data', 'Vendor not found or already deleted', 404);
      }

      return ResponseUtil.createSuccessResponse(
          'Data berhasil dihapus (soft delete)', deletedVendor.toJson());
    } catch (e) {
      return ResponseUtil.createErrorResponse('Gagal menghapus data', e);
    }
  }
}

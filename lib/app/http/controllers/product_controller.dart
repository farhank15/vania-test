import 'package:vania/vania.dart';
import '../../services/product_service.dart';
import '../../models/product.dart';
import '../../../utils/response.dart';

class ProductController extends Controller {
  final ProductService _service = ProductService();

  // GET /products - Get all products
  Future<Response> index() async {
    try {
      final products = await _service.getAllProducts();
      return ResponseUtil.createSuccessResponse(
          'Data berhasil diambil', products.map((p) => p.toJson()).toList());
    } catch (e) {
      return ResponseUtil.createErrorResponse('Gagal mengambil data', e);
    }
  }

  // GET /products/:id - Get product by ID
  Future<Response> show(Request request, dynamic id) async {
    try {
      if (id == null) {
        return ResponseUtil.createErrorResponse(
            'ID tidak valid', 'ID is required', 400);
      }

      final productId = int.tryParse(id.toString());
      if (productId == null) {
        return ResponseUtil.createErrorResponse(
            'Format ID tidak valid', 'ID must be a number', 400);
      }

      final product = await _service.getProductById(productId);
      if (product == null) {
        return ResponseUtil.createErrorResponse(
            'Data tidak ditemukan', 'Product not found', 404);
      }

      return ResponseUtil.createSuccessResponse(
          'Data berhasil ditemukan', product.toJson());
    } catch (e) {
      return ResponseUtil.createErrorResponse('Gagal mengambil data', e);
    }
  }

// POST /products - Create new product
  Future<Response> store(Request request) async {
    try {
      final data = request.body;

      // Validasi field wajib
      final requiredFields = [
        'vend_id',
        'prod_name',
        'prod_price',
        'prod_desc'
      ];
      final missingFields = requiredFields
          .where((field) =>
              data[field] == null || data[field].toString().trim().isEmpty)
          .toList();

      if (missingFields.isNotEmpty) {
        return ResponseUtil.createErrorResponse('Validasi gagal',
            'Field berikut wajib diisi: ${missingFields.join(', ')}', 400);
      }

      final vendId = int.tryParse(data['vend_id'].toString());
      if (vendId == null) {
        return ResponseUtil.createErrorResponse(
            'Validasi gagal', 'vend_id harus berupa angka', 400);
      }

      // Validasi status vendor
      final vendorStatus = await _service.validateVendorStatus(vendId);
      if (vendorStatus == 'not_found') {
        return ResponseUtil.createErrorResponse(
            'Validasi gagal', 'Vendor dengan ID $vendId tidak ditemukan', 404);
      } else if (vendorStatus == 'inactive') {
        return ResponseUtil.createErrorResponse('Validasi gagal',
            'Vendor dengan ID $vendId sudah tidak aktif', 400);
      }

      final product = Product(
        vendId: vendId,
        prodName: data['prod_name'],
        prodPrice: int.tryParse(data['prod_price'].toString()),
        prodDesc: data['prod_desc'],
      );

      final newProduct = await _service.createProduct(product);
      if (newProduct == null) {
        return ResponseUtil.createErrorResponse('Gagal membuat data produk',
            'Terjadi kesalahan saat menyimpan data', 500);
      }

      return ResponseUtil.createSuccessResponse(
          'Data produk berhasil dibuat', newProduct.toJson(), 201);
    } catch (e) {
      return ResponseUtil.createErrorResponse('Gagal membuat data produk', e);
    }
  }

  // PUT /products/:id - Update product by ID
  Future<Response> update(Request request, dynamic id) async {
    try {
      if (id == null) {
        return ResponseUtil.createErrorResponse(
            'ID tidak ditemukan', 'ID is required', 400);
      }

      final productId = int.tryParse(id.toString());
      if (productId == null) {
        return ResponseUtil.createErrorResponse(
            'Format ID tidak valid', 'ID must be a number', 400);
      }

      final data = request.body;
      final product = Product(
        vendId: int.tryParse(data['vend_id'].toString()),
        prodName: data['prod_name'],
        prodPrice: int.tryParse(data['prod_price'].toString()),
        prodDesc: data['prod_desc'],
      );

      final updatedProduct = await _service.updateProduct(productId, product);
      if (updatedProduct == null) {
        return ResponseUtil.createErrorResponse(
            'Gagal memperbarui data', 'Update failed', 400);
      }

      return ResponseUtil.createSuccessResponse(
          'Data berhasil diperbarui', updatedProduct.toJson());
    } catch (e) {
      return ResponseUtil.createErrorResponse('Gagal memperbarui data', e);
    }
  }

  // DELETE /products/:id - Delete product by ID
  Future<Response> destroy(Request request, dynamic id) async {
    try {
      if (id == null) {
        return ResponseUtil.createErrorResponse(
            'ID tidak ditemukan', 'ID is required', 400);
      }

      final productId = int.tryParse(id.toString());
      if (productId == null) {
        return ResponseUtil.createErrorResponse(
            'Format ID tidak valid', 'ID must be a number', 400);
      }

      final deletedProduct = await _service.deleteProduct(productId);
      if (deletedProduct == null) {
        return ResponseUtil.createErrorResponse(
            'Gagal menghapus data', 'Deletion failed', 400);
      }

      return ResponseUtil.createSuccessResponse(
          'Data berhasil dihapus', deletedProduct.toJson());
    } catch (e) {
      return ResponseUtil.createErrorResponse('Gagal menghapus data', e);
    }
  }
}

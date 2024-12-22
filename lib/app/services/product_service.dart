import '../../config/database.dart';
import '../models/product.dart';

class ProductService {
  final Database _db;
  static final ProductService _instance = ProductService._internal(Database());

  ProductService._internal(this._db);

  factory ProductService() {
    return _instance;
  }

  Future<void> checkConnection() async {
    if (!_db.isConnected) {
      await _db.connect();
    }
  }

  Future<List<Product>> getAllProducts() async {
    await checkConnection();
    try {
      final results =
          await _db.query('SELECT * FROM products WHERE deleted_at IS NULL');
      return results.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data produk: ${e.toString()}');
    }
  }

  Future<Product?> getProductById(int id) async {
    await checkConnection();
    try {
      final results = await _db.query(
        'SELECT * FROM products WHERE id = @id AND deleted_at IS NULL',
        {'id': id},
      );
      return results.isNotEmpty ? Product.fromJson(results.first) : null;
    } catch (e) {
      throw Exception('Gagal mengambil data produk: ${e.toString()}');
    }
  }

  Future<Product?> createProduct(Product product) async {
    await checkConnection();
    try {
      final result = await _db.query(
        '''
        INSERT INTO products (vend_id, prod_name, prod_price, prod_desc) 
        VALUES (@vend_id, @prod_name, @prod_price, @prod_desc) 
        RETURNING *
        ''',
        {
          'vend_id': product.vendId,
          'prod_name': product.prodName,
          'prod_price': product.prodPrice,
          'prod_desc': product.prodDesc,
        },
      );
      return result.isNotEmpty ? Product.fromJson(result.first) : null;
    } catch (e) {
      throw Exception('Gagal membuat data produk: ${e.toString()}');
    }
  }

  Future<bool> isVendorActive(int vendId) async {
    await checkConnection();
    try {
      final result = await _db.query(
        '''
      SELECT id FROM vendors 
      WHERE id = @id AND deleted_at IS NULL
      ''',
        {'id': vendId},
      );
      return result.isNotEmpty;
    } catch (e) {
      throw Exception('Gagal memvalidasi vendor: ${e.toString()}');
    }
  }

  Future<String?> validateVendorStatus(int vendId) async {
    await checkConnection();
    try {
      final result = await _db.query(
        '''
      SELECT deleted_at FROM vendors 
      WHERE id = @id
      ''',
        {'id': vendId},
      );

      if (result.isEmpty) {
        return 'not_found'; // Vendor tidak ditemukan
      } else if (result.first['deleted_at'] != null) {
        return 'inactive'; // Vendor sudah di-soft delete
      }

      return 'active'; // Vendor aktif
    } catch (e) {
      throw Exception('Gagal memvalidasi vendor: ${e.toString()}');
    }
  }

  Future<Product?> updateProduct(int id, Product product) async {
    await checkConnection();
    try {
      final result = await _db.query(
        '''
        UPDATE products 
        SET vend_id = @vend_id, 
            prod_name = @prod_name, 
            prod_price = @prod_price, 
            prod_desc = @prod_desc, 
            updated_at = now()
        WHERE id = @id AND deleted_at IS NULL 
        RETURNING *
        ''',
        {
          'id': id,
          'vend_id': product.vendId,
          'prod_name': product.prodName,
          'prod_price': product.prodPrice,
          'prod_desc': product.prodDesc,
        },
      );
      return result.isNotEmpty ? Product.fromJson(result.first) : null;
    } catch (e) {
      throw Exception('Gagal memperbarui data produk: ${e.toString()}');
    }
  }

  Future<Product?> deleteProduct(int id) async {
    await checkConnection();
    try {
      final result = await _db.query(
        '''
        UPDATE products 
        SET deleted_at = now() 
        WHERE id = @id AND deleted_at IS NULL 
        RETURNING *
        ''',
        {'id': id},
      );
      return result.isNotEmpty ? Product.fromJson(result.first) : null;
    } catch (e) {
      throw Exception('Gagal menghapus data produk: ${e.toString()}');
    }
  }
}

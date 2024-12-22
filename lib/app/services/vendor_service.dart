import '../models/vendor.dart';
import '../../config/database.dart';

class VendorService {
  final Database _db;
  static final VendorService _instance = VendorService._internal(Database());

  VendorService._internal(this._db);

  factory VendorService() {
    return _instance;
  }

  Future<void> checkConnection() async {
    if (!_db.isConnected) {
      await _db.connect();
    }
  }

  Future<List<Vendor>> getAllVendors() async {
    await checkConnection();
    try {
      final results =
          await _db.query('SELECT * FROM vendors WHERE deleted_at IS NULL');
      return results.map((json) => Vendor.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data vendor: ${e.toString()}');
    }
  }

  Future<Vendor?> getVendorById(int id) async {
    await checkConnection();
    try {
      final results = await _db.query(
        'SELECT * FROM vendors WHERE id = @id AND deleted_at IS NULL',
        {'id': id},
      );
      return results.isNotEmpty ? Vendor.fromJson(results.first) : null;
    } catch (e) {
      throw Exception('Gagal mengambil data vendor: ${e.toString()}');
    }
  }

  Future<Vendor?> createVendor(Vendor vendor) async {
    await checkConnection();
    try {
      final result = await _db.query(
        '''
        INSERT INTO vendors (vend_name, vend_address, vend_kota, vend_state, vend_zip, vend_country) 
        VALUES (@vend_name, @vend_address, @vend_kota, @vend_state, @vend_zip, @vend_country) 
        RETURNING *
        ''',
        {
          'vend_name': vendor.vendName,
          'vend_address': vendor.vendAddress,
          'vend_kota': vendor.vendKota,
          'vend_state': vendor.vendState,
          'vend_zip': vendor.vendZip,
          'vend_country': vendor.vendCountry,
        },
      );
      return result.isNotEmpty ? Vendor.fromJson(result.first) : null;
    } catch (e) {
      throw Exception('Gagal membuat data vendor: ${e.toString()}');
    }
  }

  Future<Vendor?> updateVendor(int id, Vendor vendor) async {
    await checkConnection();
    try {
      final updates = <String, dynamic>{};
      final setClauses = <String>[];

      if (vendor.vendName != null) {
        updates['vend_name'] = vendor.vendName;
        setClauses.add('vend_name = @vend_name');
      }
      if (vendor.vendAddress != null) {
        updates['vend_address'] = vendor.vendAddress;
        setClauses.add('vend_address = @vend_address');
      }
      if (vendor.vendKota != null) {
        updates['vend_kota'] = vendor.vendKota;
        setClauses.add('vend_kota = @vend_kota');
      }
      if (vendor.vendState != null) {
        updates['vend_state'] = vendor.vendState;
        setClauses.add('vend_state = @vend_state');
      }
      if (vendor.vendZip != null) {
        updates['vend_zip'] = vendor.vendZip;
        setClauses.add('vend_zip = @vend_zip');
      }
      if (vendor.vendCountry != null) {
        updates['vend_country'] = vendor.vendCountry;
        setClauses.add('vend_country = @vend_country');
      }

      if (setClauses.isEmpty) {
        throw Exception('Tidak ada data yang diupdate');
      }

      setClauses.add('updated_at = now()');
      updates['id'] = id;

      final result = await _db.query(
        '''
        UPDATE vendors 
        SET ${setClauses.join(', ')}
        WHERE id = @id AND deleted_at IS NULL
        RETURNING *
        ''',
        updates,
      );
      return result.isNotEmpty ? Vendor.fromJson(result.first) : null;
    } catch (e) {
      throw Exception('Gagal memperbarui data vendor: ${e.toString()}');
    }
  }

  Future<Vendor?> deleteVendor(int id) async {
    await checkConnection();
    try {
      final result = await _db.query(
        '''
        UPDATE vendors 
        SET deleted_at = now() 
        WHERE id = @id AND deleted_at IS NULL
        RETURNING *
        ''',
        {'id': id},
      );
      return result.isNotEmpty ? Vendor.fromJson(result.first) : null;
    } catch (e) {
      throw Exception('Gagal menghapus data vendor: ${e.toString()}');
    }
  }
}

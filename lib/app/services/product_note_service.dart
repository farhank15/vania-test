import '../models/product_note.dart';
import '../../config/database.dart';

class ProductNoteService {
  final Database _db;
  static final ProductNoteService _instance =
      ProductNoteService._internal(Database());

  ProductNoteService._internal(this._db);

  factory ProductNoteService() {
    return _instance;
  }

  Future<void> checkConnection() async {
    if (!_db.isConnected) {
      await _db.connect();
    }
  }

  Future<List<ProductNote>> getAllNotes() async {
    await checkConnection();
    try {
      final results = await _db
          .query('SELECT * FROM product_notes WHERE deleted_at IS NULL');
      return results.map((json) => ProductNote.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data catatan produk: ${e.toString()}');
    }
  }

  Future<ProductNote?> getNoteById(int id) async {
    await checkConnection();
    try {
      final results = await _db.query(
        'SELECT * FROM product_notes WHERE id = @id AND deleted_at IS NULL',
        {'id': id},
      );
      return results.isNotEmpty ? ProductNote.fromJson(results.first) : null;
    } catch (e) {
      throw Exception('Gagal mengambil data catatan produk: ${e.toString()}');
    }
  }

  Future<ProductNote?> createNote(ProductNote note) async {
    await checkConnection();
    try {
      final result = await _db.query(
        '''
      INSERT INTO product_notes (prod_id, note_date, note_text) 
      VALUES (@prod_id, @note_date, @note_text) 
      RETURNING *
      ''',
        {
          'prod_id': note.prodId,
          'note_date': note.noteDate,
          'note_text': note.noteText,
        },
      );
      return result.isNotEmpty ? ProductNote.fromJson(result.first) : null;
    } catch (e) {
      throw Exception('Gagal membuat catatan produk: ${e.toString()}');
    }
  }

  Future<bool> isProductActive(int prodId) async {
    await checkConnection();
    try {
      final result = await _db.query(
        '''
      SELECT COUNT(*) AS count 
      FROM products 
      WHERE id = @prod_id AND deleted_at IS NULL
      ''',
        {'prod_id': prodId},
      );
      return result.first['count'] > 0;
    } catch (e) {
      throw Exception('Gagal memeriksa status produk: ${e.toString()}');
    }
  }

  Future<ProductNote?> updateNote(int id, ProductNote note) async {
    await checkConnection();
    try {
      final result = await _db.query(
        '''
      UPDATE product_notes 
      SET note_date = @note_date, 
          note_text = @note_text, 
          updated_at = now()
      WHERE id = @id AND deleted_at IS NULL
      RETURNING *
      ''',
        {
          'id': id,
          'note_date': note.noteDate,
          'note_text': note.noteText,
        },
      );
      return result.isNotEmpty ? ProductNote.fromJson(result.first) : null;
    } catch (e) {
      throw Exception('Gagal memperbarui catatan produk: ${e.toString()}');
    }
  }

  Future<ProductNote?> deleteNote(int id) async {
    await checkConnection();
    try {
      final result = await _db.query(
        '''
      UPDATE product_notes 
      SET deleted_at = now() 
      WHERE id = @id AND deleted_at IS NULL
      RETURNING *
      ''',
        {'id': id},
      );
      return result.isNotEmpty ? ProductNote.fromJson(result.first) : null;
    } catch (e) {
      throw Exception('Gagal menghapus catatan produk: ${e.toString()}');
    }
  }
}

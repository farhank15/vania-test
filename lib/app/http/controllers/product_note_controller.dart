import 'package:vania/vania.dart';
import '../../services/product_note_service.dart';
import '../../models/product_note.dart';
import '../../../utils/response.dart';

class ProductNoteController extends Controller {
  final ProductNoteService _service = ProductNoteService();

  // GET /product-notes - Get all notes
  Future<Response> index() async {
    try {
      final notes = await _service.getAllNotes();
      return ResponseUtil.createSuccessResponse(
          'Data berhasil diambil', notes.map((n) => n.toJson()).toList());
    } catch (e) {
      return ResponseUtil.createErrorResponse('Gagal mengambil data', e);
    }
  }

  // GET /product-notes/{id} - Get note by ID
  Future<Response> show(Request request, dynamic id) async {
    try {
      if (id == null) {
        return ResponseUtil.createErrorResponse(
            'ID tidak valid', 'ID is required', 400);
      }

      final noteId = int.tryParse(id.toString());
      if (noteId == null) {
        return ResponseUtil.createErrorResponse(
            'Format ID tidak valid', 'ID must be a number', 400);
      }

      final note = await _service.getNoteById(noteId);
      if (note == null) {
        return ResponseUtil.createErrorResponse(
            'Data tidak ditemukan', 'Note not found', 404);
      }

      return ResponseUtil.createSuccessResponse(
          'Data berhasil ditemukan', note.toJson());
    } catch (e) {
      return ResponseUtil.createErrorResponse('Gagal mengambil data', e);
    }
  }

  // POST /product-notes - Create new note
  Future<Response> store(Request request) async {
    try {
      final data = request.body;

      // Validasi input
      if (data['prod_id'] == null || data['note_date'] == null) {
        return ResponseUtil.createErrorResponse(
          'Field prod_id dan note_date wajib diisi',
          400,
        );
      }

      // Validasi format tanggal
      final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$'); // Format YYYY-MM-DD
      if (!regex.hasMatch(data['note_date'])) {
        return ResponseUtil.createErrorResponse(
          'Field note_date harus berupa format tanggal yang valid (YYYY-MM-DD)',
          400,
        );
      }

      // Periksa apakah prod_id valid dan aktif
      final prodId = data['prod_id'];
      final isProductActive = await _service.isProductActive(prodId);
      if (!isProductActive) {
        return ResponseUtil.createErrorResponse(
          'Produk dengan ID $prodId tidak ditemukan atau telah dihapus.',
          404,
        );
      }

      final productNote = ProductNote(
        prodId: prodId,
        noteDate: data['note_date'], // Gunakan string langsung
        noteText: data['note_text'],
      );

      final newProductNote = await _service.createNote(productNote);
      if (newProductNote == null) {
        return ResponseUtil.createErrorResponse(
          'Gagal membuat data',
          'Terjadi kesalahan saat menyimpan catatan produk',
          500,
        );
      }

      return ResponseUtil.createSuccessResponse(
        'Data berhasil dibuat',
        newProductNote.toJson(),
        201,
      );
    } catch (e) {
      return ResponseUtil.createErrorResponse(
        'Gagal membuat data',
        e.toString(),
      );
    }
  }

  // PUT /product-notes/{id} - Update note by ID
  Future<Response> update(Request request, dynamic id) async {
    try {
      if (id == null) {
        return ResponseUtil.createErrorResponse(
            'ID tidak ditemukan', 'ID is required', 400);
      }

      final noteId = int.tryParse(id.toString());
      if (noteId == null) {
        return ResponseUtil.createErrorResponse(
            'Format ID tidak valid', 'ID must be a number', 400);
      }

      final data = request.body;
      if (data['note_date'] != null) {
        final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
        if (!regex.hasMatch(data['note_date'])) {
          return ResponseUtil.createErrorResponse(
            'Field note_date harus berupa format tanggal yang valid (YYYY-MM-DD)',
            400,
          );
        }
      }

      final note = ProductNote(
        noteDate: data['note_date'],
        noteText: data['note_text'],
      );

      final updatedNote = await _service.updateNote(noteId, note);
      if (updatedNote == null) {
        return ResponseUtil.createErrorResponse(
            'Gagal memperbarui data', 'Update failed', 400);
      }

      return ResponseUtil.createSuccessResponse(
          'Data berhasil diperbarui', updatedNote.toJson());
    } catch (e) {
      return ResponseUtil.createErrorResponse('Gagal memperbarui data', e);
    }
  }

  // DELETE /product-notes/{id} - Delete note by ID
  Future<Response> destroy(Request request, dynamic id) async {
    try {
      if (id == null) {
        return ResponseUtil.createErrorResponse(
            'ID tidak ditemukan', 'ID is required', 400);
      }

      final noteId = int.tryParse(id.toString());
      if (noteId == null) {
        return ResponseUtil.createErrorResponse(
            'Format ID tidak valid', 'ID must be a number', 400);
      }

      final deletedNote = await _service.deleteNote(noteId);
      if (deletedNote == null) {
        return ResponseUtil.createErrorResponse(
            'Gagal menghapus data', 'Deletion failed', 400);
      }

      return ResponseUtil.createSuccessResponse(
          'Data berhasil dihapus', deletedNote.toJson());
    } catch (e) {
      return ResponseUtil.createErrorResponse('Gagal menghapus data', e);
    }
  }
}

import 'package:vania/vania.dart';
import 'package:mysql1/mysql1.dart';
import '../../../database/database_connection.dart';

class CustomerController extends Controller {
  // Tampilkan semua customer
  Future<Response> index() async {
    try {
      MySqlConnection conn = await connectToDatabase();
      var results = await conn.query('SELECT * FROM customers');
      await conn.close();

      return Response.json({
        'data': results
            .map((row) => {
                  'cust_id': row['cust_id'],
                  'cust_name': row['cust_name'],
                  'cust_address': row['cust_address'],
                  'cust_city': row['cust_city'],
                })
            .toList()
      });
    } catch (e) {
      return Response.json({
        'error': 'Gagal mengambil data customer',
        'message': e.toString()
      }).status(500);
    }
  }

  // Tambah customer baru
  Future<Response> store(Request request) async {
    try {
      final body = request.input();

      MySqlConnection conn = await connectToDatabase();

      // Menjalankan query untuk menambahkan customer
      var result = await conn.query(
          'INSERT INTO customers (cust_id, cust_name, cust_address, cust_city, cust_state, cust_zip, cust_country, cust_telp) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
          [
            body['cust_id'],
            body['cust_name'],
            body['cust_address'],
            body['cust_city'],
            body['cust_state'],
            body['cust_zip'],
            body['cust_country'],
            body['cust_telp']
          ]);

      await conn.close();

      // Verifikasi jika data berhasil dimasukkan
      if (result.insertId != null) {
        return Response.json({'message': 'Customer added successfully!'},
            201); // Status 201 Created
      } else {
        return Response.json({'error': 'Failed to add customer.'},
            500); // Status 500 Internal Server Error
      }
    } catch (e) {
      return Response.json({
        'error': 'Gagal menambah data customer',
        'message': e.toString(),
      }, 500); // Status 500 Internal Server Error
    }
  }

  // Update customer
  Future<Response> update(Request request) async {
    try {
      // Ambil cust_id dari query string
      final custId =
          request.query('cust_id'); // Mengambil 'cust_id' dari query string

      if (custId == null) {
        return Response.json(
            {'error': 'cust_id is required'}, 400); // Status 400: Bad Request
      }

      final body = request.input(); // Ambil data dari body request

      MySqlConnection conn = await connectToDatabase();

      // Cek apakah customer dengan cust_id ini ada
      var result = await conn
          .query('SELECT * FROM customers WHERE cust_id = ?', [custId]);

      if (result.isEmpty) {
        return Response.json(
            {'error': 'Customer not found'}, 404); // Status 404: Not Found
      }

      // Update customer jika ditemukan
      await conn.query(
          'UPDATE customers SET cust_name = ?, cust_address = ?, cust_city = ?, cust_state = ?, cust_zip = ?, cust_country = ?, cust_telp = ? WHERE cust_id = ?',
          [
            body['cust_name'],
            body['cust_address'],
            body['cust_city'],
            body['cust_state'],
            body['cust_zip'],
            body['cust_country'],
            body['cust_telp'],
            custId // Pastikan cust_id digunakan untuk kondisi WHERE
          ]);

      await conn.close();
      return Response.json(
          {'message': 'Customer updated successfully!'}, 200); // Status 200 OK
    } catch (e) {
      return Response.json({
        'error': 'Failed to update customer',
        'message': e.toString(),
      }, 500); // Status 500 Internal Server Error
    }
  }

  // Hapus customer
  Future<Response> delete(Request request) async {
    try {
      // Ambil cust_id dari query string
      final custId =
          request.query('cust_id'); // Mengambil 'cust_id' dari query string

      if (custId == null) {
        return Response.json(
            {'error': 'cust_id is required'}, 400); // Status 400: Bad Request
      }

      MySqlConnection conn = await connectToDatabase();

      // Cek apakah customer dengan cust_id ini ada
      var result = await conn
          .query('SELECT * FROM customers WHERE cust_id = ?', [custId]);

      if (result.isEmpty) {
        return Response.json(
            {'error': 'Customer not found'}, 404); // Status 404: Not Found
      }

      // Hapus customer berdasarkan cust_id
      await conn.query('DELETE FROM customers WHERE cust_id = ?', [custId]);

      await conn.close();

      return Response.json(
          {'message': 'Customer deleted successfully!'}, 200); // Status 200 OK
    } catch (e) {
      return Response.json({
        'error': 'Gagal menghapus data customer',
        'message': e.toString(),
      }, 500); // Status 500: Internal Server Error
    }
  }
}

final customerController = CustomerController();

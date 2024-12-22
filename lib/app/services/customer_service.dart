import '../models/customer.dart';
import '../../config/database.dart';

class CustomerService {
  final Database _db;
  static final CustomerService _instance =
      CustomerService._internal(Database());

  CustomerService._internal(this._db);

  factory CustomerService() {
    return _instance;
  }

  Future<void> checkConnection() async {
    if (!_db.isConnected) {
      await _db.connect();
    }
  }

  Future<List<Customer>> getAllCustomers() async {
    await checkConnection();
    try {
      final results = await _db.query('SELECT * FROM customers');
      return results.map((json) => Customer.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data pelanggan: ${e.toString()}');
    }
  }

  Future<Customer?> getCustomerById(int id) async {
    await checkConnection();
    try {
      final results = await _db.query(
        'SELECT * FROM customers WHERE id = @id',
        {'id': id},
      );
      return results.isNotEmpty ? Customer.fromJson(results.first) : null;
    } catch (e) {
      throw Exception('Gagal mengambil data pelanggan: ${e.toString()}');
    }
  }

  Future<Customer?> createCustomer(Customer customer) async {
    await checkConnection();
    try {
      final result = await _db.query(
        '''
      INSERT INTO customers 
      (cust_name, cust_address, cust_city, cust_state, cust_zip, cust_country, cust_telp)
      VALUES (@name, @address, @city, @state, @zip, @country, @telp)
      RETURNING id, cust_name, cust_address, cust_city, cust_state, cust_zip, cust_country, cust_telp, created_at, updated_at
      ''', // Hindari RETURNING *.
        {
          'name': customer.custName,
          'address': customer.custAddress,
          'city': customer.custCity,
          'state': customer.custState,
          'zip': customer.custZip,
          'country': customer.custCountry,
          'telp': customer.custTelp,
        },
      );

      if (result.isNotEmpty) {
        final data = result.first;
        data['created_at'] = data['created_at'] != null
            ? DateTime.parse(data['created_at'].toString())
            : null;
        data['updated_at'] = data['updated_at'] != null
            ? DateTime.parse(data['updated_at'].toString())
            : null;

        return Customer.fromJson(data);
      }

      return null;
    } catch (e) {
      throw Exception('Gagal membuat data pelanggan: ${e.toString()}');
    }
  }

  Future<Customer?> updateCustomer(int id, Customer customer) async {
    await checkConnection();
    try {
      final result = await _db.query(
        '''
      UPDATE customers 
      SET cust_name = @name, 
          cust_address = @address, 
          cust_city = @city, 
          cust_state = @state, 
          cust_zip = @zip, 
          cust_country = @country, 
          cust_telp = @telp, 
          updated_at = now()
      WHERE id = @id
      RETURNING *
      ''',
        {
          'id': id,
          'name': customer.custName,
          'address': customer.custAddress,
          'city': customer.custCity,
          'state': customer.custState,
          'zip': customer.custZip,
          'country': customer.custCountry,
          'telp': customer.custTelp,
        },
      );
      return result.isNotEmpty ? Customer.fromJson(result.first) : null;
    } catch (e) {
      throw Exception('Gagal memperbarui data pelanggan: ${e.toString()}');
    }
  }

  Future<Customer?> deleteCustomer(int id) async {
    await checkConnection();
    try {
      final result = await _db.query(
        'DELETE FROM ${Customer.tableName} WHERE id = @id RETURNING *',
        {'id': id},
      );
      return result.isNotEmpty ? Customer.fromJson(result.first) : null;
    } catch (e) {
      throw Exception('Gagal menghapus data pelanggan: ${e.toString()}');
    }
  }
}

// lib/database/migrations/create_customers_table.dart
import 'package:vania/vania.dart';

class CreateCustomersTable extends Migration {
  @override
  Future<void> up() async {
    super.up();

    // Membuat tabel 'customers' jika belum ada
    await createTableNotExists('customers', () {
      char('cust_id', length: 5);
      string('cust_name', length: 50);
      string('cust_address', length: 50);
      string('cust_city', length: 20);
      string('cust_state', length: 5);
      string('cust_zip', length: 7);
      string('cust_country', length: 25);
      string('cust_telp', length: 15);
      primary('cust_id');
    });
  }

  @override
  Future<void> down() async {
    super.down();

    // Menghapus tabel 'customers' jika ada
    await dropIfExists('customers');
  }
}

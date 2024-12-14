// lib/database/migrations/create_orders_table.dart
import 'package:vania/vania.dart';

class CreateOrdersTable extends Migration {
  @override
  Future<void> up() async {
    super.up();

    // Membuat tabel orders jika belum ada
    await createTableNotExists('orders', () {
      integer('order_num', length: 11);
      date('order_date');
      char('cust_id', length: 5);
      primary('order_num');
      foreign('cust_id', 'customers', 'cust_id', constrained: true);
    });
  }

  @override
  Future<void> down() async {
    super.down();

    // Menghapus tabel orders jika ada
    await dropIfExists('orders');
  }
}

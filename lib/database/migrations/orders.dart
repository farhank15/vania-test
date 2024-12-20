import 'package:vania/vania.dart';

class Orders extends Migration {
  @override
  Future<void> up() async {
    super.up();
    await createTableNotExists('orders', () {
      id();
      date('order_date');
      integer('cust_id', length: 11);
      foreign('cust_id', 'customers', 'id', constrained: true);
      timeStamp('created_at', defaultValue: 'now()');
      timeStamp('updated_at', defaultValue: 'now()');
      timeStamp('deleted_at');
    });
  }

  @override
  Future<void> down() async {
    super.down();
    await dropIfExists('orders');
  }
}

import 'package:vania/vania.dart';

class OrderItems extends Migration {
  @override
  Future<void> up() async {
    super.up();
    await createTableNotExists('order_items', () {
      id();
      integer('order_id', length: 11);
      integer('prod_id', length: 11);
      integer('quantity', length: 11);
      integer('size', length: 11);
      foreign('prod_id', 'products', 'id');
      foreign('order_id', 'orders', 'id');
      timeStamp('created_at', defaultValue: 'now()');
      timeStamp('updated_at', defaultValue: 'now()');
      timeStamp('deleted_at');
    });
  }

  @override
  Future<void> down() async {
    super.down();
    await dropIfExists('order_items');
  }
}

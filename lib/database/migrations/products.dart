import 'package:vania/vania.dart';

class Products extends Migration {
  @override
  Future<void> up() async {
    super.up();
    await createTableNotExists('products', () {
      id();
      integer('vend_id', length: 11);
      string('prod_name', length: 25);
      integer('prod_price', length: 11);
      text('prod_desc');
      foreign('vend_id', 'vendors', 'id');
      timeStamp('created_at', defaultValue: 'now()');
      timeStamp('updated_at', defaultValue: 'now()');
      timeStamp('deleted_at');
    });
  }

  @override
  Future<void> down() async {
    super.down();
    await dropIfExists('products');
  }
}

import 'package:vania/vania.dart';

class Vendors extends Migration {
  @override
  Future<void> up() async {
    super.up();
    await createTableNotExists('vendors', () {
      id();
      string('vend_name', length: 50);
      text('vend_address');
      text('vend_kota');
      string('vend_state', length: 5);
      string('vend_zip', length: 7);
      string('vend_country', length: 25);
      timeStamp('created_at', defaultValue: 'now()');
      timeStamp('updated_at', defaultValue: 'now()');
      timeStamp('deleted_at');
    });
  }

  @override
  Future<void> down() async {
    super.down();
    await dropIfExists('vendors');
  }
}

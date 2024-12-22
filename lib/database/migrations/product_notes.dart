import 'package:vania/vania.dart';

class ProductNotes extends Migration {
  @override
  Future<void> up() async {
    super.up();
    await createTableNotExists('product_notes', () {
      id();
      integer('prod_id', length: 11);
      date('note_date');
      text('note_text');
      primary('note_id');
      foreign('prod_id', 'products', 'id');
      timeStamp('created_at', defaultValue: 'now()');
      timeStamp('updated_at', defaultValue: 'now()');
      timeStamp('deleted_at', nullable: true);
    });
  }

  @override
  Future<void> down() async {
    super.down();
    await dropIfExists('product_notes');
  }
}

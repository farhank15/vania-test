import 'package:vania/vania.dart';

class Users extends Migration {
  @override
  Future<void> up() async {
    super.up();
    await createTableNotExists('users', () {
      id();
      string('name', length: 50);
      string('email', length: 50);
      string('password', length: 50);
      timeStamp('created_at', defaultValue: 'now()');
      timeStamp('updated_at', defaultValue: 'now()');
      timeStamp('deleted_at');
    });
  }

  @override
  Future<void> down() async {
    super.down();
    await dropIfExists('users');
  }
}

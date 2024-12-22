import 'package:vania/vania.dart';

class Users extends Migration {
  @override
  Future<void> up() async {
    super.up();
    await createTableNotExists('users', () {
      id();
      string('name', length: 50);
      string('username', length: 50, unique: true);
      string('email', length: 50, unique: true);
      string('password', length: 100);
      timeStamp('last_login_at', nullable: true);
      string('last_login_ip', length: 45, nullable: true);
      timeStamp('created_at', defaultValue: 'now()');
      timeStamp('updated_at', defaultValue: 'now()');
      timeStamp('deleted_at', nullable: true);
    });
  }

  @override
  Future<void> down() async {
    super.down();
    await dropIfExists('users');
  }
}

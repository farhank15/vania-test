import 'package:vania/vania.dart';
import '../app/http/controllers/customer_controller.dart';
import '../app/http/controllers/user_controller.dart';

class WebRoute implements Route {
  @override
  void register() {
    final customerController = CustomerController();
    final userController = UserController();

    // Prefix API
    const String apiPrefix = '/api/v1';

    // Customer routes
    Router.get('$apiPrefix/customers', customerController.index);
    Router.get('$apiPrefix/customers/{id}', customerController.show);
    Router.post('$apiPrefix/customers', customerController.store);
    Router.put('$apiPrefix/customers/{id}', customerController.update);
    Router.delete('$apiPrefix/customers/{id}', customerController.destroy);

    // User authentication routes
    Router.get('$apiPrefix/users', userController.index);
    Router.get('$apiPrefix/users/{id}', userController.show);
    Router.post('$apiPrefix/users/login', userController.login);
    Router.post('$apiPrefix/users', userController.store);
    Router.put('$apiPrefix/users/{id}', userController.update);
    Router.delete('$apiPrefix/users/{id}', userController.destroy);
  }
}

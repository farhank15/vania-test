import 'package:backend/app/http/controllers/product_controller.dart';
import 'package:vania/vania.dart';
import '../app/http/controllers/customer_controller.dart';
import '../app/http/controllers/user_controller.dart';
import '../app/http/controllers/order_controller.dart';
import '../app/http/controllers/vendor_controller.dart';

class WebRoute implements Route {
  @override
  void register() {
    final customerController = CustomerController();
    final userController = UserController();
    final orderController = OrderController();
    final vendorController = VendorController();
    final controller = ProductController();

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

    // Order routes
    Router.get('$apiPrefix/orders', orderController.index);
    Router.get('$apiPrefix/orders/{id}', orderController.show);
    Router.post('$apiPrefix/orders', orderController.store);
    Router.put('$apiPrefix/orders/{id}', orderController.update);
    Router.delete('$apiPrefix/orders/{id}', orderController.destroy);

    // vendor routes
    Router.get('$apiPrefix/vendors', vendorController.index);
    Router.get('$apiPrefix/vendors/{id}', vendorController.show);
    Router.post('$apiPrefix/vendors', vendorController.store);
    Router.put('$apiPrefix/vendors/{id}', vendorController.update);
    Router.delete('$apiPrefix/vendors/{id}', vendorController.destroy);

    // Product routes
    Router.get('$apiPrefix/products', controller.index);
    Router.get('$apiPrefix/products/{id}', controller.show);
    Router.post('$apiPrefix/products', controller.store);
    Router.put('$apiPrefix/products/{id}', controller.update);
    Router.delete('$apiPrefix/products/{id}', controller.destroy);
  }
}

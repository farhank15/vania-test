import 'package:vania/vania.dart';
import '../app/http/controllers/customer_controller.dart';

class WebRoute implements Route {
  @override
  void register() {
    final customerController = CustomerController();

    // Customer routes
    Router.get('/customers', customerController.index);
    Router.get('/customers/{id}', customerController.show);
    Router.post('/customers', customerController.store);
    Router.put('/customers/{id}', customerController.update);
    Router.delete('/customers/{id}', customerController.destroy);
  }
}

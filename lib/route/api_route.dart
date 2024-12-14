// lib/route/api_route.dart
import 'package:vania/vania.dart';
import 'package:vania_coba/app/http/controllers/customer_controller.dart'; // Tambahkan import ini

class ApiRoute implements Route {
  @override
  void register() {
    /// Base RoutePrefix
    Router.basePrefix('api');

    // Rute Customer
    Router.get("/customers", customerController.index);
    Router.post("/customers", customerController.store);
    // Router.get("/customers/:id", customerController.show);
    Router.put("/customers", customerController.update);
    // Router.put("/customers/:cust_id", customerController.update);
    Router.delete("/customers", customerController.delete);
    // Router.delete("/customers/:id", customerController.delete);
  }
}

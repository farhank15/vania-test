import 'dart:io';
import 'package:vania/vania.dart';
import 'customers.dart';
import 'orders.dart';
import 'vendors.dart';
import 'products.dart';
import 'product_notes.dart';
import 'order_items.dart';
import 'users.dart';

void main(List<String> args) async {
  await MigrationConnection().setup();
  if (args.isNotEmpty && args.first.toLowerCase() == "migrate:fresh") {
    await Migrate().dropTables();
  } else {
    await Migrate().registry();
  }
  await MigrationConnection().closeConnection();
  exit(0);
}

class Migrate {
  registry() async {
		 await Customers().up();
		 await Orders().up();
		 await Vendors().up();
		 await Products().up();
		 await ProductNotes().up();
		 await OrderItems().up();
		 await Users().up();
	}

  dropTables() async {
		 await Users().down();
		 await OrderItems().down();
		 await ProductNotes().down();
		 await Products().down();
		 await Vendors().down();
		 await Orders().down();
		 await Customers().down();
	 }
}

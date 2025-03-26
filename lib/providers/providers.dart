import 'package:riverpod/riverpod.dart';
import 'package:shopping_cart_app/models/cart.dart';
import 'package:shopping_cart_app/models/product.dart';
import 'package:shopping_cart_app/services/product_service.dart';

final productServiceProvider= Provider((ref)=>ProductService());

final productProvider= FutureProvider.family<List<Product>?,int>((ref,page)async {
   final service=ref.watch(productServiceProvider);
   return service.getProducts(page, 10); 
});

final allProductsProvider = StateProvider<List<Product>>((ref) => []);

final cartProvider = StateProvider<List<Cart>>((ref) => []);

final totalPriceProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  double total = 0; // Start with 0
  for (var item in cart) {
    total = total + (item.product.price!*(1-item.product.discountPercentage!/100) * item.quantity);
  }
  return total;
});

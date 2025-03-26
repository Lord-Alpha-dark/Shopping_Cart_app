import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_cart_app/providers/providers.dart';
import 'package:shopping_cart_app/screens/components/builcart_items.dart';
import '../models/cart.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 249, 175, 200),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 249, 175, 200),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Padding(
          padding: EdgeInsets.only(left: 92),
          child: Text(
            'Cart',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 28),
          ),
        ),
      ),
      body: cart.isEmpty
          ? const Center(child: Text('Your cart is empty'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.length,
                    itemBuilder: (context, index) {
                      final cartItem = cart[index];
                      return buildCartItem(cartItem, index,ref);
                    },
                  ),
                ),
                Container(
                  height: 90,
                  margin: const EdgeInsets.only(top: 10,bottom: 5,left: 3,right: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: _buildFooter(cart)),
              ],
            ),
    );
  }


  Widget _buildFooter(List<Cart> cart) {
    //  total price
    int totalQuantity = 0;
    double totalPrice = 0;
    for (var item in cart) {
      final discountedPrice = item.product.price * (1 - item.product.discountPercentage / 100);
      totalPrice += discountedPrice * item.quantity;
      totalQuantity += item.quantity;
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Amount',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              Text(
                '₹${totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              // Navigate to checkout screen (placeholder)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Proceeding to checkout...')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              'Check Out ${totalQuantity}',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  }

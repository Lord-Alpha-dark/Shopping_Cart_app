  import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_cart_app/models/cart.dart';
import 'package:shopping_cart_app/providers/providers.dart';

Widget buildCartItem(Cart cartItem, int index,WidgetRef ref) {
    final product = cartItem.product;
    final discountedPrice = product.price * (1 - product.discountPercentage / 100);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              // Product Image
              SizedBox(
                width: 80,
                height: 80,
                child: product.image.isNotEmpty
                    ? Image.network(
                        product.image.first,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      )
                    : const Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.grey,
                      ),
              ),
              const SizedBox(width: 16),
              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      product.brand ?? 'Unknown Brand',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '₹${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '₹${discountedPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${product.discountPercentage.toStringAsFixed(2)}% OFF',
                      style: const TextStyle(color: Colors.green, fontSize: 12),
                    ),
                  ],
                ),
              ),
              // Quantity Controls
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      _decreaseQuantity(index,ref);
                    },
                  ),
                  Text(
                    '${cartItem.quantity}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      increaseQuantity(index,ref);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


void increaseQuantity(int index,WidgetRef ref) {
    final cart = ref.read(cartProvider.notifier).state;
    final updatedCart = List<Cart>.from(cart);
    updatedCart[index] = Cart(
      product: updatedCart[index].product,
      quantity: updatedCart[index].quantity + 1,
    );
    ref.read(cartProvider.notifier).state = updatedCart;
  }

  void _decreaseQuantity(int index,WidgetRef ref) {
    final cart = ref.read(cartProvider.notifier).state;
    final updatedCart = List<Cart>.from(cart);
    final newQuantity = updatedCart[index].quantity - 1;

    if (newQuantity <= 0) {
      // Remove item from cart if quantity reaches 0
      updatedCart.removeAt(index);
    } else {
      updatedCart[index] = Cart(
        product: updatedCart[index].product,
        quantity: newQuantity,
      );
    }
    ref.read(cartProvider.notifier).state = updatedCart;
  }

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_cart_app/models/cart.dart';
import 'package:shopping_cart_app/models/product.dart';
import 'package:shopping_cart_app/providers/providers.dart';

Widget productCard(Product product,WidgetRef ref)=>
Card(
              elevation: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child:Stack(
                      fit: StackFit.expand,
                          children:[ product.image.isNotEmpty
                        ?  CarouselSlider(
                              options: CarouselOptions(
                           
                                viewportFraction: 1.0,
                                enableInfiniteScroll: true,
                                autoPlay: false,
                                
                              ),
                              items: product.image.map((imageUrl) {
                                return Container(
                                   width: double.infinity,
                                   height: double.infinity,
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                     
                                    errorBuilder: (context, error, stackTrace) =>const Icon(
                                      Icons.broken_image,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              }).toList(),
                        ):
                        const Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey,
                          ),
                            Positioned(
                        bottom: 8,
                        right: 8,
                        child: ElevatedButton(
                          onPressed: () {
                            final cart = ref.read(cartProvider.notifier).state;
                            ref.read(cartProvider.notifier).state = [
                              ...cart,
                              Cart(product: product, quantity: 1),
                            ];
                          },
                          child: const Text('Add'),
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(12),
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            elevation: 2,
                          ),
                        ),
                            )
                          ]
                          ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.title,
                          style: TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          product.brand ?? 'Unknown Brand',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '₹${product.price.toStringAsFixed(2)}',
                              style:const TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '₹${(product.price*(1-product.discountPercentage/100)).toStringAsFixed(2)}',
                              style:const  TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 4),
                        Text(
                          '   ${product.discountPercentage.toStringAsFixed(2)}% OFF',
                          style: TextStyle(color: Colors.green, fontSize: 12),
                        ),
                        SizedBox(height: 8),
                       
                      ],
              ),
            );
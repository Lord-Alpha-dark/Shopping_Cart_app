import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:shopping_cart_app/models/cart.dart';
import 'package:shopping_cart_app/models/product.dart';
import 'package:shopping_cart_app/providers/providers.dart';

 Logger logger=Logger();
class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({Key? key}) : super(key: key);
  @override

  ProductListScreenState createState() => ProductListScreenState();
}

class ProductListScreenState extends ConsumerState<ProductListScreen> {
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _isFetchingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent-50 && !_isFetchingMore) {
        _currentPage++;
        ref.refresh(productProvider(_currentPage));
        setState(() {
          _isFetchingMore = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productProvider(_currentPage));
    final cart = ref.watch(cartProvider);
    final allProducts = ref.watch(allProductsProvider);

   // Listen for changes to productsAsync and update allProductsProvider
    ref.listen<AsyncValue<List<Product>?>>(
      productProvider(_currentPage),
      (previous, next) {
        next.when(
          data: (newProducts) {
            if (newProducts != null) {
              final currentAllProducts = ref.read(allProductsProvider);
              if (_currentPage == 1) {
                ref.read(allProductsProvider.notifier).state = newProducts;
              } else if (newProducts.isNotEmpty) {
                ref.read(allProductsProvider.notifier).state = [...currentAllProducts, ...newProducts];
              }
              logger.i("Updated allProducts: ${ref.read(allProductsProvider).length} items");
            }
            setState(() {
              _isFetchingMore = false;
            });
          },
          loading: () {
            // Do nothing; _isFetchingMore is already true
          },
          error: (err, _) {
            logger.e("Error fetching products: $err");
            setState(() {
              _isFetchingMore = false;
            });
          },
        );
      },
    );
    
   
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 249, 175, 200),
      appBar: AppBar(
        title:  const Padding(
          padding:  EdgeInsets.only(left: 92),
          child: Text(' Catalogue',style: TextStyle(fontWeight: FontWeight.w600,fontSize: 28),),
        ),
        backgroundColor: const Color.fromARGB(255, 249, 175, 200),
        actions: [
          Stack(
            children:[
              IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: (){

                },),
                if(cart.isNotEmpty)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text("${cart.length}",style: TextStyle(color: Colors.white, fontSize: 10),
                   textAlign: TextAlign.center,),
                    ) ) 
            ]
          )
        ],
      ),
      body: productsAsync.when(
        data: (products) => GridView.builder(
          controller: _scrollController,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.58),
            itemCount: allProducts.length +(_isFetchingMore ? 1 : 0),
           itemBuilder: (context,index){
            if(index==allProducts.length && _isFetchingMore)
            {
              return const Center(child: CircularProgressIndicator());
            }
            final product = allProducts[index];
            return Card(
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
           }
           ),
           loading: () => Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        
      )
    );
  }
}
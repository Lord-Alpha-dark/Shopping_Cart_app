
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:shopping_cart_app/models/product.dart';
import 'package:shopping_cart_app/providers/providers.dart';
import 'package:shopping_cart_app/screens/cart_screen.dart';
import 'package:shopping_cart_app/screens/components/product_card.dart';

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

   // Listening for changes to productsAsync and update allProductsProvider
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartScreen()),
                  );
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
            return productCard(product,ref);
           }
           ),
           loading: () => Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        
      )
    );
  }
}
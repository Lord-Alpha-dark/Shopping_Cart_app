import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:shopping_cart_app/models/product.dart';
import 'package:http/http.dart' as http;

final logger=Logger();
class ProductService {
  Future<List<Product>?> getProducts(int page,int limit) async {
      try {
         final response = await http.get(Uri.parse('https://dummyjson.com/products?page=$page&limit=$limit'));
         if(response.statusCode==200)
         {
          final Map<String,dynamic> data = json.decode(response.body);
          List<dynamic> list=data["products"];
          logger.i("Fetched ${list.length} items");
          return list.map((value)=>Product.fromJson(value)).toList();
         }
         else
         {
           logger.e("Error fetching Items: ${response.body}");
           return null;
         }
      } catch (error) {
         logger.e("Error fetching Items: $error");
         return null;
      } 
  } 
}



import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:i_mart/views/inner_screens/product_detail.dart';

class AllProductsScreen extends StatelessWidget {
  const AllProductsScreen({super.key});

  // Function to fetch all products from Firestore
  Future<List<Map<String, dynamic>>> _fetchAllProducts() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('products').get();
      return querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['productName'],
          'price': doc['price'],
          'discountPrice': doc['discountPrice'],
          'brand': doc['brand'],
          'imageUrl': (doc.data().containsKey('productImages') && (doc['productImages'] as List).isNotEmpty)
              ? doc['productImages'][0]
              : 'https://example.com/default_product_image.jpg',
        };
      }).toList();
    } catch (e) {
      print("Error fetching products: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context){ 
    return Scaffold(
      appBar: AppBar(
        title: Text('All Products'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchAllProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error fetching products'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No products available'));
          }

          final products = snapshot.data!;
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.6,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetail(productId: products[index]['id']),
                    ),
                  );
                },
                child: _buildProductCard(products[index]),
              );
            },
          );
        },
      ),
    );
  }

  // Build individual product card
  Widget _buildProductCard(Map<String, dynamic> product) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              product['imageUrl'],
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.network('https://example.com/default_product_image.jpg', height: 120, width: double.infinity, fit: BoxFit.cover);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product['name'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('Price: ₹${product['price'].toStringAsFixed(2)}', style: TextStyle(color: Colors.green)),
                if (product['discountPrice'] != null && product['discountPrice'] > 0)
                  Text('Discount Price: ₹${product['discountPrice'].toStringAsFixed(2)}', style: TextStyle(color: Colors.red)),
                if (product['brand'] != null) Text('Brand: ${product['brand']}', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

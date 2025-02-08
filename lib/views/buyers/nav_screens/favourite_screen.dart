import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_mart/provider/product_provider.dart' as product_provider;
import 'package:i_mart/views/buyers/main_screen.dart';
import 'package:i_mart/provider/auth_provider.dart';
import 'package:i_mart/views/buyers/nav_screens/cart_screen.dart';
import 'package:i_mart/views/inner_screens/product_detail.dart';

class FavoriteScreen extends ConsumerWidget {
  const FavoriteScreen({super.key});

  Future<List<Map<String, dynamic>>> fetchFavoriteProducts(String userId) async {
    try {
      QuerySnapshot favoriteSnapshot = await FirebaseFirestore.instance
          .collection('favorites')
          .where('userId', isEqualTo: userId)
          .get();

      List<Map<String, dynamic>> favoriteProducts = [];
      for (var favoriteDoc in favoriteSnapshot.docs) {
        String productId = favoriteDoc['productId'];
        DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
            .collection('products')
            .doc(productId)
            .get();

        if (productSnapshot.exists) {
          favoriteProducts.add(productSnapshot.data() as Map<String, dynamic>..['documentId'] = favoriteDoc.id);
        } else {
          print("Product not found for ID: $productId");
        }
      }
      return favoriteProducts;
    } catch (e) {
      print("Error fetching favorite products: $e");
      return []; // Return an empty list on error
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.read(authProvider).currentUser?.uid; 
    if (userId == null) {
      return const Center(child: Text('Please log in to see favorites.'));
    }

    final _cartProvider = ref.read(product_provider.cartProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Favorites',
          style: GoogleFonts.lato(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => CartScreenProduct()));
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>( 
        future: fetchFavoriteProducts(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print("Snapshot error: ${snapshot.error}");
            return const Center(child: Text('Error loading favorite products.'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Your wishlist is empty\nYou can add products to your wishlist from the button below.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(fontSize: 17, letterSpacing: 1.7),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return mainscreen(); // Ensure your MainScreen widget is correctly referenced
                      }));
                    },
                    child: Text('Add Item'),
                  ),
                ],
              ),
            );
          }

          final favoriteProducts = snapshot.data!;

          return ListView.builder(
            itemCount: favoriteProducts.length,
            itemBuilder: (context, index) {
              final product = favoriteProducts[index];

              // Add null checks here
              String productId = product['productId'] ?? 'N/A';
              String productName = product['productName'] ?? 'Unknown Product';
              double price = product['price'] ?? 0.0;
              List<dynamic> productImages = product['productImages'] ?? [''];
              String imageUrl = productImages.isNotEmpty ? productImages[0] : '';

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetail(productId: productId),
                              ),
                            );
                          },
                          child: Image.network(
                            imageUrl,
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                productName,
                                style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '₹${price.toStringAsFixed(2)}',
                                style: GoogleFonts.lato(color: Colors.green),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add_shopping_cart),
                          onPressed: () async {
                            // Use the CartNotifier's addProductToCart method
                            await _cartProvider.addProductToCart(
                              productName: productName,
                              productPrice: price,
                              catgoryName: product['categoryName'] ?? 'N/A',
                              imageUrl: productImages,
                              quantity: 1,
                              productId: productId,
                              productSize: product['size'] ?? 'N/A',
                              discount: product['discount'] ?? 0,
                              description: product['description'] ?? '',
                              storeId: product['vendorId'] ?? '',
                            );

                            // Show success message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('$productName added to cart!'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
} 
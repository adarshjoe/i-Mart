import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_mart/provider/auth_provider.dart';
import 'package:i_mart/views/buyers/nav_screens/favourite_screen.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

// CartItem class
class CartItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;

  CartItem({required this.productId, required this.productName, required this.price, this.quantity = 1});
}

// Provider for cart state management
final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

// CartNotifier class
class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addToCart(CartItem item) {
    final existingIndex = state.indexWhere((cartItem) => cartItem.productId == item.productId);
    if (existingIndex >= 0) {
      final updatedItem = state[existingIndex];
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == existingIndex)
            CartItem(
              productId: updatedItem.productId,
              productName: updatedItem.productName,
              price: updatedItem.price,
              quantity: updatedItem.quantity + 1,
            )
          else
            state[i]
      ];
    } else {
      state = [...state, item];
    }
  }

  void removeFromCart(String productId) {
    state = state.where((item) => item.productId != productId).toList();
  }

  Future<void> fetchCartItems(String userId) async {
    final snapshot = await FirebaseFirestore.instance.collection('cart').where('userId', isEqualTo: userId).get();
    state = snapshot.docs.map((doc) {
      final data = doc.data();
      return CartItem(
        productId: data['productId'],
        productName: data['productName'],
        price: data['price'],
        quantity: data['quantity'],
      );
    }).toList();
  }
}

class ProductDetail extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetail({Key? key, required this.productId}) : super(key: key);

  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends ConsumerState<ProductDetail> {
  late Future<DocumentSnapshot> productSnapshot;
  late Future<DocumentSnapshot> vendorSnapshot;
  late Future<List<Map<String, dynamic>>> reviewsSnapshot;

  bool isFavorite = false;
  double reviewRating = 0.0;
  final TextEditingController reviewController = TextEditingController();
  String userFullName = ''; 
  String? userId; 

  @override
  void initState() {
    super.initState();
    userId = ref.read(authProvider).currentUser?.uid;
    productSnapshot = FirebaseFirestore.instance.collection('products').doc(widget.productId).get();
    reviewsSnapshot = fetchReviews(widget.productId);
    checkIfFavorite();
    fetchUserFullName();
  }

  Future<void> fetchUserFullName() async {
    if (userId != null) {
      final userSnapshot = await FirebaseFirestore.instance.collection('buyers').doc(userId).get();
      if (userSnapshot.exists && userSnapshot.data() != null) {
        setState(() {
          userFullName = userSnapshot.data()?['fullName'] ?? '';
        });
      }
    }
  }

  Future<void> checkIfFavorite() async {
    if (userId != null) {
      final favoriteSnapshot = await FirebaseFirestore.instance
          .collection('favorites')
          .where('productId', isEqualTo: widget.productId)
          .where('userId', isEqualTo: userId)
          .get();
      if (favoriteSnapshot.docs.isNotEmpty) {
        setState(() {
          isFavorite = true;
        });
      }
    }
  }

  Future<DocumentSnapshot> fetchVendor(String vendorId) {
    return FirebaseFirestore.instance.collection('vendors').doc(vendorId).get();
  }

  Future<List<Map<String, dynamic>>> fetchReviews(String productId) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('reviews')
        .where('productId', isEqualTo: productId)
        .get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  void toggleFavorite() async {
    setState(() {
      isFavorite = !isFavorite;
    });

    if (isFavorite) {
      await FirebaseFirestore.instance.collection('favorites').add({
        'userId': userId,
        'productId': widget.productId,
        'addedAt': Timestamp.now(),
      });
    } else {
      final favoriteSnapshot = await FirebaseFirestore.instance
          .collection('favorites')
          .where('productId', isEqualTo: widget.productId)
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in favoriteSnapshot.docs) {
        await doc.reference.delete();
      }
    }
  }

  Future<void> submitReview(double rating, String reviewText) async {
    await FirebaseFirestore.instance.collection('reviews').add({
      'productId': widget.productId,
      'buyerName': userFullName,
      'rating': rating,
      'review': reviewText,
      'createdAt': Timestamp.now(),
    });
    setState(() {
      reviewsSnapshot = fetchReviews(widget.productId);
    });
    reviewController.clear();
    setState(() {
      reviewRating = 0.0;
    });
  }

  Future<void> addToCartFirestore(CartItem item) async {
    if (userId != null) {
      await FirebaseFirestore.instance.collection('cart').add({
        'userId': userId,
        'productId': item.productId,
        'productName': item.productName,
        'price': item.price,
        'quantity': item.quantity,
        'addedAt': Timestamp.now(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: productSnapshot,
      builder: (context, productSnapshot) {
        if (productSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (productSnapshot.hasError) {
          return const Center(child: Text('Error loading product.'));
        }
        if (!productSnapshot.hasData || productSnapshot.data == null) {
          return const Center(child: Text('Product not found.'));
        }

        final productData = productSnapshot.data!.data() as Map<String, dynamic>;
        if (productData.isEmpty) {
          return const Center(child: Text('Product data is null.'));
        }
        vendorSnapshot = fetchVendor(productData['vendorId']);

        return FutureBuilder<DocumentSnapshot>(
          future: vendorSnapshot,
          builder: (context, vendorSnapshot) {
            if (vendorSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (vendorSnapshot.hasError) {
              return const Center(child: Text('Error loading vendor.'));
            }
            if (!vendorSnapshot.hasData || vendorSnapshot.data == null) {
              return const Center(child: Text('Vendor not found.'));
            }

            final vendorData = vendorSnapshot.data!.data() as Map<String, dynamic>;
            if (vendorData.isEmpty) {
              return const Center(child: Text('Vendor data is null.'));
            }

            return Scaffold(
              appBar: AppBar(
                title: Text('Product Details', style: GoogleFonts.lato()),
                actions: [
                  IconButton(
                    icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                    color: isFavorite ? Colors.red : null,
                    onPressed: toggleFavorite,
                  ),
                  IconButton(
                    icon: const Icon(Icons.favorite),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const FavoriteScreen()),
                      );
                    },
                  ),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Images
                    SizedBox(
                      height: 300,
                      child: PageView.builder(
                        itemCount: (productData['productImages'] as List?)?.length ?? 0,
                        itemBuilder: (context, index) {
                          return Image.network(
                            productData['productImages']?[index] ?? '',
                            fit: BoxFit.cover,
                            width: double.infinity,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),

                         // Product Name and Price
                    Text(productData['productName'] ?? '', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text('Discount Price: ₹${productData['discountPrice']?.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green, fontSize: 20)),
                    Text('Original Price: ₹${productData['price']?.toStringAsFixed(2)}', style: const TextStyle(color: Colors.red, fontSize: 16, decoration: TextDecoration.lineThrough)),
                    const SizedBox(height: 20),

                    // Product Details
                    Text('Brand: ${productData['brand'] ?? ''}', style: const TextStyle(fontSize: 16)),
                    Text('Size: ${productData['size'] ?? ''}', style: const TextStyle(fontSize: 16)),
                    Text('Warranty: ${productData['warranty'] ?? ''}', style: const TextStyle(fontSize: 16)),
                    Text('Year of Manufacture: ${productData['yearOfManufacture'] ?? ''}', style: const TextStyle(fontSize: 16)),
                    Text('Description: ${productData['description'] ?? ''}', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 20),

                    // Vendor Details
                    Text('Vendor: ${vendorData['companyName'] ?? ''}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('Address: ${vendorData['address'] ?? ''}', style: const TextStyle(fontSize: 16)),
                    Text('Phone: ${vendorData['companyNumber'] ?? ''}', style: const TextStyle(fontSize: 16)), 
                    Text('Email: ${vendorData['email'] ?? ''}', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 20),

                    const SizedBox(height: 20),

                    // Add to Cart Button
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          final cartItem = CartItem(
                            productId: widget.productId,
                            productName: productData['productName'] ?? '',
                            price: productData['discountPrice'] ?? 0.0,
                          );

                          // Check if the item is already in the cart
                          final existingSnapshot = await FirebaseFirestore.instance
                              .collection('cart')
                              .where('userId', isEqualTo: userId)
                              .where('productId', isEqualTo: cartItem.productId)
                              .get();

                          if (existingSnapshot.docs.isNotEmpty) {
                            // Item already in cart, show a message
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item already in cart')));
                          } else {
                            // Item not in cart, add it
                            await addToCartFirestore(cartItem);
                            ref.read(cartProvider.notifier).addToCart(cartItem);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to Cart')));
                          }
                        },
                        child: const Text('Add to Cart'),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Reviews Section
                    Text('Reviews:', style: const TextStyle(fontSize: 20)),
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: reviewsSnapshot,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return const Center(child: Text('Error loading reviews.'));
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text('No reviews yet.'));
                        }

                        return Column(
                          children: snapshot.data!.map((review) {
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(review['buyerName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                    RatingBarIndicator(
                                      rating: review['rating'].toDouble(),
                                      itemCount: 5,
                                      itemSize: 20.0,
                                      direction: Axis.horizontal,
                                      unratedColor: Colors.grey,
                                      itemBuilder: (context, index) => const Icon(Icons.star, color: Colors.amber),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(review['review']),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),

                    // Submit Review Section
                    const SizedBox(height: 20),
                    Text('Submit your review:', style: const TextStyle(fontSize: 20)),
                    RatingBar.builder(
                      initialRating: reviewRating,
                      minRating: 1,
                      itemCount: 5,
                      itemSize: 40.0,
                      direction: Axis.horizontal,
                      itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                      onRatingUpdate: (rating) {
                        setState(() {
                          reviewRating = rating;
                        });
                      },
                    ),
                    TextField(
                      controller: reviewController,
                      decoration: const InputDecoration(labelText: 'Write your review'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (reviewController.text.isNotEmpty) {
                          submitReview(reviewRating, reviewController.text);
                        }
                      },
                      child: const Text('Submit Review'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

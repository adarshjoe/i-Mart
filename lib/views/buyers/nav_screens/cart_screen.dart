
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i_mart/views/buyers/main_screen.dart';
import 'package:i_mart/views/buyers/nav_screens/checkoutscreen.dart';
import 'package:i_mart/views/buyers/nav_screens/widgets/cart_item.dart';
import 'package:i_mart/views/inner_screens/product_detail.dart' hide CartItem;
import 'package:intl/intl.dart'; // For currency formatting

class CartScreenProduct extends ConsumerStatefulWidget {
  const CartScreenProduct({Key? key}) : super(key: key);

  @override
  _CartScreenProductState createState() => _CartScreenProductState();
}

class _CartScreenProductState extends ConsumerState<CartScreenProduct> {
  late String userId;
  double totalAmount = 0.0; // Keep as double for calculations
  String username = ''; // Variable to hold the username
  List<bool> _selectedItems = []; // Track selected items
  List<DocumentSnapshot> cartItems = []; // Declare cartItems here
  bool isLoading = true; // Loading state for data fetching

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser!.uid;
    fetchData();
  }

  Future<void> fetchData() async {
    username = await fetchUsername();
    cartItems = await fetchCartItems();

    // Initialize selection state only if there are items in the cart
    if (cartItems.isNotEmpty) {
      _selectedItems = List.generate(cartItems.length, (index) => false);
      updateTotalAmount();
    }

    // Using a setState call outside the FutureBuilder to ensure it doesn't conflict with the build phase
    if (mounted) {
      setState(() {
        isLoading = false; // Update loading state
      });
    }
  }

  Future<String> fetchUsername() async {
    try {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('buyers')
          .doc(userId)
          .get();

      if (userSnapshot.exists) {
        return (userSnapshot.data() as Map<String, dynamic>)['fullName'] ?? 'Unknown User';
      }
    } catch (e) {
      print('Error fetching username: $e');
    }
    return 'Unknown User'; // Default value
  }

  Future<List<DocumentSnapshot>> fetchCartItems() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('cart')
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs; // Return the list of cart items
    } catch (e) {
      print('Error fetching cart items: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> fetchProductDetails(String productId) async {
    try {
      DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get();

      if (productSnapshot.exists) {
        return productSnapshot.data() as Map<String, dynamic>?; 
      }
    } catch (e) {
      // Handle potential errors in fetching product data
      print(' $e');
    }
    return null;
  }

  void updateTotalAmount() {
    totalAmount = 0.0; // Reset the total
    for (var index = 0; index < cartItems.length; index++) {
      if (_selectedItems[index]) { // Only calculate total for selected items
        final itemData = cartItems[index].data() as Map<String, dynamic>;
        final productPrice = (itemData['price'] as num?)?.toDouble() ?? 0.00;
        final quantity = itemData['quantity'] ?? 1;
        totalAmount += productPrice * quantity;
      }
    }
    if (mounted) {
      setState(() {}); // Trigger UI update after recalculating the total
    }
  }

  void incrementQuantity(int index) {
    final itemData = cartItems[index].data() as Map<String, dynamic>;
    final currentQuantity = itemData['quantity'] ?? 1;
    FirebaseFirestore.instance
        .collection('cart')
        .doc(cartItems[index].id)
        .update({'quantity': currentQuantity + 1}).then((_) {
      fetchData(); // Refresh the cart items after increment
    });
  }

  void decrementQuantity(int index) {
    final itemData = cartItems[index].data() as Map<String, dynamic>;
    final currentQuantity = itemData['quantity'] ?? 1;

    if (currentQuantity > 1) {
      FirebaseFirestore.instance
          .collection('cart')
          .doc(cartItems[index].id)
          .update({'quantity': currentQuantity - 1}).then((_) {
        fetchData(); // Refresh the cart items after decrement
      });
    }
  }

  void removeItem(int index) {
    FirebaseFirestore.instance
        .collection('cart')
        .doc(cartItems[index].id)
        .delete().then((_) {
      fetchData(); // Refresh the cart items after removal
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Cart',
          style: GoogleFonts.lato(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF102DE1),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Your shopping cart is empty.\nYou can add products to your cart from the shop.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(fontSize: 17),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.to(() => const mainscreen());
                        },
                        child: const Text('Shop Now'),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: cartItems.length,
                          itemBuilder: (context, index) {
                            final item = cartItems[index].data() as Map<String, dynamic>;
                            final productId = item['productId'] ?? 'unknown_id';
                            final quantity = (item['quantity'] as num?)?.toInt() ?? 1;

                            return FutureBuilder<Map<String, dynamic>?>( // Use FutureBuilder for product details
                              future: fetchProductDetails(productId),
                              builder: (context, productSnapshot) {
                                if (productSnapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator());
                                }
                                if (productSnapshot.hasError || !productSnapshot.hasData) {
                                  return const Center(child: Text(''));
                                }

                                final productDetails = productSnapshot.data!;
                                final productName = productDetails['productName'] ?? 'Unknown Product';
                                final productPrice = (productDetails['price'] as num?)?.toDouble() ?? 0.00;
                                final productDiscountPrice = (productDetails['discountPrice'] as num?)?.toDouble();

                                // Format prices to show currency
                                final formattedPrice = NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(
                                  productDiscountPrice ?? productPrice // Show discount price if available
                                );

                                final formattedDiscountPrice = productDiscountPrice != null 
                                    ? NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(productPrice) 
                                    : '';

                                return GestureDetector(
                                  onTap: () {
                                    Get.to(() => ProductDetail(productId: productId));
                                  },
                                  child: CartItem(
                                    productName: productName,
                                    productPrice: formattedPrice, // Use the formatted price
                                    discountPrice: formattedDiscountPrice.isNotEmpty ? formattedDiscountPrice : '', // Show discount price if available
                                    quantity: quantity.toInt(), // Updated to string for display
                                    productImage: productDetails['productImages']?[0] ?? '',
                                    productBrand: productDetails['brand'] ?? 'Unknown Brand',
                                    isSelected: _selectedItems[index], // Pass selection state
                                    onSelect: () {
                                      setState(() {
                                        _selectedItems[index] = !_selectedItems[index]; // Toggle selection
                                      });
                                      updateTotalAmount(); // Update total after selection
                                    },
                                    onIncrement: () => incrementQuantity(index),
                                    onDecrement: () => decrementQuantity(index),
                                    onRemove: () => removeItem(index),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16.0), // Space before total amount
                      Text(
                        'Total: ${NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(totalAmount)}', 
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16.0), // Space before the button
                      ElevatedButton(
                        onPressed: totalAmount > 0 ? () {
                          // Handle checkout with selected items
                          List<Map<String, dynamic>> selectedProducts = [];
                          for (var index = 0; index < cartItems.length; index++) {
                            if (_selectedItems[index]) {
                              selectedProducts.add({
                                'productId': cartItems[index]['productId'],
                                'quantity': cartItems[index]['quantity'],
                                
                              });
                            }
                          }
                          Get.to(() => Checkoutscreen( selectedProducts: selectedProducts,totalAmount: totalAmount, username: username, userId: userId));
                        } : null, // Disable button if total amount is zero
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF102DE1), // Button color
                          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0), // Button padding
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0), // Rounded corners
                          ),
                        ),
                        child: const Text(
                          'Proceed to Checkout',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}





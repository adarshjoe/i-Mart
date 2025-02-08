import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:i_mart/models/product_models.dart';
import 'package:firebase_auth/firebase_auth.dart';

final cartProvider = StateNotifierProvider<CartNotifier, Map<String, CartModel>>(
  (ref) => CartNotifier(),
);

class CartNotifier extends StateNotifier<Map<String, CartModel>> {
  CartNotifier() : super({});

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Fetch cart data from Firestore when initializing
  Future<void> fetchCartItems() async {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final cartSnapshot = await _firestore.collection('cart').doc(uid).get();
    if (cartSnapshot.exists) {
      Map<String, dynamic> cartData = cartSnapshot.data() as Map<String, dynamic>;
      Map<String, CartModel> cartItems = {};
      cartData.forEach((key, value) {
        cartItems[key] = CartModel.fromFirestore(value as Map<String, dynamic>);
      });
      state = cartItems;
    }
  }

  // Add or update a product in the cart
  Future<void> addProductToCart({
    required String productName,
    required num productPrice,
    required String catgoryName,
    required List imageUrl,
    required int quantity,
    required String productId,
    required String productSize,
    required num discount,
    required String description,
    required String storeId,
  }) async {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return;

    if (state.containsKey(productId)) {
      // Update the quantity of the existing product
      state[productId]!.quantity += 1; // Increment quantity
    } else {
      // Add a new product to the cart
      state[productId] = CartModel(
        productId: productId,
        productName: productName,
        productPrice: productPrice,
        catgoryName: catgoryName,
        quantity: quantity,
        imageUrl: imageUrl,
        productSize: productSize,
        discount: discount,
        description: description,
        storeId: storeId,
      );
    }

    // Update Firestore
    await _firestore.collection('cart').doc(uid).set({
      productId: {
        'productId': productId,
        'productName': productName,
        'productPrice': productPrice,
        'catgoryName': catgoryName,
        'quantity': state[productId]!.quantity,
        'imageUrl': imageUrl,
        'productSize': productSize,
        'discount': discount,
        'description': description,
        'storeId': storeId,
      }
    }, SetOptions(merge: true));
  }

  Future<void> removeItem(String productId) async {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return;

    // Check if the product ID exists in the current cart state
    if (state.containsKey(productId)) {
      state.remove(productId);
      state = {...state}; // Update state

      // Check if the cart document exists before trying to remove the item
      final cartDoc = await _firestore.collection('cart').doc(uid).get();
      if (cartDoc.exists) {
        // Remove item from Firestore
        await _firestore.collection('cart').doc(uid).update({
          productId: FieldValue.delete(),
        });
      } else {
        // Handle the case where the document does not exist
        print('Cart document for user $uid does not exist.');
      }
    } else {
      print('Product ID $productId not found in cart state.');
    }
  }

  void incrementItem(String productId) {
    if (state.containsKey(productId)) {
      state[productId]!.quantity++;
      state = {...state}; // Notify listeners
    }
  }

  void decrementItem(String productId) {
    if (state.containsKey(productId) && state[productId]!.quantity > 1) {
      state[productId]!.quantity--;
      state = {...state}; // Notify listeners
    }
  }

  double calculateTotalAmount() {
    double totalAmount = 0.0;
    state.forEach((productId, cartItem) {
      totalAmount += cartItem.quantity * cartItem.productPrice; // Ensure to use productPrice
    });
    return totalAmount;
  }

  Map<String, CartModel> get getCartItems => state;

  // Add item method (not used currently)
  void addItem(product) {
    // This could be implemented if needed
  }
}

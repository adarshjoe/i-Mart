import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'order_detail_screen.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    // Check if the user is logged in
    if (userId == null) {
      return Center(child: Text('User not logged in.'));
    }

    // Stream to fetch all orders for the logged-in user
    final Stream<QuerySnapshot> _ordersStream = FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: userId) // Fetch orders based on the logged-in user's ID
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text('My Orders', style: GoogleFonts.lato(color: Colors.white)),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _ordersStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data?.docs.isEmpty ?? true) {
            return Center(
              child: Text(
                'No orders found.',
                style: GoogleFonts.lato(fontSize: 18, color: Colors.black54),
              ),
            );
          }

          // Build the order cards for each order document
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final orderData = snapshot.data!.docs[index];
              return _buildOrderCard(context, orderData);
            },
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>?> fetchProductDetails(String productId) async {
    try {
      // Fetch the product document from the 'products' collection
      final productSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get();

      if (productSnapshot.exists) {
        return productSnapshot.data(); // Return the product data including the image
      }
    } catch (e) {
      print('Error fetching product details: $e');
    }
    return null;
  }

  Widget _buildOrderCard(BuildContext context, QueryDocumentSnapshot orderData) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Column(
        children: [
          FutureBuilder<List<Widget>>(
            future: _buildProductList(orderData),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }

              if (snapshot.hasError) {
                return Text('Error fetching products: ${snapshot.error}');
              }

              return Column(children: snapshot.data ?? []);
            },
          ),
          ListTile(
            title: Text('Total Amount: ₹${orderData['totalAmount']}', style: GoogleFonts.lato(color: Colors.green)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order Status: ${orderData['orderStatus']}', style: GoogleFonts.lato(color: Colors.orange)),
                Text('Ordered At: ${orderData['orderedAt'].toDate().toString()}', style: GoogleFonts.lato(color: Colors.black54)), // Format the timestamp
                Text('Payment Method: ${orderData['paymentMethod']}', style: GoogleFonts.lato(color: Colors.black54)),
                Text('Phone Number: ${orderData['phoneNumber']}', style: GoogleFonts.lato(color: Colors.black54)),
                Text('Address: ${orderData['address']}', style: GoogleFonts.lato(color: Colors.black54)),
                Text('City: ${orderData['city']}', style: GoogleFonts.lato(color: Colors.black54)),
                Text('Pincode: ${orderData['pincode']}', style: GoogleFonts.lato(color: Colors.black54)),
              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                await FirebaseFirestore.instance.collection('orders').doc(orderData.id).delete();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order cancelled successfully.')));
              },
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderDetailScreen(orderId: orderData.id), // Correct instantiation
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<List<Widget>> _buildProductList(QueryDocumentSnapshot orderData) async {
    List<Widget> productWidgets = [];
    List selectedProducts = orderData['selectedProducts']; // Assuming selectedProducts is an array of maps with productId and quantity

    for (var product in selectedProducts) {
      String productId = product['productId']; // Get the product ID from the order
      int quantity = product['quantity']; // Get the quantity

      // Fetch the product details (including image) using the productId
      Map<String, dynamic>? productDetails = await fetchProductDetails(productId);

      if (productDetails != null) {
        // Use the 'productImages' field to fetch the product image URL
        List<dynamic> images = productDetails['productImages'];
        String imageUrl = images.isNotEmpty ? images[0] : ''; // Use the first image from the list

        productWidgets.add(
          ListTile(
            leading: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // If there's an error loading the image, display a placeholder
                      return Icon(Icons.image_not_supported, size: 50, color: Colors.grey);
                    },
                  )
                : Icon(Icons.image_not_supported, size: 50, color: Colors.grey), // Fallback if no image URL is available
            title: Text(productDetails['productName'], style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
            subtitle: Text('Quantity: $quantity', style: GoogleFonts.lato(color: Colors.black54)),
          ),
        );
      } else {
        // Handle the case where product details are not found
        productWidgets.add(Text('Product not found for ID: $productId'));
      }
    }

    return productWidgets;
  }
}

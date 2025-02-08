import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_mart/vendor/screens/inner_screens/vendor_order_detail.dart';

class VendorOrderScreen extends StatefulWidget {
  const VendorOrderScreen({Key? key}) : super(key: key);

  @override
  _VendorOrderScreenState createState() => _VendorOrderScreenState();
}

class _VendorOrderScreenState extends State<VendorOrderScreen> {
  @override
  Widget build(BuildContext context) {
    final vendorId = FirebaseAuth.instance.currentUser?.uid;

    // Check if the vendor is logged in
    if (vendorId == null) {
      return Center(child: Text('Vendor not logged in.'));
    }

    // Stream to fetch all orders
    final Stream<QuerySnapshot> _ordersStream = FirebaseFirestore.instance
        .collection('orders')
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text('Vendor Orders', style: GoogleFonts.lato(color: Colors.white)),
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

          // Fetch all products for the logged-in vendor
          return FutureBuilder<List<String>>(
            future: _fetchVendorProductIds(vendorId),
            builder: (context, vendorProductsSnapshot) {
              if (vendorProductsSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (vendorProductsSnapshot.hasError) {
                return Center(child: Text('Error fetching vendor products: ${vendorProductsSnapshot.error}'));
              }

              List<String> vendorProductIds = vendorProductsSnapshot.data ?? [];
              // Filter orders based on the vendor's products
              final List<QueryDocumentSnapshot> vendorOrders = snapshot.data!.docs.where((order) {
                final selectedProducts = order['selectedProducts'];
                if (selectedProducts is List) {
                  return selectedProducts.any((product) => vendorProductIds.contains(product['productId']));
                } else {
                  return false; // Return false if it's not a list
                }
              }).toList();

              if (vendorOrders.isEmpty) {
                return Center(
                  child: Text(
                    'No orders found for this vendor.',
                    style: GoogleFonts.lato(fontSize: 18, color: Colors.black54),
                  ),
                );
              }

              // Build the order cards for each order document
              return ListView.builder(
                itemCount: vendorOrders.length,
                itemBuilder: (context, index) {
                  final orderData = vendorOrders[index];
                  return _buildOrderCard(context, orderData, vendorId); // Pass vendorId here
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<List<String>> _fetchVendorProductIds(String vendorId) async {
    final productSnapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('vendorId', isEqualTo: vendorId)
        .get();

    return productSnapshot.docs.map((doc) => doc['productId'] as String).toList();
  }

  Widget _buildOrderCard(BuildContext context, QueryDocumentSnapshot orderData, String vendorId) {
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
                Text('Ordered At: ${orderData['orderedAt'].toDate().toString()}', style: GoogleFonts.lato(color: Colors.black54)),
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
                String orderStatus = orderData['orderStatus'];
                List<dynamic> selectedProducts = orderData['selectedProducts'];

                if (orderStatus == 'Delivered') {
                  // Remove from screen without deleting from Firestore
                  setState(() {
                    // Optionally remove this order from the vendorOrders list in the UI
                  });
                  _showMessage(context, 'Order marked as delivered. Cannot delete.');
                } else {
                  // Show confirmation dialog for cancellation
                  bool? shouldCancel = await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Cancel Order'),
                        content: Text('This order will be marked as cancelled. Do you want to proceed?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true), // Yes
                            child: Text('Yes'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false), // No
                            child: Text('No'),
                          ),
                        ],
                      );
                    },
                  );

                  if (shouldCancel == true) {
                    bool canCancel = selectedProducts.every((product) => product['isReadyForDelivery'] != true);
                    if (canCancel) {
                      await _cancelOrder(context, orderData.id); // Mark as cancelled without deleting
                    } else {
                      _showMessage(context, 'You cannot cancel items that are ready for delivery.');
                    }
                  }
                }
              },
            ),
            onTap: () {
              // Navigate to the VendorOrderDetailScreen with order data
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VendorOrderDetailScreen(orderId: orderData.id, currentVendorId: vendorId),
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
    final selectedProducts = orderData['selectedProducts'];

    if (selectedProducts is List) {
      for (var product in selectedProducts) {
        String productId = product['productId'];
        Map<String, dynamic>? productDetails = await fetchProductDetails(productId);
        if (productDetails != null) {
          productWidgets.add(
            ListTile(
              leading: Image.network(productDetails['productImages'][0], width: 50, height: 50, fit: BoxFit.cover),
              title: Text(productDetails['productName'], style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
              subtitle: Text('Quantity: ${product['quantity']}', style: GoogleFonts.lato(color: Colors.black54)),
            ),
          );
        } else {
          productWidgets.add(Text('Product not found for ID: $productId'));
        }
      }
    } else {
      productWidgets.add(Text('No products found for this order.'));
    }

    return productWidgets;
  }

  Future<Map<String, dynamic>?> fetchProductDetails(String productId) async {
    final productSnapshot = await FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .get();

    return productSnapshot.exists ? productSnapshot.data() : null;
  }

  Future<void> _cancelOrder(BuildContext context, String orderId) async {
    await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'orderStatus': 'Cancelled', // Update the order status to 'Cancelled'
    });

    _showMessage(context, 'Order successfully cancelled.');
  }

  void _showMessage(BuildContext context, String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}

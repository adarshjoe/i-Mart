import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_mart/views/inner_screens/product_detail.dart';

class OrderDetailScreen extends StatelessWidget {
  final String orderId;

  const OrderDetailScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DocumentReference orderRef =
        FirebaseFirestore.instance.collection('orders').doc(orderId);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Order Details',
          style: GoogleFonts.lato(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: orderRef.get(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final orderData = snapshot.data!;
          List selectedProducts = orderData['selectedProducts'] ?? [];

          return Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order ID: ${orderData.id}',
                    style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Total Amount: ₹${orderData['totalAmount']}',
                    style: GoogleFonts.lato(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Payment Method: ${orderData['paymentMethod']}',
                    style: GoogleFonts.lato(color: Colors.black54),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Order Status: ${orderData['orderStatus']}',
                    style: GoogleFonts.lato(color: Colors.orange),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Ordered At: ${orderData['orderedAt'].toDate().toString()}',
                    style: GoogleFonts.lato(color: Colors.black54),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Products:',
                    style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 5),
                  _buildProductsList(selectedProducts, context),
                  const SizedBox(height: 20),
                  Text(
                    'Shipping Address:',
                    style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Name: ${orderData['username']}',
                    style: GoogleFonts.lato(color: Colors.black54),
                  ),
                  Text(
                    'Address: ${orderData['address']}',
                    style: GoogleFonts.lato(color: Colors.black54),
                  ),
                  Text(
                    'City: ${orderData['city']}, Pincode: ${orderData['pincode']}',
                    style: GoogleFonts.lato(color: Colors.black54),
                  ),
                  Text(
                    'Landmark: ${orderData['landmark']}',
                    style: GoogleFonts.lato(color: Colors.black54),
                  ),
                  Text(
                    'Phone: ${orderData['phoneNumber']}',
                    style: GoogleFonts.lato(color: Colors.black54),
                  ),
                  if (orderData['alternativeNumber'] != "")
                    Text(
                      'Alternative Phone: ${orderData['alternativeNumber']}',
                      style: GoogleFonts.lato(color: Colors.black54),
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      Map<String, String?>? newAddressData = await _showEditAddressDialog(
                        context,
                        orderData['address'],
                        orderData['city'],
                        orderData['landmark'],
                      );
                      if (newAddressData != null) {
                        await orderRef.update({
                          'address': newAddressData['address'],
                          'city': newAddressData['city'],
                          'landmark': newAddressData['landmark'],
                        });
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Address updated successfully.')));
                      }
                    },
                    child: const Text('Edit Address'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      await orderRef.delete();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order deleted successfully.')));
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel Order'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Function to build product details list
  Widget _buildProductsList(List selectedProducts, BuildContext context) {
    return FutureBuilder<List<Widget>>(
      future: _fetchProductDetails(selectedProducts, context), // Pass context here
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error fetching product details: ${snapshot.error}'));
        }

        final productsWidgets = snapshot.data;

        if (productsWidgets == null || productsWidgets.isEmpty) {
          return Center(child: Text('No products found.'));
        }

        return ListView(
          shrinkWrap: true, // Prevents overflow in a Column
          physics: NeverScrollableScrollPhysics(), // Disable scrolling for ListView
          children: productsWidgets,
        );
      },
    );
  }

  // Function to fetch product details for selected products
  Future<List<Widget>> _fetchProductDetails(List selectedProducts, BuildContext context) async {
    List<Widget> productWidgets = [];

    for (var product in selectedProducts) {
      String productId = product['productId'];
      DocumentSnapshot productSnapshot = await FirebaseFirestore.instance.collection('products').doc(productId).get();

      if (productSnapshot.exists) {
        // Fetching necessary product details
        Map<String, dynamic> productData = productSnapshot.data() as Map<String, dynamic>; // Cast to Map
        String productName = productData['productName'] ?? 'Unknown Product';

        // Use null-aware access to safely get the image and price
        String productImage = productData['productImages'] != null && productData['productImages'].isNotEmpty 
            ? productData['productImages'][0] // Assuming the first image is used
            : ''; // Default image if not available
        double productPrice = product['price'] ?? productData['price'] ?? 0.0; // Correctly fetching original price
        double discountPrice = productData['discountPrice'] ?? productPrice; // Get discount price if available

        productWidgets.add(
          GestureDetector(
            onTap: () {
              // Navigate to Product Detail Screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetail(productId: productId), // Pass productId to ProductDetailScreen
                ),
              );
            },
            child: ListTile(
              leading: productImage.isNotEmpty
                  ? Image.network(productImage, fit: BoxFit.cover, width: 50, height: 50)
                  : Icon(Icons.image_not_supported, size: 50),
              title: Text(productName, style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Quantity: ${product['quantity']}', style: GoogleFonts.lato()),
                  Row(
                    children: [
                      Text(' ₹${productPrice.toStringAsFixed(2)}', style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.red)),
                      const SizedBox(width: 8),
                      Text(' ₹${discountPrice.toStringAsFixed(2)}', style: TextStyle(color: Colors.green)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        productWidgets.add(
          ListTile(
            title: Text('Product not found: ID $productId', style: GoogleFonts.lato(color: Colors.red)),
          ),
        );
      }
    }

    return productWidgets;
  }

  Future<Map<String, String?>?> _showEditAddressDialog(BuildContext context, String currentAddress, String currentCity, String currentLandmark) async {
    final TextEditingController addressController = TextEditingController(text: currentAddress);
    final TextEditingController cityController = TextEditingController(text: currentCity);
    final TextEditingController landmarkController = TextEditingController(text: currentLandmark);

    return showDialog<Map<String, String?>?>(context: context, builder: (context) {
      return AlertDialog(
        title: Text('Edit Address'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: addressController,
              decoration: InputDecoration(labelText: 'Address'),
            ),
            TextField(
              controller: cityController,
              decoration: InputDecoration(labelText: 'City'),
            ),
            TextField(
              controller: landmarkController,
              decoration: InputDecoration(labelText: 'Landmark'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, null); // Return null if cancelled
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, {
                'address': addressController.text,
                'city': cityController.text,
                'landmark': landmarkController.text,
              }); // Return updated address data
            },
            child: Text('Save'),
          ),
        ],
      );
    });
  }
}

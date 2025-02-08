import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_mart/views/inner_screens/product_detail.dart';

class DeliveryOrderDetailScreen extends StatelessWidget {
  final String orderId;

  const DeliveryOrderDetailScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DocumentReference orderRef =
        FirebaseFirestore.instance.collection('orders').doc(orderId);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Delivery Order Details',
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
                  _buildDeliveryStatusUpdate(context, orderRef, orderData['orderStatus']),
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
      future: _fetchProductDetails(selectedProducts, context),
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
          shrinkWrap: true, 
          physics: NeverScrollableScrollPhysics(),
          children: productsWidgets,
        );
      },
    );
  }

  // Fetch product details for selected products
  Future<List<Widget>> _fetchProductDetails(List selectedProducts, BuildContext context) async {
    List<Widget> productWidgets = [];

    for (var product in selectedProducts) {
      String productId = product['productId'];
      DocumentSnapshot productSnapshot = await FirebaseFirestore.instance.collection('products').doc(productId).get();

      if (productSnapshot.exists) {
        Map<String, dynamic> productData = productSnapshot.data() as Map<String, dynamic>;
        String productName = productData['productName'] ?? 'Unknown Product';

        String productImage = productData['productImages'] != null && productData['productImages'].isNotEmpty
            ? productData['productImages'][0]
            : '';
        double productPrice = product['price'] ?? productData['price'] ?? 0.0;
        double discountPrice = productData['discountPrice'] ?? productPrice;

        productWidgets.add(
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetail(productId: productId),
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

  // Widget to update delivery status
  Widget _buildDeliveryStatusUpdate(BuildContext context, DocumentReference orderRef, String currentStatus) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Update Delivery Status:',
          style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        DropdownButton<String>(
          value: currentStatus,
          items: ['Pending', 'Shipped', 'Out for Delivery', 'Delivered'].map((String status) {
            return DropdownMenuItem<String>(
              value: status,
              child: Text(status),
            );
          }).toList(),
          onChanged: (newStatus) async {
            if (newStatus != null) {
              await orderRef.update({'orderStatus': newStatus});
              // Use context here to show a SnackBar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Order status updated to $newStatus')),
              );
            }
          },
        ),
      ],
    );
  }
}

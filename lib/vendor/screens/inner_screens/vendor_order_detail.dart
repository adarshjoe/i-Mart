import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class VendorOrderDetailScreen extends StatefulWidget {
  final String orderId;
  final String currentVendorId; // Vendor ID for the logged-in vendor

  const VendorOrderDetailScreen({
    Key? key,
    required this.orderId,
    required this.currentVendorId,
  }) : super(key: key);

  @override
  _VendorOrderDetailScreenState createState() => _VendorOrderDetailScreenState();
}

class _VendorOrderDetailScreenState extends State<VendorOrderDetailScreen> {
  Map<String, dynamic>? orderData;
  String? selectedStatus;
  TextEditingController customStatusController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchOrderData();
  }

  Future<void> _fetchOrderData() async {
    try {
      DocumentSnapshot orderSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .get();

      if (orderSnapshot.exists) {
        setState(() {
          orderData = orderSnapshot.data() as Map<String, dynamic>?;
          selectedStatus = orderData?['orderStatus'];
        });
      } else {
        print('Order not found for ID: ${widget.orderId}');
      }
    } catch (e) {
      print('Error fetching order data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (orderData == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Order Details', style: GoogleFonts.lato(color: Colors.white)),
          backgroundColor: Colors.blue,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    List<String> orderStatusOptions = [
      'Pending',
      'Delivered',
      'Cancelled',
      'Processing'
    ];

    if (!orderStatusOptions.contains(selectedStatus)) {
      selectedStatus = orderStatusOptions[0];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details', style: GoogleFonts.lato(color: Colors.white)),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Amount: ₹${orderData!['totalAmount']}', style: GoogleFonts.lato(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text('Order Status:', style: GoogleFonts.lato(color: Colors.orange)),
              DropdownButton<String>(
                value: selectedStatus,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedStatus = newValue;
                  });
                },
                items: orderStatusOptions.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: GoogleFonts.lato()),
                  );
                }).toList(),
              ),
              SizedBox(height: 10),
              Text('Or Create Custom Status:', style: GoogleFonts.lato(color: Colors.orange)),
              TextField(
                controller: customStatusController,
                decoration: InputDecoration(hintText: 'Enter custom status'),
                onSubmitted: (value) {
                  setState(() {
                    selectedStatus = value;
                  });
                },
              ),
              SizedBox(height: 16),
              Text('Ordered At: ${orderData!['orderedAt'].toDate().toString()}', style: GoogleFonts.lato(color: Colors.black54)),
              Text('Payment Method: ${orderData!['paymentMethod']}', style: GoogleFonts.lato(color: Colors.black54)),
              Text('Phone Number: ${orderData!['phoneNumber']}', style: GoogleFonts.lato(color: Colors.black54)),
              Text('Address: ${orderData!['address']}', style: GoogleFonts.lato(color: Colors.black54)),
              Text('City: ${orderData!['city']}', style: GoogleFonts.lato(color: Colors.black54)),
              Text('Pincode: ${orderData!['pincode']}', style: GoogleFonts.lato(color: Colors.black54)),
              Text('User Name: ${orderData!['username']}', style: GoogleFonts.lato(color: Colors.black54)),
              Text('User Email: ${orderData!['email']}', style: GoogleFonts.lato(color: Colors.black54)),
              SizedBox(height: 20),
              Text('Products:', style: GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.bold)),
              FutureBuilder<List<Widget>>(
                future: _buildProductList(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error fetching products: ${snapshot.error}'));
                  } else {
                    return Column(children: snapshot.data ?? []);
                  }
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateOrderStatus,
                child: Text('Save Changes', style: GoogleFonts.lato()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<Widget>> _buildProductList() async {
    List<Widget> productWidgets = [];
    List selectedProducts = orderData?['selectedProducts'] ?? [];

    if (selectedProducts.isEmpty) {
      productWidgets.add(Text('No products found for this order.'));
      return productWidgets;
    }

    for (var product in selectedProducts) {
      String productId = product['productId'];
      Map<String, dynamic>? productDetails = await fetchProductDetails(productId);

      if (productDetails != null) {
        String vendorId = productDetails['vendorId'];
        bool isCurrentVendorProduct = vendorId == widget.currentVendorId;
        bool isReadyForDelivery = product['isReadyForDelivery'] ?? false;

        productWidgets.add(
          ListTile(
            leading: Image.network(
              productDetails['productImages'][0],
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
            title: Text(productDetails['productName'], style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Quantity: ${product['quantity']}', style: GoogleFonts.lato(color: Colors.black54)),
                Text('Ready for Delivery: ${isReadyForDelivery ? "Yes" : "No"}',
                    style: GoogleFonts.lato(color: isReadyForDelivery ? Colors.green : Colors.red)),
                if (isCurrentVendorProduct)
                  ElevatedButton(
                    onPressed: () => _markAsReady(productId),
                    child: Text(isReadyForDelivery ? 'Ready' : 'Mark as Ready'),
                  ),
              ],
            ),
          ),
        );
      } else {
        productWidgets.add(Text('Product not found for ID: $productId'));
      }
    }

    return productWidgets;
  }

  Future<Map<String, dynamic>?> fetchProductDetails(String productId) async {
    try {
      final productSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get();

      if (productSnapshot.exists) {
        return productSnapshot.data();
      } else {
        print('Product not found for ID: $productId');
        return null;
      }
    } catch (e) {
      print('Error fetching product details for ID $productId: $e');
      return null;
    }
  }

  Future<void> _markAsReady(String productId) async {
    try {
      List selectedProducts = orderData?['selectedProducts'] ?? [];
      for (int i = 0; i < selectedProducts.length; i++) {
        if (selectedProducts[i]['productId'] == productId) {
          selectedProducts[i]['isReadyForDelivery'] = true;
        }
      }

      await FirebaseFirestore.instance.collection('orders').doc(widget.orderId).update({
        'selectedProducts': selectedProducts,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Product marked as ready.')));
      _fetchOrderData(); // Refresh order data
    } catch (e) {
      print('Error marking product as ready: $e');
    }
  }

  Future<void> _updateOrderStatus() async {
    try {
      bool allProductsReady = orderData?['selectedProducts'].every((product) => product['isReadyForDelivery'] == true);

      if (!allProductsReady) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('All products must be marked as ready before updating the order status.')));
        return;
      }

      await FirebaseFirestore.instance.collection('orders').doc(widget.orderId).update({
        'orderStatus': selectedStatus,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order status updated successfully.')));
    } catch (e) {
      print('Error updating order status: $e');
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DeliveryBoyOrderScreen extends StatefulWidget {
  const DeliveryBoyOrderScreen({Key? key}) : super(key: key);

  @override
  _DeliveryBoyOrderScreenState createState() => _DeliveryBoyOrderScreenState();
}

class _DeliveryBoyOrderScreenState extends State<DeliveryBoyOrderScreen> {
  @override
  Widget build(BuildContext context) {
    final deliveryBoyId = FirebaseAuth.instance.currentUser?.uid;

    // Check if the delivery boy is logged in
    if (deliveryBoyId == null) {
      return Center(child: Text('Delivery Boy not logged in.'));
    }

    // Stream to fetch all orders
    final Stream<QuerySnapshot> _ordersStream = FirebaseFirestore.instance.collection('orders').snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text('Delivery Orders', style: GoogleFonts.lato(color: Colors.white)),
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

          // Fetch delivery boy's profile information
          return FutureBuilder<DocumentSnapshot>(
            future: _fetchDeliveryBoyProfile(deliveryBoyId),
            builder: (context, profileSnapshot) {
              if (profileSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (profileSnapshot.hasError) {
                return Center(child: Text('Error fetching profile: ${profileSnapshot.error}'));
              }

              if (!profileSnapshot.hasData || !profileSnapshot.data!.exists) {
                return Center(
                  child: Text(
                    'Profile not found for this delivery boy.',
                    style: GoogleFonts.lato(fontSize: 18, color: Colors.black54),
                  ),
                );
              }

              final deliveryBoyData = profileSnapshot.data!;
              String? deliveryBoyPincode = deliveryBoyData['pinCode'];

              if (deliveryBoyPincode == null) {
                return Center(
                  child: Text(
                    'No pincode found for this delivery boy.',
                    style: GoogleFonts.lato(fontSize: 18, color: Colors.black54),
                  ),
                );
              }

              // Filter orders based on the delivery boy's pincode
              final List<QueryDocumentSnapshot> deliveryBoyOrders = snapshot.data!.docs.where((order) {
                return order['pincode'] == deliveryBoyPincode;
              }).toList();

              if (deliveryBoyOrders.isEmpty) {
                return Center(
                  child: Text(
                    'No orders found for this pincode.',
                    style: GoogleFonts.lato(fontSize: 18, color: Colors.black54),
                  ),
                );
              }

              // Build the order cards for each order document
              return ListView.builder(
                itemCount: deliveryBoyOrders.length,
                itemBuilder: (context, index) {
                  final orderData = deliveryBoyOrders[index];
                  return _buildOrderCard(context, orderData, deliveryBoyData);
                },
              );
            },
          );
        },
      ),
    );
  }

  // Function to fetch the profile of the delivery boy
  Future<DocumentSnapshot> _fetchDeliveryBoyProfile(String deliveryBoyId) async {
    return await FirebaseFirestore.instance
        .collection('delivery_boys')
        .doc(deliveryBoyId)
        .get();
  }

  // Function to build an order card UI
  Widget _buildOrderCard(BuildContext context, QueryDocumentSnapshot orderData, DocumentSnapshot deliveryBoyData) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(deliveryBoyData['profileImageUrl']),
            ),
            title: Text('Order for: ${deliveryBoyData['fullName']}', style: GoogleFonts.lato()),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Amount: ₹${orderData['totalAmount']}', style: GoogleFonts.lato(color: Colors.green)),
                Text('Order Status: ${orderData['orderStatus']}', style: GoogleFonts.lato(color: Colors.orange)),
                Text('Ordered At: ${orderData['orderedAt'].toDate().toString()}', style: GoogleFonts.lato(color: Colors.black54)),
                Text('Payment Method: ${orderData['paymentMethod']}', style: GoogleFonts.lato(color: Colors.black54)),
                Text('Phone Number: ${orderData['phoneNumber']}', style: GoogleFonts.lato(color: Colors.black54)),
                Text('Address: ${orderData['address']}', style: GoogleFonts.lato(color: Colors.black54)),
                Text('City: ${orderData['city']}', style: GoogleFonts.lato(color: Colors.black54)),
                Text('Pincode: ${orderData['pincode']}', style: GoogleFonts.lato(color: Colors.black54)),
              ],
            ),
            trailing: Icon(Icons.arrow_forward, color: Colors.blue),
          ),
        ],
      ),
    );
  }
}

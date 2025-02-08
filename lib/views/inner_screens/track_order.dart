


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TrackOrdersScreen extends StatefulWidget {
  final String userId;

  TrackOrdersScreen({required this.userId});

  @override
  _TrackOrdersScreenState createState() => _TrackOrdersScreenState();
}

class _TrackOrdersScreenState extends State<TrackOrdersScreen> {
  List<OrderItem> orders = [];

  @override
  void initState() {
    super.initState();
    loadOrders();
  }

  // Load orders from Firestore
  Future<void> loadOrders() async {
    QuerySnapshot orderSnapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: widget.userId)
        .get();

    setState(() {
      orders = orderSnapshot.docs.map((doc) {
        return OrderItem(
          orderId: doc['orderId'],
          productName: doc['productName'],
          orderedAt: (doc['orderedAt'] as Timestamp).toDate(),
        );
      }).toList();
    });
  }

  // Method to delete an order
  Future<void> deleteOrder(String orderId) async {
    await FirebaseFirestore.instance.collection('orders').doc(orderId).delete();
    loadOrders(); // Refresh the order list
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Order cancelled successfully."),
    ));
  }

  // Check if the order is cancellable (within 2 hours)
  bool isCancellable(DateTime orderedAt) {
    final now = DateTime.now();
    final difference = now.difference(orderedAt);
    return difference.inHours < 2; // Check if order is within 2 hours
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Track Your Orders")),
      body: orders.isEmpty
          ? Center(child: Text("No orders found."))
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return ListTile(
                  title: Text(order.productName),
                  subtitle: Text("Ordered at: ${order.orderedAt}"),
                  trailing: isCancellable(order.orderedAt)
                      ? IconButton(
                          icon: Icon(Icons.cancel),
                          onPressed: () {
                            deleteOrder(order.orderId);
                          },
                        )
                      : null,
                );
              },
            ),
    );
  }
}

// OrderItem class to represent an order
class OrderItem {
  final String orderId;
  final String productName;
  final DateTime orderedAt;

  OrderItem({required this.orderId, required this.productName, required this.orderedAt});
}

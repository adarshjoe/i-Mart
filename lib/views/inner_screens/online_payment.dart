import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import for currency formatting
import 'package:i_mart/views/buyers/nav_screens/cart_screen.dart';

class OnlinePaymentScreen extends StatefulWidget {
  final double totalAmount;
  final String username;
  final String phoneNumber;
  final String alternativeNumber;
  final String city;
  final String pincode;
  final String landmark;
  final String address;
  final List<Map<String, dynamic>> selectedProducts; // Add this line
  final String userId; // Add this line

  const OnlinePaymentScreen({
    Key? key,
    required this.totalAmount,
    required this.username,
    required this.phoneNumber,
    required this.alternativeNumber,
    required this.city,
    required this.pincode,
    required this.landmark,
    required this.address,
    required this.selectedProducts, // Include in constructor
    required this.userId, // Include in constructor
  }) : super(key: key);

  @override
  _OnlinePaymentScreenState createState() => _OnlinePaymentScreenState();
}

class _OnlinePaymentScreenState extends State<OnlinePaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  String cardNumber = '';
  String cardHolderName = '';
  String expiryDate = '';
  String cvv = '';
  bool isProcessing = false; // To manage button state

  final String dummyCardNumber = '1234567812345678';
  final String dummyCardHolderName = 'John Doe';
  final String dummyExpiryDate = '12/25';
  final String dummyCVV = '123';

  void submitPayment() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isProcessing = true; // Set processing state to true
      });

      if (cardNumber == dummyCardNumber &&
          cardHolderName == dummyCardHolderName &&
          expiryDate == dummyExpiryDate &&
          cvv == dummyCVV) {
        try {
          await FirebaseFirestore.instance.collection('orders').add({
            'username': widget.username,
            'phoneNumber': widget.phoneNumber,
            'alternativeNumber': widget.alternativeNumber,
            'paymentMethod': 'Online Payment',
            'totalAmount': widget.totalAmount,
            'orderStatus': 'Pending',
            'orderedAt': FieldValue.serverTimestamp(),
            'city': widget.city,
            'pincode': widget.pincode,
            'landmark': widget.landmark,
            'address': widget.address,
            'userId': widget.userId, // Store the user ID
            'selectedProducts': widget.selectedProducts, // Store selected products
          });

          Get.snackbar('Payment Successful', 'Your payment has been processed!',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
              duration: const Duration(seconds: 3));

          Get.off(() => CartScreenProduct()); // Navigate to CartScreen
        } catch (error) {
          Get.snackbar('Error', 'Failed to complete payment: $error',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white);
        } finally {
          setState(() {
            isProcessing = false; // Reset processing state
          });
        }
      } else {
        setState(() {
          isProcessing = false; // Reset processing state
        });
        Get.snackbar('Payment Failed', 'Invalid card details provided!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 3));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Online Payment'),
        backgroundColor: const Color(0xFF102DE1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display the total amount formatted in INR
              Text(
                'Total Amount: ₹${NumberFormat('#,##0.00', 'en_IN').format(widget.totalAmount)}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Card Number'),
                keyboardType: TextInputType.number,
                onChanged: (value) => cardNumber = value,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your card number';
                  } else if (value.length != 16) {
                    return 'Card number must be 16 digits';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Card Holder Name'),
                onChanged: (value) => cardHolderName = value,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the cardholder name';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Expiry Date (MM/YY)'),
                onChanged: (value) => expiryDate = value,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter expiry date';
                  } else if (!RegExp(r'^(0[1-9]|1[0-2])\/[0-9]{2}$').hasMatch(value)) {
                    return 'Invalid expiry date format';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'CVV'),
                keyboardType: TextInputType.number,
                onChanged: (value) => cvv = value,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter CVV';
                  } else if (value.length != 3) {
                    return 'CVV must be 3 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: isProcessing ? null : submitPayment, // Disable button if processing
                  child: isProcessing 
                      ? const CircularProgressIndicator() // Show loading indicator
                      : const Text('Submit Payment'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    backgroundColor: const Color(0xFF102DE1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

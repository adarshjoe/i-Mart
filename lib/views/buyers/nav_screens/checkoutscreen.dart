import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_mart/views/buyers/nav_screens/cart_screen.dart';
import 'package:i_mart/views/inner_screens/online_payment.dart';

class Checkoutscreen extends StatefulWidget {
  final double totalAmount;
  final String username; 
  final List<Map<String, dynamic>> selectedProducts; // Ensure this is a list of maps
  final String userId; 

  const Checkoutscreen({
    Key? key,
    required this.totalAmount,
    required this.username,
    required this.selectedProducts,
    required this.userId,
  }) : super(key: key);

  @override
  _CheckoutscreenState createState() => _CheckoutscreenState();
}

class _CheckoutscreenState extends State<Checkoutscreen> {
  final _formKey = GlobalKey<FormState>();
  String phoneNumber = '';
  String alternativeNumber = '';
  String paymentMethod = 'Cash on Delivery';
  String city = '';
  String pincode = '';
  String landmark = '';
  String address = '';

  void submitOrder() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Create order document in Firestore
        await FirebaseFirestore.instance.collection('orders').add({
          'username': widget.username,
          'phoneNumber': phoneNumber,
          'alternativeNumber': alternativeNumber,
          'paymentMethod': paymentMethod,
          'totalAmount': widget.totalAmount,
          'orderStatus': 'Pending',
          'orderedAt': FieldValue.serverTimestamp(),
          'city': city,
          'pincode': pincode,
          'landmark': landmark,
          'address': address,
          'selectedProducts': widget.selectedProducts, // Store selected product details
          'userId': widget.userId, // Store user ID
        });

        // Show success message
        Get.snackbar(
          'Order Placed',
          'Your item has been successfully ordered!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        _formKey.currentState!.reset(); // Clear form
        Get.off(() => CartScreenProduct()); // Navigate to CartScreen
      } catch (error) {
        Get.snackbar(
          'Error',
          'Failed to place order: $error',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  void proceedToPayment() {
    // Navigate to Online Payment screen with order details
    Get.to(() => OnlinePaymentScreen(
      totalAmount: widget.totalAmount,
      username: widget.username,
      phoneNumber: phoneNumber,
      alternativeNumber: alternativeNumber,
      city: city,
      pincode: pincode,
      landmark: landmark,
      address: address,
      selectedProducts: widget.selectedProducts, // Pass selected products to payment screen
      userId: widget.userId, // Pass user ID to payment screen
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Checkout',
          style: GoogleFonts.lato(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF102DE1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter Delivery Details',
                  style: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                _buildTextField('Phone Number *', TextInputType.phone, (value) {
                  if (value!.isEmpty) return 'Please enter your phone number';
                  if (value.length != 10) return 'Phone number must be 10 digits';
                  return null;
                }, (value) => phoneNumber = value),
                _buildTextField('Alternative Number', TextInputType.phone, null, (value) {
                  alternativeNumber = value;
                }),
                _buildTextField('City *', TextInputType.text, (value) {
                  if (value!.isEmpty) return 'Please enter your city';
                  return null;
                }, (value) => city = value),
                _buildTextField('Pincode *', TextInputType.number, (value) {
                  if (value!.isEmpty) return 'Please enter your pincode';
                  if (value.length != 6) return 'Pincode must be 6 digits';
                  return null;
                }, (value) => pincode = value),
                _buildTextField('Landmark', TextInputType.text, null, (value) {
                  landmark = value;
                }),
                _buildTextField('Address *', TextInputType.text, (value) {
                  if (value!.isEmpty) return 'Please enter your address';
                  return null;
                }, (value) => address = value),
                const SizedBox(height: 20),
                Text(
                  'Select Payment Method',
                  style: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                RadioListTile(
                  title: const Text('Cash on Delivery'),
                  value: 'Cash on Delivery',
                  groupValue: paymentMethod,
                  onChanged: (value) {
                    setState(() {
                      paymentMethod = value.toString();
                    });
                  },
                ),
                RadioListTile(
                  title: const Text('Online Payment'),
                  value: 'Online Payment',
                  groupValue: paymentMethod,
                  onChanged: (value) {
                    setState(() {
                      paymentMethod = value.toString();
                    });
                  },
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: paymentMethod == 'Cash on Delivery' ? submitOrder : proceedToPayment,
                    child: const Text('Place Order'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15), backgroundColor: const Color(0xFF102DE1),
                      textStyle: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextInputType inputType, String? Function(String?)? validator, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        keyboardType: inputType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: validator,
        onChanged: onChanged,
      ),
    );
  }
}

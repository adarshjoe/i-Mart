import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:i_mart/delivery_staff/Screens/homeScreen.dart';


class DeliveryStaffLoginPage extends StatefulWidget {
  @override
  _DeliveryStaffLoginPageState createState() => _DeliveryStaffLoginPageState();
}

class _DeliveryStaffLoginPageState extends State<DeliveryStaffLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check if email exists in the 'delivery_boys' collection
      QuerySnapshot snapshot = await _firestore
          .collection('delivery_boys')
          .where('email', isEqualTo: _emailController.text)
          .where('password', isEqualTo: _passwordController.text)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Perform Firebase authentication
        await _auth.signInWithEmailAndPassword(
            email: _emailController.text, password: _passwordController.text);

        // Navigate to the home page after login
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => DeliveryMainScreen()));
      } else {
        _showErrorMessage('Invalid email or password');
      }
    } catch (e) {
      _showErrorMessage('An error occurred, please try again');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showErrorMessage(String message) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Error'),
              content: Text(message),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Delivery Icon (Can be replaced with an app-specific logo)
              Icon(
                Icons.delivery_dining,
                size: 100,
                color: Colors.blueAccent,
              ),
              SizedBox(height: 40),
              // Email Input Field
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Username (Email)',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Password Input Field
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Sign In Button
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _login,
                      child: Text('Sign In'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
              SizedBox(height: 20),
              // Forgot Password Button
              TextButton(
                onPressed: () {
                  // Implement forget password logic here
                },
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(color: Colors.blueAccent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

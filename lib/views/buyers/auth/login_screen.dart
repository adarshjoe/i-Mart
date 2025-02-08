import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_mart/controllers/auth_controller.dart';
import 'package:i_mart/delivery_staff/auth/delivery_login.dart';
import 'package:i_mart/vendor/authentication/vendor_login_screen.dart';
import 'package:i_mart/vendor/authentication/vendor_register_screen.dart';
import 'package:i_mart/views/buyers/auth/register_screen.dart';
import 'package:i_mart/views/buyers/auth/reset_paasword_screen.dart';
import 'package:i_mart/views/buyers/main_screen.dart'; // Ensure this is your main buyer screen

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthController _authController = AuthController();

  late String email;
  late String password;
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> loginUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      Map<String, dynamic> res = await _authController.loginUser(email, password);

      setState(() {
        _isLoading = false;
      });

      if (res['status'] == 'success') {
        String userRole = res['role'];
        if (userRole == 'buyer') {
          Get.offAll(() => mainscreen()); // Adjust this to your actual main screen
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Logged in as a buyer')),
          );
        } else if (userRole == 'vendor') {
          Get.offAll(() => VendorRegisterScreen()); // Redirect to vendor dashboard or appropriate screen
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Logged in as a vendor')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Invalid user role. Please contact support.'),
            backgroundColor: Colors.blue,
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Login failed. ${res['status']}'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.98),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 40),
                Text(
                  "Welcome Back!",
                  style: GoogleFonts.poppins(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Login to your account",
                  style: GoogleFonts.poppins(
                    color: Colors.black54,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 30),
                // Email TextFormField
                TextFormField(
                  onChanged: (value) {
                    email = value;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your email';
                    } else if (!GetUtils.isEmail(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email, color: Colors.blueAccent),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Password TextFormField
                TextFormField(
                  obscureText: _obscurePassword,
                  onChanged: (value) {
                    password = value;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your password';
                    } else if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock, color: Colors.blueAccent),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        color: Colors.blueAccent,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 15),
                // "Forgot Password?" link
                GestureDetector(
                  onTap: () {
                    Get.to(ResetPasswordScreen());
                  },
                  child: Text(
                    "Forgot Password?",
                    style: GoogleFonts.poppins(
                      color: Colors.blueAccent,
                      fontSize: 14,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Sign In Button
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      loginUser();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Sign In',
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
                SizedBox(height: 15),
                // Sign Up Link
                GestureDetector(
                  onTap: () {
                    Get.to(RegisterScreen());
                  },
                  child: Text(
                    "Don't have an account? Sign Up",
                    style: GoogleFonts.poppins(
                      color: Colors.blueAccent,
                      fontSize: 14,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                // Vendor account creation link
                GestureDetector(
                  onTap: () {
                    Get.to(VendorLoginScreen());
                  },
                  child: Text(
                    "Vendor Log In",
                    style: GoogleFonts.poppins(
                      color: Colors.blueAccent,
                      fontSize: 14,
                    ),
                  ),
                ),


                GestureDetector(
                  onTap: () {
                    Get.to(DeliveryStaffLoginPage());
                  },
                  child: Text(
                    "Delivery",
                    style: GoogleFonts.poppins(
                      color: Colors.blueAccent,
                      fontSize: 14,
                    ),
                  ),
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

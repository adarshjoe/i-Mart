import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_mart/vendor/authentication/vendor_register_screen.dart';
import 'package:i_mart/vendor/controllers/vendor_controller.dart';
import 'package:i_mart/vendor/screens/vendor_main_screen.dart';
import 'package:i_mart/views/buyers/nav_screens/widgets/button_widget.dart';
import 'package:i_mart/views/buyers/nav_screens/widgets/custom_text_field.dart';

class VendorLoginScreen extends StatefulWidget {
  VendorLoginScreen({super.key});

  @override
  State<VendorLoginScreen> createState() => _VendorLoginScreenState();
}

class _VendorLoginScreenState extends State<VendorLoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final VendorController _authController = VendorController();

  late String email;
  late String password;
  bool _isLoading = false;

  loginUser() async {
    String loginStatus = '';

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      Map<String, dynamic> res =
          await _authController.loginVendorUser(email, password);

      setState(() {
        _isLoading = false;
        loginStatus = res['status'];
      });

      if (loginStatus == 'success') {
        String userRole = res['role'];

        if (userRole == 'vendor') {
          Get.offAll(VendorMainScreen());
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Logged in as a vendor')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Invalid user role. Please contact support.'),
            backgroundColor: Colors.blue,
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Login failed. $loginStatus'),
          backgroundColor: Colors.blue,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.95),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Center(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Login Vendor Account",
                      style: GoogleFonts.roboto(
                        color: Color(0xFF0d120E),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'To Explore the world exclusives',
                      style: GoogleFonts.roboto(
                        color: Color(0xFF0d120E),
                        fontSize: 14,
                        letterSpacing: 0.2,
                      ),
                    ),
                    Icon(
                      Icons.business_center,
                      size: 200,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Email',
                        style: GoogleFonts.getFont(
                          'Nunito Sans',
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    CustomTextField(
                      onChanged: (value) {
                        email = value;
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter your email';
                        }
                        return null;
                      },
                      label: 'Enter your email',
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Icon(
                          Icons.email,
                          size: 20,
                        ),
                      ),
                      hintText: 'enter email',
                    ),
                    SizedBox(height: 15),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Password',
                        style: GoogleFonts.getFont(
                          'Nunito Sans',
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    CustomTextField(
                      isPassword: true,
                      onChanged: (value) {
                        password = value;
                      },
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter your password';
                        }
                        return null;
                      },
                      label: 'Enter your password',
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Icon(
                          Icons.lock,
                          size: 20,
                        ),
                      ),
                      hintText: 'enter password',
                    ),
                    SizedBox(height: 15),
                    ButtonWidgets(
                      isLoading: _isLoading,
                      buttonChange: () {
                        if (_formKey.currentState!.validate()) {
                          loginUser();
                        }
                      },
                      buttonTitle: 'Sign In',
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Create Vendor account?',
                          style: GoogleFonts.roboto(),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.to(VendorRegisterScreen());
                          },
                          child: Text(
                            'Create account?',
                            style: GoogleFonts.roboto(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

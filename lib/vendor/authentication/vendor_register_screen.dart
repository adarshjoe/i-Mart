import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_mart/vendor/authentication/create_store_screen.dart';
import 'package:i_mart/vendor/controllers/vendor_controller.dart';
import 'package:i_mart/views/buyers/nav_screens/widgets/button_widget.dart';
import 'package:i_mart/views/buyers/nav_screens/widgets/custom_text_field.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class VendorRegisterScreen extends StatefulWidget {
  @override
  State<VendorRegisterScreen> createState() => _VendorRegisterScreenState();
}

class _VendorRegisterScreenState extends State<VendorRegisterScreen> {
  final VendorController _vendorController = VendorController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late String companyName;
  late String companyNumber;
  late String address;
  late String companyId;
  late String email;
  late String password;
  File? _storeImage;
  final picker = ImagePicker();

  Future<void> _pickStoreImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _storeImage = File(pickedFile.path);
      }
    });
  }

  registerUser() async {
    if (_formKey.currentState!.validate() && _storeImage != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        String res = await _vendorController.createNewUser(
            email, companyName, companyNumber, password, address, companyId);

        setState(() {
          _isLoading = false;
        });

        if (res == 'success') {
          // Navigate to the CreateStoreScreen with the store image
          Get.to(CreateStoreScreen(storeImage: _storeImage!));
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Account created! Now, create your store.')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Something went wrong. Please try again later.'),
            ),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please pick a store image.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.95),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 30),
                  Text(
                    'Create Your Business Account',
                    style: GoogleFonts.roboto(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'To Make Your Business Bigger',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 20),
                  Icon(
                    Icons.business_center,
                    size: 100,
                    color: Colors.blue,
                  ),
                  SizedBox(height: 20),
                  _buildTextField('Company Name', Icons.business, 'Enter your company name', (value) {
                    companyName = value;
                  }),
                  SizedBox(height: 10),
                  _buildTextField('Company Number', Icons.phone, 'Enter your company number', (value) {
                    companyNumber = value;
                  }),
                  SizedBox(height: 10),
                  _buildTextField('Address', Icons.location_on, 'Enter your address', (value) {
                    address = value;
                  }),
                  SizedBox(height: 10),
                  _buildTextField('Company ID', Icons.badge, 'Enter your company ID', (value) {
                    companyId = value;
                  }),
                  SizedBox(height: 10),
                  _buildTextField('Email', Icons.email, 'Enter your email', (value) {
                    email = value;
                  }),
                  SizedBox(height: 10),
                  _buildTextField('Password', Icons.lock, 'Enter your password', (value) {
                    password = value;
                  }, isPassword: true),
                  SizedBox(height: 10),

                  // Store Image Picker
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _pickStoreImage,
                        child: Text('Pick Store Image'),
                      ),
                      SizedBox(width: 16),
                      _storeImage != null
                          ? Image.file(_storeImage!, height: 50)
                          : Text('No image selected'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: ButtonWidgets(
          buttonChange: registerUser,
          isLoading: _isLoading,
          buttonTitle: 'Sign up',
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, String hintText, Function(String) onChanged, {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Text(
            label,
            style: GoogleFonts.roboto(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ),
        CustomTextField(
          label: hintText,
          prefixIcon: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Icon(
              icon,
              size: 20,
              color: Colors.grey,
            ),
          ),
          hintText: hintText,
          isPassword: isPassword,
          validator: (value) {
            if (value!.isEmpty) {
              return 'Please enter $label.';
            } else {
              return null;
            }
          },
          onChanged: onChanged,
        ),
      ],
    );
  }
}

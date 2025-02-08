import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_mart/controllers/auth_controller.dart';
import 'package:i_mart/views/buyers/auth/login_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthController _authController = AuthController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String email = '';
  String fullName = '';
  String password = '';
  String pinCode = '';
  String locality = '';
  String city = '';
  String state = 'Kerala'; // Default state
  String phoneNumber = ''; // Added phone number variable
  File? _profileImage;

  // List of states in India
  final List<String> states = [
    'Kerala',
    'Maharashtra',
    'Karnataka',
    'Tamil Nadu',
    'Telangana',
    'Andhra Pradesh',
    'West Bengal',
    'Gujarat',
    'Rajasthan',
    'Uttar Pradesh',
    'Bihar',
    'Punjab',
    'Haryana',
    'Odisha',
    'Madhya Pradesh',
    'Chhattisgarh',
    'Assam',
    'Jharkhand',
    'Himachal Pradesh',
    'Uttarakhand',
    'Delhi',
    'Jammu and Kashmir',
    'Goa',
    'Tripura',
    'Meghalaya',
    'Nagaland',
    'Sikkim',
    'Arunachal Pradesh',
    'Manipur',
    'Mizoram',
    'Lakshadweep',
    'Puducherry',
    'Dadra and Nagar Haveli and Daman and Diu',
  ];

  Future<void> registerUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      String res = await _authController.createNewUser(
        email,
        fullName,
        password,
        pinCode,
        locality,
        city,
        state,
        phoneNumber,
        _profileImage,
      );

      setState(() {
        _isLoading = false;
      });

      if (res == 'success') {
        Get.to(LoginScreen());
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Congratulations, your account has been created.'),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Something went wrong. $res'),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please fill in all fields correctly.'),
      ));
    }
  }

  Future<void> pickProfileImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.95),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start, // Align items to the start
            children: [
              SizedBox(height: 30), // Move everything down
              Text(
                "Create Your Account",
                style: GoogleFonts.roboto(
                  color: Color(0xFF0d120E),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                  fontSize: 23,
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
              SizedBox(height: 20),
              GestureDetector(
                onTap: pickProfileImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : null,
                  child: _profileImage == null
                      ? Icon(Icons.camera_alt, size: 50, color: Colors.grey)
                      : null,
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                onChanged: (value) {
                  email = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter your email';
                  } else if (!GetUtils.isEmail(value)) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Enter your email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 15),
              TextFormField(
                onChanged: (value) {
                  fullName = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter your Full Name';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Enter your Full Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 15),
              TextFormField(
                obscureText: true,
                onChanged: (value) {
                  password = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter your password';
                  } else if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Enter your password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 15),
              TextFormField(
                onChanged: (value) {
                  pinCode = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter your pin code';
                  } else if (value.length != 6) {
                    return 'Pin code must be 6 digits';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Enter your pin code',
                  prefixIcon: Icon(Icons.pin),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 15),
              TextFormField(
                onChanged: (value) {
                  locality = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter your locality';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Enter your locality',
                  prefixIcon: Icon(Icons.location_city),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 15),
              TextFormField(
                onChanged: (value) {
                  city = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter your city';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Enter your city',
                  prefixIcon: Icon(Icons.location_city),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 15),
              // State Dropdown
              DropdownButtonFormField<String>(
                value: state,
                onChanged: (newValue) {
                  setState(() {
                    state = newValue!;
                  });
                },
                items: states.map((String state) {
                  return DropdownMenuItem<String>(
                    value: state,
                    child: Text(state),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Select your state',
                  prefixIcon: Icon(Icons.map),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 15),
              TextFormField(
                onChanged: (value) {
                  phoneNumber = value; // Capture phone number
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter your phone number';
                  } else if (value.length < 10) {
                    return 'Phone number must be at least 10 digits';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Enter your phone number',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    registerUser();
                  }
                },
                child: _isLoading
                    ? CircularProgressIndicator()
                    : Text('Sign Up'),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account?',
                    style: GoogleFonts.roboto(),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.to(LoginScreen());
                    },
                    child: Text(
                      'Login',
                      style: GoogleFonts.roboto(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

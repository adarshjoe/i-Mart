import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:i_mart/vendor/screens/upload_product_screen.dart';
import 'package:i_mart/vendor/screens/vendor_account_screen.dart';
import 'package:i_mart/vendor/screens/vendor_orders_screen.dart';
import 'package:i_mart/vendor/screens/vendor_product_screen.dart';
import 'package:i_mart/views/buyers/nav_screens/home_screen.dart';

class VendorMainScreen extends StatefulWidget {
  const VendorMainScreen({super.key});

  @override
  State<VendorMainScreen> createState() => _VendorMainScreenState();
}

class _VendorMainScreenState extends State<VendorMainScreen> {
  final List<Widget> _pages =  [
    HomeScreen(),
    ProductUploadPage(),
    VendorProductsScreen(), // Add the products screen here
    VendorOrderScreen(),
    VendorAccountScreen(),
  ];

  int pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        onTap: (value) {
          setState(() {
            pageIndex = value;
          });
        },
        currentIndex: pageIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            backgroundColor: Colors.white.withOpacity(0.95),
            icon: Image.asset(
              'assets/icons/home.png',
              width: 25,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.home); // Fallback to icon if image fails
              },
            ),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: 'Upload',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag), // Add a suitable icon for products
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/orders.png',
              width: 40,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.list_alt); // Fallback icon
              },
            ),
            label: 'Orders',
          ),
          const BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.money_dollar),
            label: 'Account',
          ),
        ],
      ),
      body: _pages[pageIndex],
    );
  }
}

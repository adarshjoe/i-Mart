import 'package:flutter/material.dart';
import 'package:i_mart/views/buyers/nav_screens/account_screen.dart';
import 'package:i_mart/views/buyers/nav_screens/cart_screen.dart';
import 'package:i_mart/views/buyers/nav_screens/favourite_screen.dart';
import 'package:i_mart/views/buyers/nav_screens/home_screen.dart';
import 'package:i_mart/views/buyers/nav_screens/store_screen.dart';

class mainscreen extends StatefulWidget {
  const mainscreen({Key? key}) : super(key: key);

  @override
  State<mainscreen> createState() => _mainscreenState();
}

class _mainscreenState extends State<mainscreen> {
  int pageIndex = 0;

  // Define a PageController to manage the PageView
  final PageController _pageController = PageController();

  // List of pages to display
  List<Widget> pages = [
    HomeScreen(),
    FavoriteScreen(),
    StoresScreen(),
    CartScreenProduct(),
    AccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Main body with PageView to display the selected page
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            pageIndex = index; // Update pageIndex when page changes
          });
        },
        physics: const NeverScrollableScrollPhysics(), // Disable swipe gesture to change pages
        children: pages,
      ),
      // Bottom navigation bar
      bottomNavigationBar: BottomNavigationBar(
        onTap: (value) {
          _pageController.jumpToPage(value); // Navigate to the selected page
          setState(() {
            pageIndex = value; // Update pageIndex when a bottom navigation item is tapped
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
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/love.png',
              width: 25,
            ),
            label: 'Favorite',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/mart.png',
              width: 25,
            ),
            label: 'Stores',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/cart.png',
              width: 25,
            ),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/user.png',
              width: 25,
            ),
            label: 'Account',
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose(); // Dispose of the PageController
    super.dispose();
  }
}

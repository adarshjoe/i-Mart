import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for currency formatting

class BottomNavBar extends StatelessWidget {
  final double totalAmount;
  final String username; // Added username parameter
  final VoidCallback onCheckout;

  const BottomNavBar({
    Key? key,
    required this.totalAmount,
    required this.username, // Require username
    required this.onCheckout,
  }) : super(key: key);

  String get formattedTotal => NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(totalAmount);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Padding(
        padding: const EdgeInsets.all(8.0), // Padding for the BottomAppBar
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded( // Wrap with Expanded to make sure it takes the available space
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, $username!', // Personalized greeting
                    style: const TextStyle(
                      fontSize: 14, // Adjust font size for smaller screens
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Total: $formattedTotal',
                    style: const TextStyle(
                      fontSize: 16, // Adjust font size for smaller screens
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8), // Small gap between text and button
            ElevatedButton(
              onPressed: onCheckout,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Button padding
                backgroundColor: const Color(0xFF102DE1), // Button background color
                foregroundColor: Colors.white, // Button text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                ),
              ),
              child: const Text(
                'Checkout',
                style: TextStyle(
                  fontSize: 14, // Adjust font size for smaller screens
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

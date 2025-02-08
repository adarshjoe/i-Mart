

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // Import for currency formatting

class CartItem extends StatelessWidget {
  final String productName;
  final String productPrice;
  final String discountPrice; // New field for discount price
  final int quantity;
  final String productImage;
  final String productBrand;
  final bool isSelected; // New field for selection state
  final VoidCallback onSelect; // New callback for selection toggle
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const CartItem({
    Key? key,
    required this.productName,
    required this.productPrice,
    required this.discountPrice, // Accept discount price
    required this.quantity,
    required this.productImage,
    required this.productBrand,
    required this.isSelected, // Accept selection state
    required this.onSelect, // Accept selection toggle callback
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  }) : super(key: key);

  // Function to convert currency formatted string to double
  double parseCurrency(String currency) {
    // Remove non-numeric characters except for the decimal point
    return double.parse(currency.replaceAll(RegExp(r'[^\d.]'), ''));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: onSelect,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Checkbox for selection state
              Checkbox(
                value: isSelected,
                onChanged: (value) {
                  onSelect(); // Toggle selection when checkbox is tapped
                },
              ),
              Image.network(
                productImage,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      productBrand,
                      style: GoogleFonts.lato(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          NumberFormat.currency(locale: 'en_IN', symbol: '₹').format(parseCurrency(productPrice)), // Format product price
                          style: GoogleFonts.lato(fontSize: 14, color: Colors.green, fontWeight: FontWeight.bold,),
                        ),
                       
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Quantity: $quantity', style: GoogleFonts.lato(fontSize: 14)),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: onIncrement, // Increment quantity
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: onDecrement, // Decrement quantity
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: onRemove, // Remove item from cart
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

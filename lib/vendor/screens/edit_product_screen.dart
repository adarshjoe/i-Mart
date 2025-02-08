

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class EditProductScreen extends StatefulWidget {
  final String productId;
  final Map<String, dynamic> productData;

  const EditProductScreen({required this.productId, required this.productData});

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late TextEditingController _productNameController;
  late TextEditingController _priceController;
  late TextEditingController _discountPriceController;
  late TextEditingController _descriptionController;
  late TextEditingController _brandController;
  late TextEditingController _sizeController;
  late TextEditingController _yearController;
  late TextEditingController _quantityController;
  late TextEditingController _warrantyController;

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with existing product data
    _productNameController = TextEditingController(text: widget.productData['productName']);
    _priceController = TextEditingController(text: widget.productData['price'].toString());
    _discountPriceController = TextEditingController(text: widget.productData['discountPrice'].toString());
    _descriptionController = TextEditingController(text: widget.productData['description']);
    _brandController = TextEditingController(text: widget.productData['brand']);
    _sizeController = TextEditingController(text: widget.productData['size']);
    _yearController = TextEditingController(text: widget.productData['yearOfManufacture']);
    _quantityController = TextEditingController(text: widget.productData['quantity'].toString());
    _warrantyController = TextEditingController(text: widget.productData['warranty']);
  }

  Future<void> _updateProduct() async {
    await _firestore.collection('products').doc(widget.productId).update({
      'productName': _productNameController.text,
      'price': double.tryParse(_priceController.text) ?? 0.0,
      'discountPrice': double.tryParse(_discountPriceController.text) ?? 0.0,
      'description': _descriptionController.text,
      'brand': _brandController.text,
      'size': _sizeController.text.isNotEmpty ? _sizeController.text : null,
      'yearOfManufacture': _yearController.text.isNotEmpty ? _yearController.text : null,
      'quantity': int.tryParse(_quantityController.text) ?? 0,
      'warranty': _warrantyController.text.isNotEmpty ? _warrantyController.text : null,
      // Assuming 'productImages' needs handling separately
      // 'productImages': imagesUrl, // Uncomment if you handle images
    });

    // Navigate back after update
    Navigator.pop(context);
  }

  @override
  void dispose() {
    // Dispose controllers when the widget is removed from the tree
    _productNameController.dispose();
    _priceController.dispose();
    _discountPriceController.dispose();
    _descriptionController.dispose();
    _brandController.dispose();
    _sizeController.dispose();
    _yearController.dispose();
    _quantityController.dispose();
    _warrantyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _updateProduct,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _productNameController,
              decoration: InputDecoration(labelText: 'Product Name'),
            ),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _discountPriceController,
              decoration: InputDecoration(labelText: 'Discount Price'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            TextField(
              controller: _brandController,
              decoration: InputDecoration(labelText: 'Brand'),
            ),
            TextField(
              controller: _sizeController,
              decoration: InputDecoration(labelText: 'Size (optional)'),
            ),
            TextField(
              controller: _yearController,
              decoration: InputDecoration(labelText: 'Year of Manufacture (optional)'),
            ),
            TextField(
              controller: _quantityController,
              decoration: InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _warrantyController,
              decoration: InputDecoration(labelText: 'Warranty (optional)'),
            ),
          ],
        ),
      ),
    );
  }
}

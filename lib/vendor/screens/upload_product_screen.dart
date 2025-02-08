import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

class ProductUploadPage extends StatefulWidget {
  static const String id = '/productScreen';

  @override
  _ProductUploadPageState createState() => _ProductUploadPageState();
}

class _ProductUploadPageState extends State<ProductUploadPage> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _categoryList = [];
  String? _selectedCategoryId;
  String? _selectedCategoryImageUrl;
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _discountPriceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _warrantyController = TextEditingController();

  List<Uint8List> images = [];
  List<String> imagesUrl = [];
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _getCategories();
  }

  Future<void> _getCategories() async {
    final querySnapshot = await _firestore.collection('Categories').get();
    setState(() {
      _categoryList = querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc.data().containsKey('name') ? doc['name'] : '',
          'imageUrl': doc.data().containsKey('categoryImageUrl') ? doc['categoryImageUrl'] : '',
        };
      }).toList();

      if (_categoryList.isNotEmpty) {
        _selectedCategoryId = _categoryList[0]['id'];
        _selectedCategoryImageUrl = _categoryList[0]['imageUrl'];
      }
    });
  }

  Future<void> _selectImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? selectedImages = await picker.pickMultiImage();

    if (selectedImages != null) {
      for (var image in selectedImages) {
        Uint8List imageData = await image.readAsBytes();
        images.add(imageData);
      }
      setState(() {}); // Update the UI after selecting images
    }
  }

  Future<void> _uploadImages() async {
    for (var image in images) {
      Reference ref = _storage.ref().child('productImages').child(Uuid().v4());
      await ref.putData(image).then((_) async {
        String downloadUrl = await ref.getDownloadURL();
        imagesUrl.add(downloadUrl);
      });
    }
  }

  Future<void> _uploadProduct() async {
  setState(() {
    _isUploading = true;
  });

  await _uploadImages();

  if (imagesUrl.isNotEmpty) {
    final productId = Uuid().v4();
    await _firestore.collection('products').doc(productId).set({
      'productId': productId,
      'categoryId': _selectedCategoryId,
      'productName': _productNameController.text,
      'price': double.tryParse(_priceController.text) ?? 0.0,
      'discountPrice': double.tryParse(_discountPriceController.text) ?? 0.0,
      'description': _descriptionController.text,
      'brand': _brandController.text,
      'size': _sizeController.text.isNotEmpty ? _sizeController.text : null,
      'yearOfManufacture': _yearController.text.isNotEmpty ? _yearController.text : null,
      'quantity': int.tryParse(_quantityController.text) ?? 0,
      'warranty': _warrantyController.text.isNotEmpty ? _warrantyController.text : null,
      'productImages': imagesUrl,
      'vendorId': FirebaseAuth.instance.currentUser!.uid,
    });

    // Clear all input fields
    _productNameController.clear();
    _priceController.clear();
    _discountPriceController.clear();
    _descriptionController.clear();
    _brandController.clear();
    _sizeController.clear();
    _yearController.clear();
    _quantityController.clear();
    _warrantyController.clear();
    imagesUrl.clear();
    images.clear(); // Clear the images list after upload

    // Show confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Product uploaded successfully!')),
    );

    // Delay for 2 seconds, then navigate back to the home or previous screen
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pop(context); // or use Navigator.pushReplacement if you want to redirect to a new screen
    });
  } else {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No images uploaded.')));
  }

  setState(() {
    _isUploading = false;
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload Product')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField(_productNameController, 'Product Name', Icons.production_quantity_limits),
              _buildTextField(_priceController, 'Price', Icons.attach_money, keyboardType: TextInputType.number),
              _buildTextField(_discountPriceController, 'Discount Price', Icons.discount, keyboardType: TextInputType.number),
              _buildMultilineTextField(_descriptionController, 'Description', Icons.description),
              _buildTextField(_brandController, 'Brand', Icons.branding_watermark),
              _buildTextField(_sizeController, 'Size (optional)', Icons.format_size),
              _buildTextField(_yearController, 'Year of Manufacture (optional)', Icons.calendar_today, keyboardType: TextInputType.number),
              _buildTextField(_quantityController, 'Quantity (required)', Icons.format_list_numbered, keyboardType: TextInputType.number),
              _buildTextField(_warrantyController, 'Warranty (optional)', Icons.security),
              _buildCategoryDropdown(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _selectImages,
                child: Text('Select Images'),
              ),
              if (images.isNotEmpty) _buildSelectedImagesPreview(), // Display selected images only when present
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isUploading ? null : _uploadProduct, // Disable the button while uploading
                child: Text(_isUploading ? 'Uploading...' : 'Upload Product'),
              ),
              SizedBox(height: 20),
              Text('Fields marked as optional:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('- Size', style: TextStyle(color: Colors.grey)),
              Text('- Year of Manufacture', style: TextStyle(color: Colors.grey)),
              Text('- Warranty', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildMultilineTextField(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      maxLines: 3, // Allows for multi-line input
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategoryId,
      onChanged: (value) {
        setState(() {
          _selectedCategoryId = value;
          _selectedCategoryImageUrl = _categoryList.firstWhere(
            (category) => category['id'] == value,
            orElse: () => {'imageUrl': ''},
          )['imageUrl'];
        });
      },
      items: _categoryList.map((category) {
        return DropdownMenuItem<String>(
          value: category['id'],
          child: Row(
            children: [
              if (category['imageUrl'] != null && category['imageUrl'].isNotEmpty)
                Image.network(
                  category['imageUrl'],
                  width: 24,
                  height: 24,
                ),
              SizedBox(width: 8),
              Text(category['name']),
            ],
          ),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: 'Select Category',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildSelectedImagesPreview() {
    return GridView.builder(
      shrinkWrap: true,
      itemCount: images.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.memory(images[index], fit: BoxFit.cover),
        );
      },
    );
  }
}

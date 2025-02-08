import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'vendor_login_screen.dart'; // Import your VendorLoginScreen

class CreateStoreScreen extends StatefulWidget {
  final File storeImage;

  CreateStoreScreen({required this.storeImage});

  @override
  _CreateStoreScreenState createState() => _CreateStoreScreenState();
}

class _CreateStoreScreenState extends State<CreateStoreScreen> {
  final _formKey = GlobalKey<FormState>();
  String? selectedCategoryId;
  String? categoryName, categoryDescription, categoryImageUrl;
  File? _categoryImage;
  final picker = ImagePicker();

  // Dropdown value for categories
  List<DocumentSnapshot> categories = [];

  bool isCreatingNewCategory = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  // Fetch categories from Firestore
  Future<void> _fetchCategories() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('Categories').get();
      setState(() {
        categories = snapshot.docs;
      });
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  // Pick an image for category
  Future<void> _pickCategoryImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _categoryImage = File(pickedFile.path);
      }
    });
  }

  // Upload category data to Firebase and navigate back
  Future<void> _submitCategory() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      EasyLoading.show(status: 'Uploading...');

      try {
        String? categoryId;

        // If a new category image is selected, upload it
        if (_categoryImage != null) {
          final ref = FirebaseStorage.instance
              .ref()
              .child('category_images')
              .child('${DateTime.now().toIso8601String()}.jpg');
          await ref.putFile(_categoryImage!);
          categoryImageUrl = await ref.getDownloadURL();
        }

        // If a new category is created, add it to Firestore
        if (isCreatingNewCategory) {
          DocumentReference newCategory = await FirebaseFirestore.instance.collection('Categories').add({
            'name': categoryName,
            'description': categoryDescription,
            'categoryImageUrl': categoryImageUrl,
          });
          categoryId = newCategory.id;
          EasyLoading.showSuccess('New Category Created Successfully!');
        } else {
          // If an existing category is selected
          EasyLoading.showSuccess('Selected Existing Category!');
          categoryId = selectedCategoryId;
        }

        // Navigate back to VendorLoginScreen with success message
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VendorLoginScreen(), // Replace with your VendorLoginScreen widget
          ),
        );
      } catch (error) {
        EasyLoading.showError('Error: $error');
      } finally {
        EasyLoading.dismiss();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Store'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Toggle between creating a new category or selecting an existing one
              SwitchListTile(
                title: Text('Create New Category'),
                value: isCreatingNewCategory,
                onChanged: (value) {
                  setState(() {
                    isCreatingNewCategory = value;
                    selectedCategoryId = null;
                    categoryName = null;
                    categoryDescription = null;
                    categoryImageUrl = null;
                    _categoryImage = null;
                  });
                },
              ),
              SizedBox(height: 16),

              // Show dropdown to select an existing category if not creating a new one
              if (!isCreatingNewCategory)
                DropdownButtonFormField<String>(
                  value: selectedCategoryId,
                  hint: Text('Select Category'),
                  items: categories.map((DocumentSnapshot category) {
                    return DropdownMenuItem<String>(
                      value: category.id,
                      child: Text(category['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCategoryId = value;
                      if (value != null) {
                        var selectedCategory = categories.firstWhere((cat) => cat.id == value);
                        categoryName = selectedCategory['name'];
                        categoryDescription = selectedCategory['description'];
                        categoryImageUrl = selectedCategory['categoryImageUrl'];
                      }
                    });
                  },
                  validator: (value) {
                    if (!isCreatingNewCategory && value == null) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                ),
              SizedBox(height: 16),

              // Display Selected Category Info if not creating a new one
              if (selectedCategoryId != null && !isCreatingNewCategory)
                Column(
                  children: [
                    Text('Category: $categoryName', style: TextStyle(fontSize: 16)),
                    Text('Description: $categoryDescription', style: TextStyle(fontSize: 14)),
                    if (categoryImageUrl != null)
                      Image.network(categoryImageUrl!, height: 100),
                    SizedBox(height: 16),
                  ],
                ),

              // Show fields for creating a new category if the switch is on
              if (isCreatingNewCategory) ...[
                // New Category Name Input
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'New Category Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (isCreatingNewCategory && (value == null || value.isEmpty)) {
                      return 'Please enter a category name';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    if (isCreatingNewCategory) {
                      categoryName = value;
                    }
                  },
                ),
                SizedBox(height: 16),

                // New Category Description Input
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'New Category Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (isCreatingNewCategory && (value == null || value.isEmpty)) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    if (isCreatingNewCategory) {
                      categoryDescription = value;
                    }
                  },
                ),
                SizedBox(height: 16),

                // Pick Category Image
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _pickCategoryImage,
                      child: Text('Pick Category Image'),
                    ),
                    SizedBox(width: 16),
                    _categoryImage != null
                        ? Image.file(_categoryImage!, height: 50)
                        : Text('No image selected'),
                  ],
                ),
                SizedBox(height: 16),
              ],

              // Submit Button
              ElevatedButton(
                onPressed: _submitCategory,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

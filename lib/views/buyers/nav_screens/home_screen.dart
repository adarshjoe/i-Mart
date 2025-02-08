import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:i_mart/views/buyers/nav_screens/category_product_screen.dart';
import 'package:i_mart/views/inner_screens/all_category_product_screen.dart';
import 'package:i_mart/views/inner_screens/all_product_screen';
import 'package:i_mart/views/inner_screens/product_detail.dart';
import 'package:i_mart/views/buyers/nav_screens/widgets/banner_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String searchQuery = "";

  Future<List<Map<String, dynamic>>> _fetchCategories() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('Categories').get();
      return querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'],
          'imageUrl': doc.data().containsKey('categoryImageUrl')
              ? doc['categoryImageUrl']
              : 'https://example.com/default_category_image.jpg',
        };
      }).toList();
    } catch (e) {
      print("Error fetching categories: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _fetchAllProducts() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('products').get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['productName'] ?? 'Unknown Product',
          'price': data['price'] ?? 0,
          'discountPrice': data['discountPrice'] ?? 0,
          'brand': data['brand'] ?? 'Unknown Brand',
          'imageUrl': (data.containsKey('productImages') &&
                  (data['productImages'] as List).isNotEmpty)
              ? data['productImages'][0]
              : 'https://example.com/default_product_image.jpg',
        };
      }).toList();
    } catch (e) {
      print("Error fetching products: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _searchAll(String query) async {
    try {
      final productQuerySnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('productName', isGreaterThanOrEqualTo: query)
          .get();

      final categoryQuerySnapshot = await FirebaseFirestore.instance
          .collection('Categories')
          .where('name', isGreaterThanOrEqualTo: query)
          .get();

      final products = productQuerySnapshot.docs.map((doc) {
        final data = doc.data();
        if (data.isEmpty || data['productName'] == null || data['price'] == 0) {
          return null; // Avoid returning products with no name or price 0
        }
        return {
          'id': doc.id,
          'name': data['productName'],
          'price': data['price'],
          'discountPrice': data['discountPrice'],
          'brand': data['brand'],
          'imageUrl': (data.containsKey('productImages') &&
                  (data['productImages'] as List).isNotEmpty)
              ? data['productImages'][0]
              : 'https://example.com/default_product_image.jpg',
        };
      }).whereType<Map<String, dynamic>>().toList();

      final categories = categoryQuerySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'],
          'imageUrl': doc.data().containsKey('categoryImageUrl')
              ? doc['categoryImageUrl']
              : 'https://example.com/default_category_image.jpg',
        };
      }).toList();

      return [...products, ...categories];
    } catch (e) {
      print("Error searching products: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  blurRadius: 5,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search Products or Categories...',
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search, color: Colors.blueAccent),
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              ),
              onChanged: (query) {
                setState(() {
                  searchQuery = query;
                });
              },
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(), // New header section
            BannerArea(),
            if (searchQuery.isNotEmpty)
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _searchAll(searchQuery),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error searching products: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No products or categories found'));
                  }
                  final searchResults = snapshot.data!;
                  return _buildProductsSection(searchResults);
                },
              )
            else ...[
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchCategories(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error fetching categories: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No categories available'));
                  }
                  final categories = snapshot.data!;
                  return _buildCategoriesSection(context, categories);
                },
              ),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchAllProducts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error fetching products: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No products available'));
                  }
                  final products = snapshot.data!;
                  return _buildProductsSection(products);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.1),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to iMart',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Your one-stop shop for all your needs. Explore our wide range of products and categories!',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(BuildContext context, List<Map<String, dynamic>> categories) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('Categories',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
        ),
        GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1,
          ),
          itemCount: categories.length < 12 ? categories.length : 12,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoryProductsScreen(categoryId: categories[index]['id']),
                  ),
                );
              },
              child: Card(
                elevation: 5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(categories[index]['imageUrl'], fit: BoxFit.cover, height: 50),
                    SizedBox(height: 5),
                    Text(categories[index]['name'], textAlign: TextAlign.center),
                  ],
                ),
              ),
            );
          },
        ),
        Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AllCategoriesScreen()));
            },
            child: Text('View All Categories'),
          ),
        ),
      ],
    );
  }

  Widget _buildProductsSection(List<Map<String, dynamic>> products) {
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(
          'Products',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent),
        ),
      ),
      GridView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.5, // Adjust this ratio to fit your needs
        ),
        itemCount: products.length < 8 ? products.length : 8,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetail(productId: products[index]['id']),
                ),
              );
            },
            child: Card(
              elevation: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Increase the height of the image
                  Image.network(
                    products[index]['imageUrl'],
                    fit: BoxFit.cover,
                    height: 250, // Increased height for a larger image
                    width: double.infinity, // Ensure it takes full width
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      products[index]['name'],
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 2, // Limit the number of lines
                      overflow: TextOverflow.ellipsis, // Add ellipsis if text overflows
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        Text(
                          '₹${products[index]['discountPrice']}',
                          style: TextStyle(fontSize: 16, color: Colors.green),
                        ),
                        SizedBox(width: 10),
                        Text(
                          '₹${products[index]['price']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ProductListScreen()));
          },
          child: Text('View All Products'),
        ),
      ),
    ],
  );
}


}

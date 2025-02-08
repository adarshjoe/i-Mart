import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:i_mart/views/buyers/nav_screens/category_product_screen.dart';

class AllCategoriesScreen extends StatefulWidget {
  const AllCategoriesScreen({super.key});

  @override
  _AllCategoriesScreenState createState() => _AllCategoriesScreenState();
}

class _AllCategoriesScreenState extends State<AllCategoriesScreen> {
  // Function to fetch all categories from Firestore
  Future<List<Map<String, dynamic>>> _fetchAllCategories() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('Categories').get();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Categories'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchAllCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Error fetching categories: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No categories available'));
          }
          final categories = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // Display categories in a grid of 3 columns
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.8,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoryProductsScreen(
                            categoryId: categories[index]['id']),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            categories[index]['imageUrl'],
                            width: 80,
                            height: 80,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.network(
                                  'https://example.com/default_category_image.jpg',
                                  width: 80,
                                  height: 80);
                            },
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(categories[index]['name'],
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

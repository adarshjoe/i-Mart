import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_mart/views/inner_screens/product_detail.dart';

class StoreDetailScreen extends StatelessWidget {
  final Map<String, dynamic> storeData;
  final String vendorId;

  const StoreDetailScreen({super.key, required this.storeData, required this.vendorId});

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _productsStream =
        FirebaseFirestore.instance.collection('products').where('vendorId', isEqualTo: vendorId).snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          storeData['companyName'] ?? 'Store Details',
          style: GoogleFonts.lato(),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _productsStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong. Please try again.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.blue));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No products available for this vendor.'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.7,
            ),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final productData = snapshot.data!.docs[index].data() as Map<String, dynamic>;

              return GestureDetector(
                onTap: () {
                  // Pass required parameters to ProductDetail
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return ProductDetail(
                      productId: productData['productId'], // Assuming productId is available
                       // If you have a productData parameter as well
                    );
                  }));
                },
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image
                      Container(
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(
                              productData['productImages']?.isNotEmpty == true
                                  ? productData['productImages'][0]
                                  : 'https://via.placeholder.com/150',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Name
                            Text(
                              productData['productName'] ?? 'Unnamed Product',
                              style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            // Discount Price
                            Text(
                              '₹${productData['discountPrice'] ?? 'N/A'}',
                              style: TextStyle(color: Colors.green, fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                            // Original Price
                            Text(
                              '₹${productData['price'] ?? 'N/A'}',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
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
          );
        },
      ),
    );
  }
}

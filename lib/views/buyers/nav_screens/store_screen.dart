import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_mart/views/inner_screens/store_detail_screen.dart';

class StoresScreen extends StatelessWidget {
  const StoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _storesStream =
        FirebaseFirestore.instance.collection('vendors').snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: _storesStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Something went wrong. Please try again.',
              style: TextStyle(color: Colors.red),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.blue),
                SizedBox(height: 10),
                Text('Loading stores...'),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No stores available.'));
        }

        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(20), // Adjust padding
            child: Column(
              children: [
                Center(
                  child: Text(
                    'Store Owners',
                    style: GoogleFonts.lato(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final storeData =
                          snapshot.data!.docs[index].data() as Map<String, dynamic>;

                      // Safely access fields with default values
                      final companyName = storeData['companyName'] as String? ?? 'No Name Available';
                      final storeImage = storeData['storeImage'] as String? ?? ''; // Default value
                      final vendorId = storeData['storeId'] as String?;
                      final email = storeData['email'] as String? ?? 'No Email Available'; // Assuming you have an email field

                      // Check if vendorId is null and handle accordingly
                      if (vendorId == null) {
                        return SizedBox(); // Skip this item if vendorId is missing
                      }

                      return InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) {
                            return StoreDetailScreen(storeData: storeData, vendorId: vendorId);
                          }));
                        },
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          margin: const EdgeInsets.symmetric(vertical: 10), // Add margin for list items
                          child: Padding(
                            padding: const EdgeInsets.all(16), // Add padding inside the card
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 30, // Adjust avatar size
                                  backgroundImage: storeImage.isNotEmpty
                                      ? NetworkImage(storeImage)
                                      : null, // Handle empty image
                                  child: storeImage.isEmpty ? Icon(Icons.store, size: 30) : null,
                                ),
                                SizedBox(width: 16), // Space between avatar and text
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        companyName,
                                        style: GoogleFonts.lato(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        email,
                                        style: GoogleFonts.lato(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

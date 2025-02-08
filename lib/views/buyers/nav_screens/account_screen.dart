import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:i_mart/views/buyers/nav_screens/cart_screen.dart';
import 'package:i_mart/views/buyers/nav_screens/favourite_screen.dart';
import 'package:i_mart/views/inner_screens/order_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:i_mart/views/buyers/auth/login_screen.dart';

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  int cartCount = 0;
  int favoritesCount = 0;
  int completedOrdersCount = 0;
  String userId = FirebaseAuth.instance.currentUser!.uid;
  String username = "";
  File? profileImage;
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    cartCount = await getCartItemCount(userId);
    favoritesCount = await getFavoritesCount(userId);
    completedOrdersCount = await getCompletedOrdersCount(userId);

    // Fetch user details from Firestore
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('buyers')
        .doc(userId)
        .get();

    if (mounted) {
      setState(() {
        username = userSnapshot['fullName'];
        profileImageUrl = userSnapshot['profileImage']; // Fetching from Firestore
      });
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      // Upload image to Firebase Storage
      String fileName = 'profileImages/$userId.jpg';
      Reference storageReference = FirebaseStorage.instance.ref().child(fileName);
      await storageReference.putFile(imageFile);

      // Get the uploaded image URL
      String imageUrl = await storageReference.getDownloadURL();

      // Update Firestore with the image URL
      await FirebaseFirestore.instance.collection('buyers').doc(userId).update({
        'profileImage': imageUrl,
      });

      if (mounted) {
        setState(() {
          profileImage = imageFile;
          profileImageUrl = imageUrl;
        });
      }
    }
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  Future<int> getCartItemCount(String userId) async {
    QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
        .collection('cart')
        .where('userId', isEqualTo: userId)
        .get();
    return cartSnapshot.docs.length;
  }

  Future<int> getFavoritesCount(String userId) async {
    QuerySnapshot favoritesSnapshot = await FirebaseFirestore.instance
        .collection('favorites')
        .where('userId', isEqualTo: userId)
        .get();
    return favoritesSnapshot.docs.length;
  }

  Future<int> getCompletedOrdersCount(String userId) async {
    QuerySnapshot completedSnapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'completed')
        .get();
    return completedSnapshot.docs.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Account"), backgroundColor: Colors.blueAccent),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: pickImage,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: profileImage != null
                            ? FileImage(profileImage!)
                            : (profileImageUrl != null
                                ? NetworkImage(profileImageUrl!)
                                : AssetImage('assets/placeholder.png')) as ImageProvider,
                        child: profileImage == null && profileImageUrl == null
                            ? Icon(Icons.camera_alt, size: 50, color: Colors.white)
                            : null,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(username, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    SizedBox(height: 5),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatsCard("Cart", cartCount, Icons.shopping_cart, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => CartScreenProduct()));
                  }),
                  _buildStatsCard("Favourite", favoritesCount, Icons.favorite, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => FavoriteScreen()));
                  }),
                  _buildStatsCard("Completed", completedOrdersCount, Icons.check, () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => OrderScreen()));
                  }),
                ],
              ),
              SizedBox(height: 30),
              _buildMenuOption("Track your order", Icons.local_shipping, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => OrderScreen()));
              }),
              _buildMenuOption("History", Icons.history, () {
                // Navigator.pushNamed(context, '/orderHistory'); // Uncomment this when you have the order history screen
              }),
              _buildMenuOption("Help", Icons.help, () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Help'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Email: imart@gmail.com'),
                          Text('Phone: 9988776655'),
                          SizedBox(height: 10),
                          Text('Description: iMart is your go-to platform for all your shopping needs. Enjoy a seamless shopping experience!'),
                        ],
                      ),
                      actions: [
                        TextButton(
                          child: Text('Close'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              }),
              _buildMenuOption("Logout", Icons.logout, logout),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard(String title, int count, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blueAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.blueAccent, width: 1),
        ),
        padding: EdgeInsets.all(10),
        width: 100,
        child: Column(
          children: [
            Icon(icon, size: 40, color: Colors.blueAccent),
            SizedBox(height: 10),
            Text(count.toString(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(title, style: TextStyle(color: Colors.blueAccent)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOption(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(title, style: TextStyle(fontSize: 16)),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(vertical: 10),
      tileColor: Colors.grey[200],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}

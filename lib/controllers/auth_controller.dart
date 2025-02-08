import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> createNewUser(
    String email,
    String fullName,
    String password,
    String pinCode,
    String locality,
    String city,
    String state,
    String phoneNumber, // Added phone number parameter
    File? image,
  ) async {
    String res = 'Some error occurred';

    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      String imageUrl = '';
      if (image != null) {
        imageUrl = await _uploadImageToStorage(image);
      }

      await _firestore.collection('buyers').doc(userCredential.user!.uid).set({
        'fullName': fullName,
        'profileImage': imageUrl,
        'email': email,
        'uid': userCredential.user!.uid,
        'pinCode': pinCode,
        'locality': locality,
        'city': city,
        'state': state,
        'phoneNumber': phoneNumber, // Save phone number in Firestore
      });

      res = 'success';
    } catch (e) {
      res = e.toString();
    }

    return res;
  }

  Future<String> resetPassword(String email) async {
    String res = 'Some error occurred';
    try {
      await _auth.sendPasswordResetEmail(email: email);
      res = 'Password reset email sent. Please check your inbox.';
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<String> _uploadImageToStorage(File image) async {
    try {
      Reference ref = _storage.ref().child('profileImages').child(_auth.currentUser!.uid);
      UploadTask uploadTask = ref.putFile(image);

      TaskSnapshot snapshot = await uploadTask;

      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      return e.toString();
    }
  }

  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    Map<String, dynamic> res = {'status': 'error', 'role': ''};

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      DocumentSnapshot userDoc = await _firestore
          .collection('buyers')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        res = {
          'status': 'success',
          'role': 'buyer',
        };
      } else {
        res['status'] = 'Invalid user role or user not found.';
      }
    } catch (e) {
      res['status'] = e.toString();
    }

    return res;
  }
}

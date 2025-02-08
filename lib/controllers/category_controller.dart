import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:i_mart/models/category_models.dart';

class CategoryController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  RxList<CategoryModel> categories = <CategoryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _fetchCategories();
  }

  void _fetchCategories() {
    try {
      _firestore.collection('categories').snapshots().listen((querySnapshot) {
        categories.assignAll(
          querySnapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>?;

            if (data != null && data.containsKey('categoryName') && data.containsKey('categoryImage')) {
              return CategoryModel(
                categoryName: data['categoryName'] ?? 'Unknown',
                categoryImage: data['categoryImage'] ?? '',
              );
            } else {
              return CategoryModel(
                categoryName: 'Unknown',
                categoryImage: '',
              );
            }
          }).toList(),
        );
      }, onError: (error) {
        print("Error fetching categories: $error");
      });
    } catch (e) {
      print("Exception caught: $e");
    }
  }
}

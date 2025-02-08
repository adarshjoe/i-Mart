import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_mart/controllers/category_controller.dart';
import 'package:i_mart/views/inner_screens/all_category_product_screen.dart';

class CategoryItem extends StatelessWidget {
  const CategoryItem({Key? key}) : super(key: key); // Corrected constructor

  @override
  Widget build(BuildContext context) {
    final CategoryController categoryController = Get.find<CategoryController>();

    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, // Always 4 columns
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0, // Adjust spacing as needed
            ),
            itemCount: categoryController.categories.length > 8
                ? 8
                : categoryController.categories.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return AllCategoriesScreen(
                      
                    );
                  }));
                },
                child: Container(
                  width: 83,
                  height: 99,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration( // Added BoxDecoration for clarity
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: 0,
                        top: 69,
                        child: SizedBox(
                          width: 83,
                          height: 30,
                          child: Text(
                            categoryController.categories[index].categoryName,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.quicksand(
                              color: Colors.black,
                              fontSize: 14,
                              letterSpacing: 0.3,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 10,
                        top: 0,
                        child: Material(
                          type: MaterialType.transparency,
                          borderRadius: BorderRadius.circular(12),
                          clipBehavior: Clip.antiAlias,
                          child: Ink(
                            color: Colors.white,
                            width: 63,
                            height: 63,
                            child: Image.network(
                              categoryController.categories[index].categoryImage,
                              width: 47,
                              height: 47,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      );
    });
  }
}

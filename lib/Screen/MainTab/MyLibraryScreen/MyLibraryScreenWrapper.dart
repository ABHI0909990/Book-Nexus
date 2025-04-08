import 'package:book_nexus/Constant/assets.dart';
import 'package:book_nexus/Constant/colors.dart';
import 'package:book_nexus/Screen/Basecontroller/basecontroller.dart';
import 'package:book_nexus/Screen/MainTab/MyLibraryScreen/MyLibraryController.dart';
import 'package:flutter/material.dart';
<<<<<<< Updated upstream
import 'package:get/get.dart';
=======
>>>>>>> Stashed changes
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../Widget/GridViewBookList/GridViewBookList.dart';

class MyLibraryScreenWrapper extends BaseView<MyLibraryController> {
  const MyLibraryScreenWrapper({super.key});

  @override
  Widget vBuilder(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 3.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 5.h),
              Text(
                'My Library',
                style: TextStyle(
                  fontSize: 19.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white100Color,
                ),
              ),
              Image.asset(AppImages.line, width: 27.w),
              SizedBox(height: 3.h),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
<<<<<<< Updated upstream
                child: Obx(() => Row(
                      children: [
                        _buildCategoryButton(
                          AppImages.bookmark,
                          CATEGORY_SAVED,
                          isSelected: controller.selectedCategory.value ==
                              CATEGORY_SAVED,
                        ),
                        _buildCategoryButton(
                          AppImages.headphone,
                          CATEGORY_IN_PROGRESS,
                          isSelected: controller.selectedCategory.value ==
                              CATEGORY_IN_PROGRESS,
                        ),
                        _buildCategoryButton(
                          AppImages.checked,
                          CATEGORY_COMPLETED,
                          isSelected: controller.selectedCategory.value ==
                              CATEGORY_COMPLETED,
                        ),
                      ],
                    )),
              ),
              SizedBox(height: 3.h),
              SizedBox(
                  height: 80.h,
                  child: GridViewBookList(books: controller.library)),
=======
                child: Row(
                  children: [
                    _buildCategoryButton(AppImages.bookmark, 'Saved books'),
                    _buildCategoryButton(AppImages.headphone, 'In Progress'),
                    _buildCategoryButton(AppImages.checked, 'Completed'),
                  ],
                ),
              ),
              SizedBox(height: 3.h),
              SizedBox(height: 80.h, child: GridViewBookList(books: controller.library)),
>>>>>>> Stashed changes
            ],
          ),
        ),
      ),
    );
  }

<<<<<<< Updated upstream
  Widget _buildCategoryButton(String image, String category,
      {bool isSelected = false}) {
=======
  Widget _buildCategoryButton(String image, String text) {
>>>>>>> Stashed changes
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 1.w),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
<<<<<<< Updated upstream
          backgroundColor: isSelected ? AppColors.green : AppColors.grey4,
        ),
        onPressed: () {
          controller.filterBooksByCategory(category);
        },
=======
          backgroundColor: AppColors.grey4,
        ),
        onPressed: () {},
>>>>>>> Stashed changes
        child: Row(
          children: [
            Image.asset(image, height: 2.h),
            SizedBox(width: 1.w),
            Text(
<<<<<<< Updated upstream
              category,
=======
              text,
>>>>>>> Stashed changes
              style: TextStyle(fontSize: 15.sp, color: AppColors.white100Color),
            ),
          ],
        ),
      ),
    );
  }
}

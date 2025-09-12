import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../route/app_routes.dart';
import '../../../controllers/add_item_controller.dart';
import '../../../widgets/drawer.dart';
import '../../../widgets/header.dart';
import 'widgets/category_filter_widget.dart';
import 'widgets/menu_item_card.dart';
import 'widgets/search_widget.dart';

class AddItemsView extends StatelessWidget {
  final Map<String, dynamic>? table;

  const AddItemsView({super.key, this.table});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddItemsController());
    controller.setTableContext(table);

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const CommonDrawerWidget(), // Use the centralized drawer
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          CommonHeaderWidget(
            customTitle: 'Add Items',
            onBackPressed: () => NavigationService.goBack(),
            showDrawerButton: true,
          ),
          Expanded(
            child: Column(
              children: [
                // Search Section
                Container(
                  padding: EdgeInsets.all(16.w),
                  child: SearchWidget(controller: controller),
                ),

                // Filter Section
                Container(
                  height: 60.h,
                  child: CategoryFilterWidget(controller: controller),
                ),

                // Items Grid - Fixed GetX issue
                Expanded(
                  child: _buildItemsGrid(controller),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomSection(controller, context),
    );
  }

  // Separate widget for the grid to properly scope the Obx
  Widget _buildItemsGrid(AddItemsController controller) {
    return Obx(() {
      // Check loading state
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF2196F3),
          ),
        );
      }

      // Get the filtered items list
      final items = controller.filteredItems;

      // Check if empty
      if (items.isEmpty) {
        return _buildEmptyState();
      }

      // Build the grid
      return GridView.builder(
        padding: EdgeInsets.all(16.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.85,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return MenuItemCard(
            item: item,
            controller: controller,
          );
        },
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.regular),
            size: 48.sp,
            color: Colors.grey[400],
          ),
          Gap(12.h),
          Text(
            'No items found',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          Gap(4.h),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(AddItemsController controller, BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Obx(() => OutlinedButton(
                onPressed: controller.totalSelectedItems > 0
                    ? () => controller.clearAllSelections()
                    : null,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey[700],
                  side: BorderSide(color: Colors.grey[400]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                child: Text(
                  'Clear All',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )),
            ),
            Gap(12.w),
            Expanded(
              flex: 2,
              child: Obx(() => ElevatedButton(
                onPressed: controller.totalSelectedItems > 0
                    ? () => controller.addSelectedItemsToTable(context)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                  disabledForegroundColor: Colors.grey[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (controller.totalSelectedItems > 0) ...[
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          '${controller.totalSelectedItems}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Gap(8.w),
                    ],
                    Text(
                      controller.totalSelectedItems > 0 ? 'Add to Order' : 'Select Items',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (controller.totalSelectedItems > 0) ...[
                      Gap(8.w),
                      Text(
                        '₹${controller.totalSelectedPrice.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              )),
            ),
          ],
        ),
      ),
    );
  }
}
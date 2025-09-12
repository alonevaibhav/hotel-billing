import 'dart:developer' as deverloper;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hotelbilling/app/modules/view/TakeOrder/components/widgets/select%20_item_widgets.dart';
import '../../../controllers/select_item_controller.dart';
import '../../../widgets/drawer.dart';
import '../../../widgets/header.dart';

class OrderManagementView extends StatelessWidget {

  final Map<String, dynamic>? table;
  final double scaleFactor = 0.8;

  const OrderManagementView({super.key, this.table});

  @override
  Widget build(BuildContext context) {
    // Use single controller instance - initialize if not exists
    final controller = Get.put(OrderManagementController());
    final tableId = table?['id'] ?? 0;

    deverloper.log('Rendering OrderManagementView for tableId: $tableId');

    // Set active table context
    controller.setActiveTable(tableId, table);

    // Get table state for this specific table
    final tableState = controller.getTableState(tableId);

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const CommonDrawerWidget(),
      resizeToAvoidBottomInset: false,
      body: Form(
        key: controller.formKey,
        child: Column(
          children: [
            CommonHeaderWidget(
              customTitle: _getTableTitle(),
              onBackPressed: controller.navigateBack,
              showDrawerButton: true,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w * scaleFactor),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildRecipientSection(tableState),
                    Gap(24.h * scaleFactor),
                    _buildItemsHeader(controller, tableId, context),
                    Gap(16.h * scaleFactor),
                    _buildItemsArea(controller, tableId),
                    Gap(120.h * scaleFactor),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: buildBottomSection(controller, tableId, scaleFactor, context, table),
    );
  }

  String _getTableTitle() {
    final tableNo = table?['tableNumber']?.toString() ?? 'Unknown';
    return 'Table no - $tableNo';
  }

  Widget _buildItemsHeader(
      OrderManagementController controller, int tableId, BuildContext context) {
    final tableState = controller.getTableState(tableId);

    return Row(
      children: [
        Text(
          'Items :',
          style: TextStyle(
            fontSize: 14.sp * scaleFactor,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const Spacer(),

        // Mark as urgent button
        Obx(() => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: OutlinedButton(
                onPressed: () =>
                    controller.toggleUrgentForTable(tableId, context, table),
                style: OutlinedButton.styleFrom(
                  backgroundColor: tableState.isMarkAsUrgent.value
                      ? Colors.orange.withOpacity(0.15)
                      : Colors.transparent,
                  side: BorderSide(
                    color: tableState.isMarkAsUrgent.value
                        ? Colors.orange[600]!
                        : Colors.grey[400]!,
                    width: 1.5 * scaleFactor,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r * scaleFactor),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w * scaleFactor,
                    vertical: 10.h * scaleFactor,
                  ),
                  minimumSize: Size.zero,
                  elevation: tableState.isMarkAsUrgent.value ? 2 : 0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tableState.isMarkAsUrgent.value
                          ? Icons.priority_high
                          : Icons.schedule,
                      size: 14.sp * scaleFactor,
                      color: tableState.isMarkAsUrgent.value
                          ? Colors.orange[700]
                          : Colors.grey[600],
                    ),
                    Gap(4.w * scaleFactor),
                    Text(
                      tableState.isMarkAsUrgent.value
                          ? 'urgent'
                          : 'mark as urgent',
                      style: TextStyle(
                        fontSize: 12.sp * scaleFactor,
                        fontWeight: FontWeight.w600,
                        color: tableState.isMarkAsUrgent.value
                            ? Colors.orange[700]
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            )),
        Gap(8.w * scaleFactor),

        // Add items button
        ElevatedButton(
          onPressed: () => controller.navigateToAddItems(tableId, table),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2196F3),
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r * scaleFactor),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: 16.w * scaleFactor,
              vertical: 10.h * scaleFactor,
            ),
            minimumSize: Size.zero,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, size: 16.sp * scaleFactor),
              Gap(4.w * scaleFactor),
              Text(
                'add items',
                style: TextStyle(
                  fontSize: 12.sp * scaleFactor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemsArea(OrderManagementController controller, int tableId) {
    final tableState = controller.getTableState(tableId);

    return Container(
      height: 400.h * scaleFactor,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r * scaleFactor),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1 * scaleFactor,
        ),
      ),
      child: Obx(() {
        if (tableState.orderItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.restaurant_menu,
                  size: 48.sp * scaleFactor,
                  color: Colors.grey[400],
                ),
                Gap(12.h * scaleFactor),
                Text(
                  'No items added yet',
                  style: TextStyle(
                    fontSize: 14.sp * scaleFactor,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Gap(4.h * scaleFactor),
                Text(
                  'Tap "add items" to start building your order',
                  style: TextStyle(
                    fontSize: 12.sp * scaleFactor,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Items list
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w * scaleFactor,
                  vertical: 12.h * scaleFactor,
                ),
                itemCount: tableState.orderItems.length,
                itemBuilder: (context, index) {
                  final item = tableState.orderItems[index];
                  return _buildOrderItemCard(item, index, controller, tableId, context);
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildOrderItemCard(Map<String, dynamic> item, int index,
      OrderManagementController controller, int tableId, context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h * scaleFactor),
      padding: EdgeInsets.all(12.w * scaleFactor),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8.r * scaleFactor),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Delete button (blue circle with trash icon)
          GestureDetector(
            onTap: () =>
                controller.removeItemFromTable(tableId, index, context),
            child: Container(
              width: 32.w * scaleFactor,
              height: 32.w * scaleFactor,
              decoration: const BoxDecoration(
                color: Color(0xFF2196F3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_outline,
                color: Colors.white,
                size: 18.sp * scaleFactor,
              ),
            ),
          ),

          Gap(12.w * scaleFactor),

          // Item details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['item_name'] ?? 'Unknown Item',
                  style: TextStyle(
                    fontSize: 14.sp * scaleFactor,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item['description'] != null &&
                    item['description'].toString().isNotEmpty) ...[
                  Gap(2.h * scaleFactor),
                  Text(
                    item['description'],
                    style: TextStyle(
                      fontSize: 11.sp * scaleFactor,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          Gap(12.w * scaleFactor),

          // Quantity controls
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Decrement button
              GestureDetector(
                onTap: () => controller.decrementItemQuantity(tableId, index, context),
                child: Container(
                  width: 28.w * scaleFactor,
                  height: 28.w * scaleFactor,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.r * scaleFactor),
                    border: Border.all(
                      color: const Color(0xFF2196F3),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.remove,
                    color: const Color(0xFF2196F3),
                    size: 16.sp * scaleFactor,
                  ),
                ),
              ),

              Gap(8.w * scaleFactor),

              // Quantity display
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w * scaleFactor,
                  vertical: 4.h * scaleFactor,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3),
                  borderRadius: BorderRadius.circular(4.r * scaleFactor),
                ),
                child: Text(
                  '${item['quantity']}',
                  style: TextStyle(
                    fontSize: 14.sp * scaleFactor,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),

              Gap(8.w * scaleFactor),

              // Increment button
              GestureDetector(
                onTap: () => controller.incrementItemQuantity(tableId, index),
                child: Container(
                  width: 28.w * scaleFactor,
                  height: 28.w * scaleFactor,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3),
                    borderRadius: BorderRadius.circular(4.r * scaleFactor),
                  ),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 16.sp * scaleFactor,
                  ),
                ),
              ),
            ],
          ),

          Gap(12.w * scaleFactor),

          // Price and total
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'price',
                style: TextStyle(
                  fontSize: 10.sp * scaleFactor,
                  color: Colors.grey[500],
                ),
              ),
              Text(
                '₹${(item['price'] as double).toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 12.sp * scaleFactor,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              Gap(2.h * scaleFactor),
              Text(
                'total',
                style: TextStyle(
                  fontSize: 10.sp * scaleFactor,
                  color: Colors.grey[500],
                ),
              ),
              Text(
                '₹${(item['total_price'] as double).toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 12.sp * scaleFactor,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2196F3),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

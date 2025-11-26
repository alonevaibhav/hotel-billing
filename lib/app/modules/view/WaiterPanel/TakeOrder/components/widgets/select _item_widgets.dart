import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:hotelbilling/app/data/models/ResponseModel/table_model.dart';
import '../../../../../../../apputils/Utils/common_utils.dart';
import '../../../../../controllers/WaiterPanelController/select_item_controller.dart';

Widget buildRecipientSection(TableOrderState tableState) {
  return Row(
    children: [
      // Recipient name field
      Expanded(
        child: CommonUiUtils.buildTextFormField(
          controller: tableState.fullNameController,
          label: 'Recipient name',
          hint: 'Enter full name',
          icon: Icons.person,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          validator: null, // Optional field
        ),
      ),

      SizedBox(width: 16.w), // Space between fields

      // Phone number field
      Expanded(
        child: CommonUiUtils.buildTextFormField(
          controller: tableState.phoneController,
          label: 'Phone number',
          hint: 'Phone number',
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
          validator: null, // Optional field
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
        ),
      ),
    ],
  );
}




Widget buildBottomSection(OrderManagementController controller, int tableId,
    double scaleFactor, BuildContext context,
    Map<String, dynamic>? table) {
  return Container(
    padding: EdgeInsets.all(16.w * scaleFactor),
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
      child: Obx(() {
        final tableState = controller.getTableState(tableId);

        // Get the actual order data from the table state, not the passed table parameter
        final orderItems = tableState.orderItems;
        final hasItems = orderItems.isNotEmpty;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Final checkout total (only show if there are items)
            if (hasItems) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w * scaleFactor,
                  vertical: 12.h * scaleFactor,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8.r * scaleFactor),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Final Checkout Total',
                      style: TextStyle(
                        fontSize: 16.sp * scaleFactor,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '₹ ${tableState.finalCheckoutTotal.value.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 18.sp * scaleFactor,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2196F3),
                      ),
                    ),
                  ],
                ),
              ),

              Gap(16.h * scaleFactor),
            ],

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: hasItems
                        ? () => controller.sendToChef(tableId, context, table as TableInfo?, orderItems,)
                        : null,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: hasItems ? Colors.grey[700] : Colors.grey[400],
                      side: BorderSide(
                        color: hasItems ? Colors.grey[400]! : Colors.grey[300]!,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r * scaleFactor),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14.h * scaleFactor),
                    ),
                    child: Text(
                      'kot to chef',
                      style: TextStyle(
                        fontSize: 14.sp * scaleFactor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Gap(12.w * scaleFactor),
                Expanded(
                  child: ElevatedButton(
                    onPressed: hasItems && controller.canProceedToCheckout(tableId)
                        ? () => controller.proceedToCheckout(tableId, context, table as TableInfo?, orderItems)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[300],
                      disabledForegroundColor: Colors.grey[600],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r * scaleFactor),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14.h * scaleFactor),
                    ),
                    child: controller.isLoading.value
                        ? SizedBox(
                      width: 20.w * scaleFactor,
                      height: 20.h * scaleFactor,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : Text(
                      'kot to manager',
                      style: TextStyle(
                        fontSize: 14.sp * scaleFactor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    ),
  );
}





import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../../../../apputils/Utils/common_utils.dart';
import '../../../../controllers/select_item_controller.dart'; // Updated import

Widget buildRecipientSection( tableState) {
  // final tableState = controller.getTableState(tableId);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Full Name Field - No validation required
      CommonUiUtils.buildTextFormField(
        controller: tableState.fullNameController, // Access from tableState
        label: 'Recipient name',
        hint: 'Enter full name',
        icon: Icons.person,
        keyboardType: TextInputType.name,
        textCapitalization: TextCapitalization.words,
        // Remove validator to make it optional
        validator: null,
      ),
      Gap(16.h), // Use your existing scaleFactor

      // Phone Number Field - No validation required
      CommonUiUtils.buildTextFormField(
        controller: tableState.phoneController, // Access from tableState
        label: 'Phone number',
        hint: 'Phone number',
        icon: Icons.phone,
        keyboardType: TextInputType.phone,
        // Remove validator to make it optional
        validator: null,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(10),
        ],
      ),
    ],
  );
}

Widget buildBottomSection(OrderManagementController controller, int tableId, double scaleFactor, BuildContext context,table) {
  final tableState = controller.getTableState(tableId);

  return Container(
    padding: EdgeInsets.all(16.w * scaleFactor),
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.3),
          blurRadius: 10,
          offset: const Offset(0, -2),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Total amount display
        Obx(() => Container(
          padding: EdgeInsets.all(16.w * scaleFactor),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8.r * scaleFactor),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount:',
                style: TextStyle(
                  fontSize: 16.sp * scaleFactor,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                '₹${tableState.finalCheckoutTotal.value.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18.sp * scaleFactor,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2196F3),
                ),
              ),
            ],
          ),
        )),
        Gap(16.h * scaleFactor),
        // Action buttons
        Row(
          children: [
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: () => controller.clearAllItemsForTable(tableId, context, table),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r * scaleFactor),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14.h * scaleFactor),
                ),
                child: Text(
                  'Clear All',
                  style: TextStyle(
                    fontSize: 14.sp * scaleFactor,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
            Gap(12.w * scaleFactor),
            Expanded(
              flex: 2,
              child: Obx(() => ElevatedButton(
                onPressed: controller.canProceedToCheckout(tableId)
                    ? () => controller.proceedToCheckout(tableId, context, table)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r * scaleFactor),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14.h * scaleFactor),
                ),
                child: controller.isLoading.value
                    ? SizedBox(
                  height: 20.h * scaleFactor,
                  width: 20.w * scaleFactor,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : Text(
                  'Proceed to Checkout',
                  style: TextStyle(
                    fontSize: 14.sp * scaleFactor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )),
            ),
          ],
        ),
      ],
    ),
  );
}

//
// Widget buildBottomSection(
//     OrderManagementController controller,
//     int tableId,
//     double scaleFactor,
//     BuildContext context,
//     Map<String, dynamic>? tableData, // Add tableData parameter
//     ) {
//   final tableState = controller.getTableState(tableId);
//
//   return Container(
//     padding: EdgeInsets.all(16.w * scaleFactor),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withOpacity(0.05),
//           blurRadius: 8,
//           offset: const Offset(0, -2),
//         ),
//       ],
//     ),
//     child: Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Container(
//           width: double.infinity,
//           padding: EdgeInsets.symmetric(vertical: 16.h * scaleFactor),
//           decoration: BoxDecoration(
//             border: Border(
//               top: BorderSide(
//                 color: Colors.grey[300]!,
//                 width: 1,
//               ),
//             ),
//           ),
//           child: Obx(() => Row(
//             children: [
//               Text(
//                 'Final Checkout Total',
//                 style: TextStyle(
//                   fontSize: 16.sp * scaleFactor,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.black87,
//                 ),
//               ),
//               const Spacer(),
//               Text(
//                 '₹ ${tableState.finalCheckoutTotal.value.toStringAsFixed(2)}', // Access from tableState
//                 style: TextStyle(
//                   fontSize: 16.sp * scaleFactor,
//                   fontWeight: FontWeight.w700,
//                   color: Colors.black87,
//                 ),
//               ),
//             ],
//           )),
//         ),
//         Gap(16.h * scaleFactor),
//         Row(
//           children: [
//             Expanded(
//               child: OutlinedButton(
//                 onPressed: controller.navigateBack,
//                 style: OutlinedButton.styleFrom(
//                   side: BorderSide(
//                     color: Colors.grey[400]!,
//                     width: 1,
//                   ),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8.r * scaleFactor),
//                   ),
//                   padding: EdgeInsets.symmetric(vertical: 14.h * scaleFactor),
//                 ),
//                 child: Text(
//                   'back',
//                   style: TextStyle(
//                     fontSize: 14.sp * scaleFactor,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//               ),
//             ),
//             Gap(12.w * scaleFactor),
//             Expanded(
//               child: Obx(() => ElevatedButton(
//                 onPressed: controller.isLoading.value
//                     ? null
//                     : () => controller.proceedToCheckout(tableId, context, tableData), // Pass required 3 parameters
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF2196F3),
//                   foregroundColor: Colors.white,
//                   elevation: 2,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8.r * scaleFactor),
//                   ),
//                   padding: EdgeInsets.symmetric(vertical: 14.h * scaleFactor),
//                 ),
//                 child: controller.isLoading.value
//                     ? SizedBox(
//                   width: 20.w * scaleFactor,
//                   height: 20.h * scaleFactor,
//                   child: const CircularProgressIndicator(
//                     strokeWidth: 2,
//                     valueColor: AlwaysStoppedAnimation<Color>(
//                       Colors.white,
//                     ),
//                   ),
//                 )
//                     : Text(
//                   'next',
//                   style: TextStyle(
//                     fontSize: 14.sp * scaleFactor,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               )),
//             ),
//           ],
//         ),
//       ],
//     ),
//   );
// }

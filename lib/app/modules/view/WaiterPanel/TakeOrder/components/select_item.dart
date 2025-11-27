//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:gap/gap.dart';
// import 'package:hotelbilling/app/modules/view/WaiterPanel/TakeOrder/components/widgets/select%20_item_widgets.dart';
// import '../../../../../data/models/ResponseModel/table_model.dart';
// import '../../../../../state/app-state.dart';
// import '../../../../controllers/WaiterPanelController/select_item_controller.dart';
// import '../../../../widgets/drawer.dart';
// import '../../../../widgets/header.dart';
//
// class OrderManagementView extends StatelessWidget {
//   final TableInfo? tableInfo;
//   static const double scaleFactor = 0.8;
//
//   const OrderManagementView({super.key, this.tableInfo});
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(OrderManagementController());
//     final tableId = tableInfo?.table.id ?? 0;
//     final tableNumber = tableInfo?.table.tableNumber ?? 0;
//
//     controller.setActiveTable(tableId, tableInfo);
//     final tableState = controller.getTableState(tableId);
//
//     // Call this to fetch existing order if any
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       controller.checkAndFetchExistingOrder(tableId, tableInfo, forceReload: true);
//     });
//     return Scaffold(
//       backgroundColor: Colors.white,
//       drawer: const CommonDrawerWidget(),
//       resizeToAvoidBottomInset: false,
//       body: Form(
//         key: controller.formKey,
//         child: Column(
//           children: [
//             CommonHeaderWidget(
//               customTitle:
//                   'Table No - ${tableInfo?.table.tableNumber ?? "Unknown"}',
//               showDrawerButton: true,
//             ),
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: EdgeInsets.all(16.w * scaleFactor),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     buildRecipientSection(tableState),
//                     Gap(24.h * scaleFactor),
//                     OrderHeader(
//                       controller: controller,
//                       tableId: tableId,
//                       tableInfo: tableInfo,
//                       tableState: tableState,
//                     ),
//                     Gap(16.h * scaleFactor),
//                     OrderContainer(
//                       controller: controller,
//                       tableId: tableId,
//                       tableState: tableState,
//                     ),
//                     Gap(120.h * scaleFactor),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: OrderFooter(
//         controller: controller,
//         tableId: tableId,
//         tableInfo: tableInfo,
//       ),
//     );
//   }
// }
//
// // 1. HEADER - Items label with Urgent and Add Items buttons
// class OrderHeader extends StatelessWidget {
//   final OrderManagementController controller;
//   final int tableId;
//   final TableInfo? tableInfo;
//   final TableOrderState tableState;
//
//   const OrderHeader({
//     required this.controller,
//     required this.tableId,
//     required this.tableInfo,
//     required this.tableState,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Text(
//           'Items :',
//           style: TextStyle(
//             fontSize: 14.sp * OrderManagementView.scaleFactor,
//             fontWeight: FontWeight.w500,
//             color: Colors.black87,
//           ),
//         ),
//         const Spacer(),
//         // Urgent Button
//         Obx(() {
//           final isUrgent = tableState.isMarkAsUrgent.value;
//           return OutlinedButton(
//             onPressed: () =>
//                 controller.toggleUrgentForTable(tableId, context, tableInfo),
//             style: OutlinedButton.styleFrom(
//               backgroundColor: isUrgent
//                   ? Colors.orange.withOpacity(0.15)
//                   : Colors.transparent,
//               side: BorderSide(
//                 color: isUrgent ? Colors.orange[600]! : Colors.grey[400]!,
//                 width: 1.5 * OrderManagementView.scaleFactor,
//               ),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(
//                     8.r * OrderManagementView.scaleFactor),
//               ),
//               padding: EdgeInsets.symmetric(
//                 horizontal: 16.w * OrderManagementView.scaleFactor,
//                 vertical: 10.h * OrderManagementView.scaleFactor,
//               ),
//               minimumSize: Size.zero,
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(
//                   isUrgent ? Icons.priority_high : Icons.schedule,
//                   size: 14.sp * OrderManagementView.scaleFactor,
//                   color: isUrgent ? Colors.orange[700] : Colors.grey[600],
//                 ),
//                 Gap(4.w * OrderManagementView.scaleFactor),
//                 Text(
//                   isUrgent ? 'urgent' : 'mark as urgent',
//                   style: TextStyle(
//                     fontSize: 12.sp * OrderManagementView.scaleFactor,
//                     fontWeight: FontWeight.w600,
//                     color: isUrgent ? Colors.orange[700] : Colors.grey[600],
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }),
//         Gap(8.w * OrderManagementView.scaleFactor),
//         // Add Items Button
//         ElevatedButton(
//           onPressed: () => controller.navigateToAddItems(tableId, tableInfo),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: const Color(0xFF2196F3),
//             foregroundColor: Colors.white,
//             elevation: 2,
//             shape: RoundedRectangleBorder(
//               borderRadius:
//                   BorderRadius.circular(8.r * OrderManagementView.scaleFactor),
//             ),
//             padding: EdgeInsets.symmetric(
//               horizontal: 16.w * OrderManagementView.scaleFactor,
//               vertical: 10.h * OrderManagementView.scaleFactor,
//             ),
//             minimumSize: Size.zero,
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(Icons.add, size: 16.sp * OrderManagementView.scaleFactor),
//               Gap(4.w * OrderManagementView.scaleFactor),
//               Text(
//                 'add items',
//                 style: TextStyle(
//                   fontSize: 12.sp * OrderManagementView.scaleFactor,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// // 2. ORDER CONTAINER - Contains the items list
// class OrderContainer extends StatelessWidget {
//   final OrderManagementController controller;
//   final int tableId;
//   final TableOrderState tableState;
//
//   const OrderContainer({super.key,
//     required this.controller,
//     required this.tableId,
//     required this.tableState,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 400.h * OrderManagementView.scaleFactor,
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius:
//             BorderRadius.circular(8.r * OrderManagementView.scaleFactor),
//         border: Border.all(
//           color: Colors.grey[300]!,
//           width: 1 * OrderManagementView.scaleFactor,
//         ),
//       ),
//       child: Obx(() {
//         // Loading state
//         if (tableState.isLoadingOrder.value) {
//           return const AppLoadingState(
//             message: 'Loading existing order...',
//           );
//         }
//
//         // Empty state
//         if (tableState.orderItems.isEmpty) {
//           return const AppEmptyState(
//             icon: Icons.restaurant_menu,
//             title: 'No items added yet',
//             subtitle: 'Tap "add items" to start building your order',
//           );
//         }
//
//         return Column(
//           children: [
//             // Frozen banner
//             if (tableState.hasFrozenItems)
//               Container(
//                 width: double.infinity,
//                 padding: EdgeInsets.symmetric(
//                   horizontal: 12.w * OrderManagementView.scaleFactor,
//                   vertical: 8.h * OrderManagementView.scaleFactor,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.blue[50],
//                   border: Border(
//                       bottom: BorderSide(color: Colors.blue[200]!, width: 1)),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.info_outline,
//                       size: 16.sp * OrderManagementView.scaleFactor,
//                       color: Colors.blue[700],
//                     ),
//                     Gap(8.w * OrderManagementView.scaleFactor),
//                     Expanded(
//                       child: Text(
//                         'Some items have been sent to kitchen and are locked',
//                         style: TextStyle(
//                           fontSize: 11.sp * OrderManagementView.scaleFactor,
//                           color: Colors.blue[700],
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             // Items list
//             Expanded(
//               child: ListView.builder(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: 16.w * OrderManagementView.scaleFactor,
//                   vertical: 12.h * OrderManagementView.scaleFactor,
//                 ),
//                 itemCount: tableState.orderItems.length,
//                 itemBuilder: (context, index) {
//                   final item = tableState.orderItems[index];
//                   final frozenQty =
//                       tableState.getFrozenQuantity(item['id'].toString());
//                   final currentQty = item['quantity'] as int;
//                   final availableQty = currentQty - frozenQty;
//                   final hasFrozen = frozenQty > 0;
//                   final canDecrement =
//                       frozenQty == 0 ? currentQty > 0 : currentQty > frozenQty;
//                   final canDelete = frozenQty == 0;
//
//                   return Container(
//                     margin: EdgeInsets.only(
//                         bottom: 12.h * OrderManagementView.scaleFactor),
//                     padding:
//                         EdgeInsets.all(12.w * OrderManagementView.scaleFactor),
//                     decoration: BoxDecoration(
//                       color: hasFrozen ? Colors.orange[50] : Colors.grey[50],
//                       borderRadius: BorderRadius.circular(
//                           8.r * OrderManagementView.scaleFactor),
//                       border: Border.all(
//                         color:
//                             hasFrozen ? Colors.orange[300]! : Colors.grey[200]!,
//                         width: hasFrozen ? 2 : 1,
//                       ),
//                     ),
//                     child: Column(
//                       children: [
//                         // Frozen indicator
//                         if (hasFrozen)
//                           Container(
//                             width: double.infinity,
//                             padding: EdgeInsets.symmetric(
//                               horizontal: 8.w * OrderManagementView.scaleFactor,
//                               vertical: 4.h * OrderManagementView.scaleFactor,
//                             ),
//                             margin: EdgeInsets.only(
//                                 bottom: 8.h * OrderManagementView.scaleFactor),
//                             decoration: BoxDecoration(
//                               color: Colors.orange[100],
//                               borderRadius: BorderRadius.circular(
//                                   4.r * OrderManagementView.scaleFactor),
//                               border: Border.all(
//                                   color: Colors.orange[400]!, width: 1),
//                             ),
//                             child: Row(
//                               children: [
//                                 Icon(
//                                   Icons.lock,
//                                   size: 14.sp * OrderManagementView.scaleFactor,
//                                   color: Colors.orange[700],
//                                 ),
//                                 Gap(4.w * OrderManagementView.scaleFactor),
//                                 Text(
//                                   '$frozenQty already sent to kitchen',
//                                   style: TextStyle(
//                                     fontSize:
//                                         11.sp * OrderManagementView.scaleFactor,
//                                     color: Colors.orange[700],
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                                 const Spacer(),
//                                 if (availableQty > 0)
//                                   Container(
//                                     padding: EdgeInsets.symmetric(
//                                       horizontal:
//                                           6.w * OrderManagementView.scaleFactor,
//                                       vertical:
//                                           2.h * OrderManagementView.scaleFactor,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       color: Colors.green[100],
//                                       borderRadius: BorderRadius.circular(10.r *
//                                           OrderManagementView.scaleFactor),
//                                     ),
//                                     child: Text(
//                                       '+$availableQty new',
//                                       style: TextStyle(
//                                         fontSize: 10.sp *
//                                             OrderManagementView.scaleFactor,
//                                         color: Colors.green[700],
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                     ),
//                                   ),
//                               ],
//                             ),
//                           ),
//                         // Item row
//                         Row(
//                           children: [
//                             // Delete button
//                             GestureDetector(
//                               onTap: canDelete
//                                   ? () => controller.removeItemFromTable(
//                                       tableId, index, context)
//                                   : null,
//                               child: Container(
//                                 width: 32.w * OrderManagementView.scaleFactor,
//                                 height: 32.w * OrderManagementView.scaleFactor,
//                                 decoration: BoxDecoration(
//                                   color: canDelete
//                                       ? const Color(0xFF2196F3)
//                                       : Colors.grey[400],
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: Icon(
//                                   canDelete
//                                       ? Icons.delete_outline
//                                       : Icons.block,
//                                   color: Colors.white,
//                                   size: 18.sp * OrderManagementView.scaleFactor,
//                                 ),
//                               ),
//                             ),
//                             Gap(12.w * OrderManagementView.scaleFactor),
//                             // Item details
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     item['item_name'] ?? 'Unknown Item',
//                                     style: TextStyle(
//                                       fontSize: 14.sp *
//                                           OrderManagementView.scaleFactor,
//                                       fontWeight: FontWeight.w600,
//                                       color: Colors.black87,
//                                     ),
//                                     maxLines: 2,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                   if (item['description'] != null &&
//                                       item['description']
//                                           .toString()
//                                           .isNotEmpty) ...[
//                                     Gap(2.h * OrderManagementView.scaleFactor),
//                                     Text(
//                                       item['description'],
//                                       style: TextStyle(
//                                         fontSize: 11.sp *
//                                             OrderManagementView.scaleFactor,
//                                         color: Colors.grey[600],
//                                       ),
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                   ],
//                                 ],
//                               ),
//                             ),
//                             Gap(12.w * OrderManagementView.scaleFactor),
//                             // Quantity controls
//                             Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 GestureDetector(
//                                   onTap: canDecrement
//                                       ? () => controller.decrementItemQuantity(
//                                           tableId, index, context)
//                                       : null,
//                                   child: Container(
//                                     width:
//                                         28.w * OrderManagementView.scaleFactor,
//                                     height:
//                                         28.w * OrderManagementView.scaleFactor,
//                                     decoration: BoxDecoration(
//                                       color: Colors.white,
//                                       borderRadius: BorderRadius.circular(4.r *
//                                           OrderManagementView.scaleFactor),
//                                       border: Border.all(
//                                         color: canDecrement
//                                             ? const Color(0xFF2196F3)
//                                             : Colors.red,
//                                         width: 1.5,
//                                       ),
//                                     ),
//                                     child: Icon(
//                                       canDecrement ? Icons.remove : Icons.block,
//                                       color: canDecrement
//                                           ? const Color(0xFF2196F3)
//                                           : Colors.red,
//                                       size: 16.sp *
//                                           OrderManagementView.scaleFactor,
//                                     ),
//                                   ),
//                                 ),
//                                 Gap(8.w * OrderManagementView.scaleFactor),
//                                 Container(
//                                   padding: EdgeInsets.symmetric(
//                                     horizontal:
//                                         12.w * OrderManagementView.scaleFactor,
//                                     vertical:
//                                         4.h * OrderManagementView.scaleFactor,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: const Color(0xFF2196F3),
//                                     borderRadius: BorderRadius.circular(
//                                         4.r * OrderManagementView.scaleFactor),
//                                   ),
//                                   child: Text(
//                                     hasFrozen
//                                         ? '$currentQty ($frozenQty+$availableQty)'
//                                         : '$currentQty',
//                                     style: TextStyle(
//                                       fontSize: hasFrozen
//                                           ? 12.sp *
//                                               OrderManagementView.scaleFactor
//                                           : 14.sp *
//                                               OrderManagementView.scaleFactor,
//                                       fontWeight: FontWeight.w600,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                                 Gap(8.w * OrderManagementView.scaleFactor),
//                                 GestureDetector(
//                                   onTap: () => controller.incrementItemQuantity(
//                                       tableId, index),
//                                   child: Container(
//                                     width:
//                                         28.w * OrderManagementView.scaleFactor,
//                                     height:
//                                         28.w * OrderManagementView.scaleFactor,
//                                     decoration: BoxDecoration(
//                                       color: const Color(0xFF2196F3),
//                                       borderRadius: BorderRadius.circular(4.r *
//                                           OrderManagementView.scaleFactor),
//                                     ),
//                                     child: Icon(
//                                       Icons.add,
//                                       color: Colors.white,
//                                       size: 16.sp *
//                                           OrderManagementView.scaleFactor,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             Gap(12.w * OrderManagementView.scaleFactor),
//                             // Price column
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.end,
//                               children: [
//                                 Text(
//                                   'price',
//                                   style: TextStyle(
//                                     fontSize:
//                                         10.sp * OrderManagementView.scaleFactor,
//                                     color: Colors.grey[500],
//                                   ),
//                                 ),
//                                 Text(
//                                   '₹${(item['price'] as double).toStringAsFixed(0)}',
//                                   style: TextStyle(
//                                     fontSize:
//                                         12.sp * OrderManagementView.scaleFactor,
//                                     fontWeight: FontWeight.w500,
//                                     color: Colors.black87,
//                                   ),
//                                 ),
//                                 Gap(2.h * OrderManagementView.scaleFactor),
//                                 Text(
//                                   'total',
//                                   style: TextStyle(
//                                     fontSize:
//                                         10.sp * OrderManagementView.scaleFactor,
//                                     color: Colors.grey[500],
//                                   ),
//                                 ),
//                                 Text(
//                                   '₹${(item['total_price'] as double).toStringAsFixed(0)}',
//                                   style: TextStyle(
//                                     fontSize:
//                                         12.sp * OrderManagementView.scaleFactor,
//                                     fontWeight: FontWeight.w600,
//                                     color: const Color(0xFF2196F3),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         );
//       }),
//     );
//   }
// }
//
// // 3. FOOTER - Bottom action buttons
// class OrderFooter extends StatelessWidget {
//   final OrderManagementController controller;
//   final int tableId;
//   final TableInfo? tableInfo;
//
//   const OrderFooter({
//     required this.controller,
//     required this.tableId,
//     required this.tableInfo,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return buildBottomSection(
//       controller,
//       tableId,
//       OrderManagementView.scaleFactor,
//       context,
//       controller.tableInfoToMap(tableInfo),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:hotelbilling/app/modules/view/WaiterPanel/TakeOrder/components/widgets/select%20_item_widgets.dart';
import '../../../../../data/models/ResponseModel/table_model.dart';
import '../../../../../state/app-state.dart';
import '../../../../controllers/WaiterPanelController/select_item_controller.dart';
import '../../../../widgets/drawer.dart';
import '../../../../widgets/header.dart';

class OrderManagementView extends StatelessWidget {
  final TableInfo? tableInfo;
  static const double scaleFactor = 0.8;

  const OrderManagementView({super.key, this.tableInfo});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OrderManagementController());
    final tableId = tableInfo?.table.id ?? 0;
    final tableNumber = tableInfo?.table.tableNumber ?? 0;

    controller.setActiveTable(tableId, tableInfo);
    final tableState = controller.getTableState(tableId);

    // Call this to fetch existing order if any
      controller.checkAndFetchExistingOrder(tableId, tableInfo, );

    return Scaffold(
      backgroundColor: Colors.grey[50], // Softer background
      drawer: const CommonDrawerWidget(),
      resizeToAvoidBottomInset: false,
      body: Form(
        key: controller.formKey,
        child: Column(
          children: [
            // Header stays at top
            CommonHeaderWidget(
              customTitle: 'Table No - ${tableInfo?.table.tableNumber ?? "Unknown"}',
              showDrawerButton: true,
            ),
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w * scaleFactor),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildRecipientSection(tableState),
                    Gap(20.h * scaleFactor),
                    OrderHeader(
                      controller: controller,
                      tableId: tableId,
                      tableInfo: tableInfo,
                      tableState: tableState,
                    ),
                    Gap(16.h * scaleFactor),
                    OrderContainer(
                      controller: controller,
                      tableId: tableId,
                      tableState: tableState,
                    ),
                    Gap(16.h * scaleFactor), // Reduced gap at bottom
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Fixed bottom bar
      bottomNavigationBar: OrderFooter(
        controller: controller,
        tableId: tableId,
        tableInfo: tableInfo,
      ),
    );
  }
}

// 1. HEADER - Items label with Urgent and Add Items buttons
class OrderHeader extends StatelessWidget {
  final OrderManagementController controller;
  final int tableId;
  final TableInfo? tableInfo;
  final TableOrderState tableState;

  const OrderHeader({
    required this.controller,
    required this.tableId,
    required this.tableInfo,
    required this.tableState,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Items',
          style: TextStyle(
            fontSize: 16.sp * OrderManagementView.scaleFactor,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const Spacer(),
        // Urgent Button
        Obx(() {
          final isUrgent = tableState.isMarkAsUrgent.value;
          return OutlinedButton.icon(
            onPressed: () => controller.toggleUrgentForTable(tableId, context, tableInfo),
            style: OutlinedButton.styleFrom(
              backgroundColor: isUrgent ? Colors.orange.withOpacity(0.1) : Colors.white,
              side: BorderSide(
                color: isUrgent ? Colors.orange[600]! : Colors.grey[300]!,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r * OrderManagementView.scaleFactor),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 12.w * OrderManagementView.scaleFactor,
                vertical: 8.h * OrderManagementView.scaleFactor,
              ),
            ),
            icon: Icon(
              isUrgent ? Icons.priority_high : Icons.schedule,
              size: 16.sp * OrderManagementView.scaleFactor,
              color: isUrgent ? Colors.orange[700] : Colors.grey[600],
            ),
            label: Text(
              isUrgent ? 'Urgent' : 'Mark Urgent',
              style: TextStyle(
                fontSize: 12.sp * OrderManagementView.scaleFactor,
                fontWeight: FontWeight.w500,
                color: isUrgent ? Colors.orange[700] : Colors.grey[700],
              ),
            ),
          );
        }),
        Gap(8.w * OrderManagementView.scaleFactor),
        // Add Items Button
        ElevatedButton.icon(
          onPressed: () => controller.navigateToAddItems(tableId, tableInfo),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2196F3),
            foregroundColor: Colors.white,
            elevation: 1,
            shadowColor: Colors.blue.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r * OrderManagementView.scaleFactor),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: 12.w * OrderManagementView.scaleFactor,
              vertical: 8.h * OrderManagementView.scaleFactor,
            ),
          ),
          icon: Icon(Icons.add, size: 18.sp * OrderManagementView.scaleFactor),
          label: Text(
            'Add Items',
            style: TextStyle(
              fontSize: 12.sp * OrderManagementView.scaleFactor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// 2. ORDER CONTAINER - Contains the items list (now with better spacing)
class OrderContainer extends StatelessWidget {
  final OrderManagementController controller;
  final int tableId;
  final TableOrderState tableState;

  const OrderContainer({
    super.key,
    required this.controller,
    required this.tableId,
    required this.tableState,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Loading state
      if (tableState.isLoadingOrder.value) {
        return Container(
          height: 300.h * OrderManagementView.scaleFactor,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r * OrderManagementView.scaleFactor),
          ),
          child: const AppLoadingState(
            message: 'Loading existing order...',
          ),
        );
      }

      // Empty state
      if (tableState.orderItems.isEmpty) {
        return Container(
          height: 300.h * OrderManagementView.scaleFactor,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r * OrderManagementView.scaleFactor),
            border: Border.all(color: Colors.grey[200]!, width: 1),
          ),
          child: const AppEmptyState(
            icon: Icons.restaurant_menu,
            title: 'No items added yet',
            subtitle: 'Tap "Add Items" to start building your order',
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Frozen banner
          if (tableState.hasFrozenItems)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w * OrderManagementView.scaleFactor),
              // margin: EdgeInsets.only(bottom: 3.h * OrderManagementView.scaleFactor),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12.r * OrderManagementView.scaleFactor),
                border: Border.all(color: Colors.orange[200]!, width: 1),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18.sp * OrderManagementView.scaleFactor,
                    color: Colors.orange[700],
                  ),
                  Gap(8.w * OrderManagementView.scaleFactor),
                  Expanded(
                    child: Text(
                      'Some items have been sent to kitchen and are locked',
                      style: TextStyle(
                        fontSize: 12.sp * OrderManagementView.scaleFactor,
                        color: Colors.orange[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Items list with improved spacing
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tableState.orderItems.length,
            separatorBuilder: (context, index) => Gap(16.h * OrderManagementView.scaleFactor),
            itemBuilder: (context, index) {
              final item = tableState.orderItems[index];
              final frozenQty = tableState.getFrozenQuantity(item['id'].toString());
              final currentQty = item['quantity'] as int;
              final availableQty = currentQty - frozenQty;
              final hasFrozen = frozenQty > 0;
              final canDecrement = frozenQty == 0 ? currentQty > 0 : currentQty > frozenQty;
              final canDelete = frozenQty == 0;

              return _buildOrderItemCard(
                item: item,
                index: index,
                frozenQty: frozenQty,
                currentQty: currentQty,
                availableQty: availableQty,
                hasFrozen: hasFrozen,
                canDecrement: canDecrement,
                canDelete: canDelete,
                controller: controller,
                tableId: tableId,
                context: context,
              );
            },
          ),
        ],
      );
    });
  }

  Widget _buildOrderItemCard({
    required Map<String, dynamic> item,
    required int index,
    required int frozenQty,
    required int currentQty,
    required int availableQty,
    required bool hasFrozen,
    required bool canDecrement,
    required bool canDelete,
    required OrderManagementController controller,
    required int tableId,
    required BuildContext context,
  }) {
    return Container(
      padding: EdgeInsets.all(10.w * OrderManagementView.scaleFactor),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r * OrderManagementView.scaleFactor),
        border: Border.all(
          color: hasFrozen ? Colors.orange[300]! : Colors.grey[200]!,
          width: hasFrozen ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Frozen indicator banner
          if (hasFrozen) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: 10.w * OrderManagementView.scaleFactor,
                vertical: 6.h * OrderManagementView.scaleFactor,
              ),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(6.r * OrderManagementView.scaleFactor),
                border: Border.all(color: Colors.orange[200]!, width: 1),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 14.sp * OrderManagementView.scaleFactor,
                    color: Colors.orange[700],
                  ),
                  Gap(6.w * OrderManagementView.scaleFactor),
                  Expanded(
                    child: Text(
                      '$frozenQty item${frozenQty > 1 ? "s" : ""} sent to kitchen',
                      style: TextStyle(
                        fontSize: 11.sp * OrderManagementView.scaleFactor,
                        color: Colors.orange[800],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (availableQty > 0)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w * OrderManagementView.scaleFactor,
                        vertical: 3.h * OrderManagementView.scaleFactor,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(12.r * OrderManagementView.scaleFactor),
                      ),
                      child: Text(
                        '+$availableQty new',
                        style: TextStyle(
                          fontSize: 10.sp * OrderManagementView.scaleFactor,
                          color: Colors.green[800],
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Gap(12.h * OrderManagementView.scaleFactor),
          ],

          // Main item row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Delete button
              GestureDetector(
                onTap: canDelete
                    ? () => controller.removeItemFromTable(tableId, index, context)
                    : null,
                child: Container(
                  width: 36.w * OrderManagementView.scaleFactor,
                  height: 36.w * OrderManagementView.scaleFactor,
                  decoration: BoxDecoration(
                    color: canDelete ? const Color(0xFFEF5350) : Colors.grey[300],
                    shape: BoxShape.circle,
                    boxShadow: canDelete
                        ? [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                        : null,
                  ),
                  child: Icon(
                    canDelete ? Icons.delete_outline : Icons.lock,
                    color: Colors.white,
                    size: 18.sp * OrderManagementView.scaleFactor,
                  ),
                ),
              ),
              Gap(14.w * OrderManagementView.scaleFactor),

              // Item details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['item_name'] ?? 'Unknown Item',
                      style: TextStyle(
                        fontSize: 15.sp * OrderManagementView.scaleFactor,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item['description'] != null && item['description'].toString().isNotEmpty) ...[
                      Gap(4.h * OrderManagementView.scaleFactor),
                      Text(
                        item['description'],
                        style: TextStyle(
                          fontSize: 12.sp * OrderManagementView.scaleFactor,
                          color: Colors.grey[600],
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    Gap(12.h * OrderManagementView.scaleFactor),

                    // Price and quantity row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Price section
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '₹${(item['price'] as double).toStringAsFixed(0)} each',
                              style: TextStyle(
                                fontSize: 11.sp * OrderManagementView.scaleFactor,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Gap(2.h * OrderManagementView.scaleFactor),
                            Text(
                              '₹${(item['total_price'] as double).toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 16.sp * OrderManagementView.scaleFactor,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2196F3),
                              ),
                            ),
                          ],
                        ),

                        // Quantity controls
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8.r * OrderManagementView.scaleFactor),
                            border: Border.all(color: Colors.grey[200]!, width: 1),
                          ),
                          padding: EdgeInsets.all(4.w * OrderManagementView.scaleFactor),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Decrement button
                              GestureDetector(
                                onTap: canDecrement
                                    ? () => controller.decrementItemQuantity(tableId, index, context)
                                    : null,
                                child: Container(
                                  width: 32.w * OrderManagementView.scaleFactor,
                                  height: 32.w * OrderManagementView.scaleFactor,
                                  decoration: BoxDecoration(
                                    color: canDecrement ? const Color(0xFF2196F3) : Colors.grey[300],
                                    borderRadius: BorderRadius.circular(6.r * OrderManagementView.scaleFactor),
                                  ),
                                  child: Icon(
                                    canDecrement ? Icons.remove : Icons.lock,
                                    color: Colors.white,
                                    size: 16.sp * OrderManagementView.scaleFactor,
                                  ),
                                ),
                              ),
                              Gap(12.w * OrderManagementView.scaleFactor),

                              // Quantity display
                              Container(
                                constraints: BoxConstraints(
                                  minWidth: 50.w * OrderManagementView.scaleFactor,
                                ),
                                child: Text(
                                  hasFrozen ? '$currentQty ($frozenQty+$availableQty)' : '$currentQty',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14.sp * OrderManagementView.scaleFactor,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              Gap(12.w * OrderManagementView.scaleFactor),

                              // Increment button
                              GestureDetector(
                                onTap: () => controller.incrementItemQuantity(tableId, index),
                                child: Container(
                                  width: 32.w * OrderManagementView.scaleFactor,
                                  height: 32.w * OrderManagementView.scaleFactor,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2196F3),
                                    borderRadius: BorderRadius.circular(6.r * OrderManagementView.scaleFactor),
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 16.sp * OrderManagementView.scaleFactor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 3. FOOTER - Bottom action buttons (stays fixed)
class OrderFooter extends StatelessWidget {
  final OrderManagementController controller;
  final int tableId;
  final TableInfo? tableInfo;

  const OrderFooter({
    required this.controller,
    required this.tableId,
    required this.tableInfo,
  });

  @override
  Widget build(BuildContext context) {
    return buildBottomSection(
      controller,
      tableId,
      OrderManagementView.scaleFactor,
      context,
      controller.tableInfoToMap(tableInfo),
    );
  }
}



//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:gap/gap.dart';
// import 'package:phosphor_flutter/phosphor_flutter.dart';
// import 'dart:developer' as developer;
// import '../../controllers/take_order_controller.dart';
// import '../../widgets/table_widget.dart';
//
// class TakeOrder extends StatelessWidget {
//   final Map<String, dynamic>? initialData;
//
//   const TakeOrder({
//     super.key,
//     this.initialData,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(TakeOrdersController());
//     final isDesktop = MediaQuery.of(context).size.width > 800;
//
//     // Log initial data if provided
//     if (initialData != null) {
//       developer.log('TakeOrdersView initialized with data: ${initialData.toString()}', name: 'TakeOrders');
//     }
//
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         body: Column(
//           children: [
//             // Header
//             _buildHeader(context),
//             // Main Content
//             Expanded(
//               child: _buildContent(controller),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHeader(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         border: Border(
//           bottom: BorderSide(
//             color: Colors.grey.shade200,
//             width: 1,
//           ),
//         ),
//       ),
//       child: Row(
//         children: [
//           // Back Button
//           GestureDetector(
//             onTap: () {
//               developer.log('Back button pressed', name: 'TakeOrders');
//               Navigator.of(context).pop();
//             },
//             child: Icon(
//               PhosphorIcons.arrowLeft(PhosphorIconsStyle.regular),
//               size: 24,
//               color: Colors.black87,
//             ),
//           ),
//
//           Gap(16),
//
//           // Hotel Info
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Alpani Hotel',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 Gap(2),
//                 Text(
//                   '2672 Westheimer Rd. Santa Ana, Illinois 85486',
//                   style: TextStyle(
//                     fontSize: 10,
//                     color: Colors.grey.shade600,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ),
//
//           // Phone Number (hide on small screens)
//           Builder(
//             builder: (context) {
//               final screenWidth = MediaQuery.of(context).size.width;
//               if (screenWidth < 600) return const SizedBox.shrink();
//
//               return Row(
//                 children: [
//                   Text(
//                     'Tel: (406) 555-0120',
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey.shade600,
//                     ),
//                   ),
//                   Gap(16),
//                 ],
//               );
//             },
//           ),
//
//           // Logout Button
//           GestureDetector(
//             onTap: () {
//               developer.log('Logout button pressed', name: 'TakeOrders');
//               Get.snackbar('Info', 'Logout functionality will be implemented');
//             },
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               decoration: BoxDecoration(
//                 color: const Color(0xFF5B73DF),
//                 borderRadius: BorderRadius.circular(4),
//               ),
//               child: const Text(
//                 'logout',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 12,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildContent(TakeOrdersController controller) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Action buttons (take orders selected, ready orders inactive)
//           Row(
//             children: [
//               // Take Orders Button (Active)
//               Expanded(
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF5B73DF),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: const Center(
//                     child: Text(
//                       'take orders',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//
//               Gap(16),
//
//               // Ready Orders Button (Inactive)
//               Expanded(
//                 child: GestureDetector(
//                   onTap: () {
//                     developer.log('Ready Orders button pressed', name: 'TakeOrders');
//                     Get.snackbar('Info', 'Ready Orders feature will be implemented');
//                   },
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       border: Border.all(color: Colors.grey.shade300),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: const Center(
//                       child: Text(
//                         'ready orders',
//                         style: TextStyle(
//                           color: Colors.black87,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//
//           Gap(20),
//
//           // Common area section
//           Expanded(
//             child: Container(
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 color: const Color(0xFFFFF9C4), // Light yellow background
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Common area title
//                   const Text(
//                     'Common area',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.black87,
//                     ),
//                   ),
//
//                   Gap(16),
//
//                   // Tables grid
//                   Expanded(
//                     child: Obx(() {
//                       if (controller.isLoading.value) {
//                         return const Center(
//                           child: CircularProgressIndicator(),
//                         );
//                       }
//
//                       if (controller.commonAreaTables.isEmpty) {
//                         return const Center(
//                           child: Text(
//                             'No tables available',
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.black54,
//                             ),
//                           ),
//                         );
//                       }
//
//                       return GridView.builder(
//                         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                           crossAxisCount: 4,
//                           crossAxisSpacing: 8,
//                           mainAxisSpacing: 8,
//                           childAspectRatio: 0.8,
//                         ),
//                         itemCount: controller.commonAreaTables.length,
//                         itemBuilder: (context, index) {
//                           final table = controller.commonAreaTables[index];
//
//                           return TableCardWidget(
//                             tableNumber: table['tableNumber'] ?? 1,
//                             price: table['price'] ?? 0,
//                             time: table['time'] ?? 0,
//                             isOccupied: table['isOccupied'] ?? false,
//                             onTap: () => controller.handleTableTap(index),
//                           );
//                         },
//                       );
//                     }),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gap/gap.dart';
import 'dart:developer' as developer;
import '../../controllers/take_order_controller.dart';
import '../../widgets/table_widget.dart';

// Content widget without Scaffold - can be reused
class TakeOrderContent extends StatelessWidget {
  const TakeOrderContent({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TakeOrdersController());

    return Container(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF9C4), // Light yellow background
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Common area title
            const Text(
              'Common area',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),

            Gap(16),

            // Tables grid
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (controller.commonAreaTables.isEmpty) {
                  return const Center(
                    child: Text(
                      'No tables available',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  );
                }

                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: controller.commonAreaTables.length,
                  itemBuilder: (context, index) {
                    final table = controller.commonAreaTables[index];

                    return TableCardWidget(
                      tableNumber: table['tableNumber'] ?? 1,
                      price: table['price'] ?? 0,
                      time: table['time'] ?? 0,
                      isOccupied: table['isOccupied'] ?? false,
                      onTap: () => controller.handleTableTap(index),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
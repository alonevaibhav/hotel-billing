// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:gap/gap.dart';
// import 'package:phosphor_flutter/phosphor_flutter.dart';
// import '../../controllers/home_controller.dart';
//
// class RestaurantView extends StatelessWidget {
//   const RestaurantView({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(RestaurantController());
//     final isDesktop = MediaQuery.of(context).size.width > 800;
//
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         drawer: isDesktop ? null : _buildDrawer(controller),
//         body: _buildMobileLayout(controller),
//       ),
//     );
//   }
//
//   // Mobile layout with drawer and full-width content
//   Widget _buildMobileLayout(RestaurantController controller) {
//     return Column(
//       children: [
//         // Header
//         _buildHeader(controller),
//         // Main Content Area
//         Expanded(
//           child: _buildHomeContent(controller),
//         ),
//       ],
//     );
//   }
//
//   // Drawer for mobile
//   Widget _buildDrawer(RestaurantController controller) {
//     return Drawer(
//       backgroundColor: const Color(0xFFF5F5F5),
//       child: Column(
//         children: [
//           // Drawer Header
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
//             decoration: const BoxDecoration(
//               color: Color(0xFF5B73DF),
//             ),
//             child: const Text(
//               'Menu',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 20,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//           Gap(20),
//           // Menu Items
//           Obx(() => _buildSidebarItem(
//                 controller: controller,
//                 icon: PhosphorIcons.coffee(PhosphorIconsStyle.regular),
//                 label: 'RESTAURANT',
//                 isActive: controller.selectedSidebarItem.value == 'RESTAURANT',
//                 onTap: () {
//                   controller.handleRestaurant();
//                   Get.back(); // Close drawer
//                 },
//               )),
//           Obx(() => _buildSidebarItem(
//                 controller: controller,
//                 icon: PhosphorIcons.bell(PhosphorIconsStyle.regular),
//                 label: 'NOTIFICATION',
//                 isActive:
//                     controller.selectedSidebarItem.value == 'NOTIFICATION',
//                 onTap: () {
//                   controller.handleNotification();
//                   Get.back(); // Close drawer
//                 },
//               )),
//           Obx(() => _buildSidebarItem(
//                 controller: controller,
//                 icon: PhosphorIcons.clockCounterClockwise(
//                     PhosphorIconsStyle.regular),
//                 label: 'HISTORY',
//                 isActive: controller.selectedSidebarItem.value == 'HISTORY',
//                 onTap: () {
//                   controller.handleHistory();
//                   Get.back(); // Close drawer
//                 },
//               )),
//           Obx(() => _buildSidebarItem(
//                 controller: controller,
//                 icon: PhosphorIcons.gear(PhosphorIconsStyle.regular),
//                 label: 'SETTINGS',
//                 isActive: controller.selectedSidebarItem.value == 'SETTINGS',
//                 onTap: () {
//                   controller.handleSettings();
//                   Get.back(); // Close drawer
//                 },
//               )),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSidebarItem({
//     required RestaurantController controller,
//     required IconData icon,
//     required String label,
//     required bool isActive,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
//         decoration: BoxDecoration(
//           color: isActive ? const Color(0xFF5B73DF) : Colors.transparent,
//           borderRadius: isActive ? BorderRadius.circular(8) : null,
//         ),
//         margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
//         child: Row(
//           children: [
//             Icon(
//               icon,
//               color: isActive ? Colors.white : Colors.black87,
//               size: 20,
//             ),
//             Gap(12),
//             Text(
//               label,
//               style: TextStyle(
//                 color: isActive ? Colors.white : Colors.black87,
//                 fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
//                 fontSize: 14,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHeader(RestaurantController controller) {
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
//           // Hamburger Menu (only show on mobile)
//           Builder(
//             builder: (context) {
//               final isDesktop = MediaQuery.of(context).size.width > 800;
//               if (isDesktop) return const SizedBox.shrink();
//
//               return GestureDetector(
//                 onTap: () => Scaffold.of(context).openDrawer(),
//                 child: Icon(
//                   PhosphorIcons.list(PhosphorIconsStyle.regular),
//                   size: 24,
//                   color: Colors.black87,
//                 ),
//               );
//             },
//           ),
//           Builder(
//             builder: (context) {
//               final isDesktop = MediaQuery.of(context).size.width > 800;
//               return Gap(isDesktop ? 0 : 16);
//             },
//           ),
//           // Hotel Info
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Obx(() => Text(
//                       controller.hotelName.value,
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.black87,
//                       ),
//                     )),
//                 Gap(2),
//                 Obx(() => Text(
//                       controller.hotelAddress.value,
//                       style: TextStyle(
//                         fontSize: 10,
//                         color: Colors.grey.shade600,
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     )),
//               ],
//             ),
//           ),
//           // Phone Number (hide on small screens)
//           Builder(
//             builder: (context) {
//               final screenWidth = MediaQuery.of(context).size.width;
//               if (screenWidth < 600) return const SizedBox.shrink();
//
//               return Row(
//                 children: [
//                   Obx(() => Text(
//                         controller.phoneNumber.value,
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey.shade600,
//                         ),
//                       )),
//                   Gap(16),
//                 ],
//               );
//             },
//           ),
//           // Logout Button
//           GestureDetector(
//             onTap: () => controller.handleLogout(),
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
//                   fontSize: 15,
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
//   Widget _buildHomeContent(RestaurantController controller) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final isTablet = constraints.maxWidth > 600;
//
//         return Container(
//           padding: EdgeInsets.all(isTablet ? 24 : 16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   // Take Orders Button
//                   Expanded(
//                     child: Obx(() => _buildActionButton(
//                           label: 'take orders',
//                           backgroundColor:
//                               controller.selectedMainButton.value ==
//                                       'take_orders'
//                                   ? const Color(0xFF5B73DF)
//                                   : Colors.white,
//                           textColor: controller.selectedMainButton.value ==
//                                   'take_orders'
//                               ? Colors.white
//                               : Colors.black87,
//                           borderColor: controller.selectedMainButton.value ==
//                                   'take_orders'
//                               ? null
//                               : Colors.grey.shade300,
//                           onTap: () => controller.handleTakeOrders(),
//                         )),
//                   ),
//                   Gap(16),
//                   // Ready Orders Button
//                   Expanded(
//                     child: Obx(() => _buildActionButton(
//                           label: 'ready orders',
//                           backgroundColor:
//                               controller.selectedMainButton.value ==
//                                       'ready_orders'
//                                   ? const Color(0xFF5B73DF)
//                                   : Colors.white,
//                           textColor: controller.selectedMainButton.value ==
//                                   'ready_orders'
//                               ? Colors.white
//                               : Colors.black87,
//                           borderColor: controller.selectedMainButton.value ==
//                                   'ready_orders'
//                               ? null
//                               : Colors.grey.shade300,
//                           onTap: () => controller.handleReadyOrders(),
//                         )),
//                   ),
//                 ],
//               )
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildActionButton({
//     required String label,
//     required Color backgroundColor,
//     required Color textColor,
//     Color? borderColor,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 16),
//         decoration: BoxDecoration(
//           color: backgroundColor,
//           border: borderColor != null ? Border.all(color: borderColor) : null,
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Center(
//           child: Text(
//             label,
//             style: TextStyle(
//               color: textColor,
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gap/gap.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../controllers/home_controller.dart';
import '../TakeOrder/take_order.dart';

class RestaurantView extends StatelessWidget {
  const RestaurantView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RestaurantController());
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        drawer: isDesktop ? null : _buildDrawer(controller),
        body: Column(
          children: [
            // Header
            _buildHeader(controller),
            // Main Content Area
            Expanded(
              child: Obx(() {
                // Show TakeOrder content by default or based on selection
                if (controller.selectedMainButton.value == 'take_orders') {
                  return _buildTakeOrderContent(controller);
                } else {
                  return _buildReadyOrderContent(controller);
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  // Take Order Content - Remove Scaffold from TakeOrder and embed it here
  Widget _buildTakeOrderContent(RestaurantController controller) {
    return Column(
      children: [
        // Action buttons
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Take Orders Button (Active)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5B73DF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'take orders',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              Gap(16),
              // Ready Orders Button (Inactive)
              Expanded(
                child: GestureDetector(
                  onTap: () => controller.handleReadyOrders(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'ready orders',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // TakeOrder content without Scaffold
        Expanded(
          child: TakeOrderContent(), // Create this as a separate widget without Scaffold
        ),
      ],
    );
  }

  // Ready Order Content
  Widget _buildReadyOrderContent(RestaurantController controller) {
    return Column(
      children: [
        // Action buttons
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Take Orders Button (Inactive)
              Expanded(
                child: GestureDetector(
                  onTap: () => controller.handleTakeOrders(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'take orders',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Gap(16),
              // Ready Orders Button (Active)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5B73DF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'ready orders',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Ready orders content placeholder
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F8FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'Ready Orders Feature\nWill be implemented',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Drawer for mobile
  Widget _buildDrawer(RestaurantController controller) {
    return Drawer(
      backgroundColor: const Color(0xFFF5F5F5),
      child: Column(
        children: [
          // Drawer Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            decoration: const BoxDecoration(
              color: Color(0xFF5B73DF),
            ),
            child: const Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Gap(20),
          // Menu Items
          Obx(() => _buildSidebarItem(
            controller: controller,
            icon: PhosphorIcons.coffee(PhosphorIconsStyle.regular),
            label: 'RESTAURANT',
            isActive: controller.selectedSidebarItem.value == 'RESTAURANT',
            onTap: () {
              controller.handleRestaurant();
              Get.back(); // Close drawer
            },
          )),
          Obx(() => _buildSidebarItem(
            controller: controller,
            icon: PhosphorIcons.bell(PhosphorIconsStyle.regular),
            label: 'NOTIFICATION',
            isActive: controller.selectedSidebarItem.value == 'NOTIFICATION',
            onTap: () {
              controller.handleNotification();
              Get.back(); // Close drawer
            },
          )),
          Obx(() => _buildSidebarItem(
            controller: controller,
            icon: PhosphorIcons.clockCounterClockwise(PhosphorIconsStyle.regular),
            label: 'HISTORY',
            isActive: controller.selectedSidebarItem.value == 'HISTORY',
            onTap: () {
              controller.handleHistory();
              Get.back(); // Close drawer
            },
          )),
          Obx(() => _buildSidebarItem(
            controller: controller,
            icon: PhosphorIcons.gear(PhosphorIconsStyle.regular),
            label: 'SETTINGS',
            isActive: controller.selectedSidebarItem.value == 'SETTINGS',
            onTap: () {
              controller.handleSettings();
              Get.back(); // Close drawer
            },
          )),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({
    required RestaurantController controller,
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF5B73DF) : Colors.transparent,
          borderRadius: isActive ? BorderRadius.circular(8) : null,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : Colors.black87,
              size: 20,
            ),
            Gap(12),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black87,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(RestaurantController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Hamburger Menu (only show on mobile)
          Builder(
            builder: (context) {
              final isDesktop = MediaQuery.of(context).size.width > 800;
              if (isDesktop) return const SizedBox.shrink();

              return GestureDetector(
                onTap: () => Scaffold.of(context).openDrawer(),
                child: Icon(
                  PhosphorIcons.list(PhosphorIconsStyle.regular),
                  size: 24,
                  color: Colors.black87,
                ),
              );
            },
          ),
          Builder(
            builder: (context) {
              final isDesktop = MediaQuery.of(context).size.width > 800;
              return Gap(isDesktop ? 0 : 16);
            },
          ),
          // Hotel Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => Text(
                  controller.hotelName.value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                )),
                Gap(2),
                Obx(() => Text(
                  controller.hotelAddress.value,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )),
              ],
            ),
          ),
          // Phone Number (hide on small screens)
          Builder(
            builder: (context) {
              final screenWidth = MediaQuery.of(context).size.width;
              if (screenWidth < 600) return const SizedBox.shrink();

              return Row(
                children: [
                  Obx(() => Text(
                    controller.phoneNumber.value,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  )),
                  Gap(16),
                ],
              );
            },
          ),
          // Logout Button
          GestureDetector(
            onTap: () => controller.handleLogout(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF5B73DF),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'logout',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
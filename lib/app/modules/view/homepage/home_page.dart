import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gap/gap.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../apputils/Utils/double_tap_to_exit.dart';
import '../../controllers/home_controller.dart';
import '../../widgets/drawer.dart';
import '../../widgets/header.dart';
import '../TakeOrder/take_order.dart';
import '../ready_order/ready_order.dart';

class WaiterDashboardView extends StatelessWidget {
  const WaiterDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final RestaurantController controller = Get.put(RestaurantController());

    return DoubleBackToExit(
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          drawer: const CommonDrawerWidget(), // Use the centralized drawer
          body: Column(
            children: [
              // Common Header
              const CommonHeaderWidget(
                showBackButton: false,
                showDrawerButton: true,
              ),
              // Main Content Area
              Expanded(
                child: Obx(() {
                  // Show content based on selection
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
      ),
    );
  }

  // Take Order Content
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
              const Gap(16),
              // Ready Orders Button (Inactive)
              Expanded(
                child: GestureDetector(
                  onTap: () =>
                      controller.handleReadyOrders(), // Fixed: Added onTap
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
          child: TakeOrderContent(), // Make sure this widget exists
        ),
      ],
    );
  }

  // Ready Order Content - Fixed structure
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
                  onTap: () =>
                      controller.handleTakeOrders(), // Fixed: Added onTap
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
              const Gap(16),
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
        // Ready orders content - Fixed: Removed incorrect nesting
        Expanded(
          child:
          ReadyOrder(), // Make sure this widget exists and doesn't contain Scaffold
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
          const Gap(20),
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
            isActive:
            controller.selectedSidebarItem.value == 'NOTIFICATION',
            onTap: () {
              controller.handleNotification();
              Get.back(); // Close drawer
            },
          )),
          Obx(() => _buildSidebarItem(
            controller: controller,
            icon: PhosphorIcons.clockCounterClockwise(
                PhosphorIconsStyle.regular),
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
            const Gap(12),
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
}

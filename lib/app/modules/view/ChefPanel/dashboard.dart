import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gap/gap.dart';
import 'package:hotelbilling/app/modules/view/ChefPanel/sidebar/chef_drawer.dart';
import '../../../../apputils/Utils/double_tap_to_exit.dart';
import '../../controllers/ChefController/dashboard_controller.dart';
import '../../controllers/chef_drawer_controller.dart';
import '../WaiterPanel/sidebar/waiter_drawer.dart';
import '../../widgets/header.dart';
import 'pending_order.dart';
import 'preparing_order.dart';

class ChefDashboard extends StatefulWidget {
  const ChefDashboard({super.key});

  @override
  State<ChefDashboard> createState() => _ChefDashboardState();
}

class _ChefDashboardState extends State<ChefDashboard> {
  late ChefController controller;

  @override
  void initState() {
    super.initState();

    // Initialize or get existing controller
    if (Get.isRegistered<ChefController>()) {
      controller = Get.find<ChefController>();
    } else {
      controller = Get.put(ChefController(), permanent: true);
    }

    // Reset to RESTAURANT selection when dashboard loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<ChefDrawerController>()) {
        final drawerController = Get.find<ChefDrawerController>();
        drawerController.resetToDefault();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DoubleBackToExit(
      child: Scaffold(
        backgroundColor: Colors.white,
        drawer: const ChefDrawerWidget(), // Use the centralized drawer
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
    );
  }

  // Take Order Content
  Widget _buildTakeOrderContent(ChefController controller) {
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
                      'Pending Orders',
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
                        'Preparing Orders',
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
          child: AcceptOrder(), // Make sure this widget exists
        ),
      ],
    );
  }

  // Ready Order Content - Fixed structure
  Widget _buildReadyOrderContent(ChefController controller) {
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
                        'Pending Orders',
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
                      'Preparing Orders',
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
        Expanded(
          child:
              DoneOrder(), // Make sure this widget exists and doesn't contain Scaffold
        ),
      ],
    );
  }
}

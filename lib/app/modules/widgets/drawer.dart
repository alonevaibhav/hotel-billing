import 'package:flutter/material.dart' hide DrawerController;
import 'package:get/get.dart';
import 'package:gap/gap.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/services/storage_service.dart';
import '../controllers/drawer_controller.dart';

class CommonDrawerWidget extends StatelessWidget {
  const CommonDrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final DrawerController controller = Get.put(DrawerController());

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header
            _buildDrawerHeader(controller),

            // Divider
            Divider(
              color: Colors.grey.shade200,
              height: 1,
              thickness: 1,
            ),

            // Menu Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildMenuItem(
                    controller: controller,
                    icon: PhosphorIcons.storefront(PhosphorIconsStyle.regular),
                    title: 'RESTAURANT',
                    isSelected:
                        controller.selectedSidebarItem.value == 'RESTAURANT',
                    onTap: () {
                      controller.handleRestaurant();
                      Navigator.pop(context);
                    },
                  ),
                  _buildMenuItem(
                    controller: controller,
                    icon: PhosphorIcons.bell(PhosphorIconsStyle.regular),
                    title: 'NOTIFICATIONS',
                    isSelected:
                        controller.selectedSidebarItem.value == 'NOTIFICATION',
                    onTap: () {
                      controller.handleNotification();
                      Navigator.pop(context);
                    },
                  ),
                  _buildMenuItem(
                    controller: controller,
                    icon: PhosphorIcons.clockCounterClockwise(
                        PhosphorIconsStyle.regular),
                    title: 'HISTORY',
                    isSelected:
                        controller.selectedSidebarItem.value == 'HISTORY',
                    onTap: () {
                      controller.handleHistory();
                      Navigator.pop(context);
                    },
                  ),
                  _buildMenuItem(
                    controller: controller,
                    icon: PhosphorIcons.gear(PhosphorIconsStyle.regular),
                    title: 'SETTINGS',
                    isSelected:
                        controller.selectedSidebarItem.value == 'SETTINGS',
                    onTap: () {
                      controller.handleSettings();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),

            // Footer with logout
            _buildDrawerFooter(controller, context),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(DrawerController controller) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF5B73DF),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant Logo or Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                PhosphorIcons.storefront(PhosphorIconsStyle.fill),
                size: 32,
                color: Colors.white,
              ),
            ),

            const Gap(16),

            // Restaurant Name
            Text(
              StorageService.to.getOrganizationName(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),

            const Gap(4),

            // Restaurant Address
            Text(
              StorageService.to.getOrganizationAddress(),
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const Gap(8),

            // User Info with better styling
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    PhosphorIcons.user(PhosphorIconsStyle.fill),
                    size: 12,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  const Gap(4),
                  Text(
                    'Welcome, ${StorageService.to.getUserName()}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required DrawerController controller,
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF5B73DF).withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? const Color(0xFF5B73DF) : Colors.grey.shade600,
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? const Color(0xFF5B73DF) : Colors.grey.shade800,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        onTap: onTap,
        dense: true,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget _buildDrawerFooter(DrawerController controller, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Refresh Data Button
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () {
                controller.refreshData();
                Navigator.pop(context);
              },
              icon: Icon(
                PhosphorIcons.arrowsCounterClockwise(
                    PhosphorIconsStyle.regular),
                size: 16,
                color: Colors.grey.shade600,
              ),
              label: Text(
                'Refresh Data',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
              style: TextButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),

          const Gap(4),

          // Logout Button
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () => _showLogoutDialog(context, controller),
              icon: Icon(
                PhosphorIcons.signOut(PhosphorIconsStyle.regular),
                size: 16,
                color: Colors.red.shade600,
              ),
              label: Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red.shade600,
                  fontSize: 13,
                ),
              ),
              style: TextButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),

          const Gap(8),

          // App Version
          Text(
            'Version 1.0.0',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, DrawerController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Logout',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Close drawer
                controller.handleLogout(); // Call logout handler
              },
              child: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

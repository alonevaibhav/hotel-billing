import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gap/gap.dart';
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
                      onTap: () => controller.handleTableTap(index,context),
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
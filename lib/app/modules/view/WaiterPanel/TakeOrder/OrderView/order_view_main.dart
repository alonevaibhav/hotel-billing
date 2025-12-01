import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import '../../../../../data/models/ResponseModel/table_model.dart';
import '../../../../controllers/WaiterPanelController/select_item_controller.dart';
import '../../../../widgets/drawer.dart';
import '../../../../widgets/header.dart';
import '../widgets/select _item_widgets.dart';
import 'order_container.dart';
import 'order_footer.dart';
import 'order_header.dart';

class OrderManagementView extends StatelessWidget {
  final TableInfo? tableInfo;
  static const double scaleFactor = 0.8;

  const OrderManagementView({super.key, this.tableInfo});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OrderManagementController());
    final tableId = tableInfo?.table.id ?? 0;
    final tableNumber = tableInfo?.table.tableNumber ?? 0;

    // Set active table first
    controller.setActiveTable(tableId, tableInfo);
    final tableState = controller.getTableState(tableId);
    final orderId = tableInfo?.currentOrder?.orderId ?? 0;

    controller.resetTableStateIfNeeded(tableId, tableInfo);

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
              customTitle:
              'Table No - ${tableInfo?.table.tableNumber ?? "Unknown"}',
              showDrawerButton: true,
            ),
            // Scrollable content with RefreshIndicator
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await controller.fetchOrder(orderId, tableId);
                },
                child: SingleChildScrollView(
                  physics:
                  const AlwaysScrollableScrollPhysics(), // This enables pull-to-refresh
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



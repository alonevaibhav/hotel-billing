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

    controller.setActiveTable(tableId, tableInfo);
    final tableState = controller.getTableState(tableId);

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const CommonDrawerWidget(),
      resizeToAvoidBottomInset: false,
      body: Form(
        key: controller.formKey,
        child: Column(
          children: [
            CommonHeaderWidget(
              customTitle: 'Table No - ${tableInfo?.table.tableNumber ?? "Unknown"}',
              showDrawerButton: true,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w * scaleFactor),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildRecipientSection(tableState),
                    Gap(24.h * scaleFactor),
                    _ItemsHeader(
                      controller: controller,
                      tableId: tableId,
                      tableInfo: tableInfo,
                      tableState: tableState,
                    ),
                    Gap(16.h * scaleFactor),
                    _ItemsList(
                      controller: controller,
                      tableId: tableId,
                      tableState: tableState,
                    ),
                    Gap(120.h * scaleFactor),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: buildBottomSection(
        controller,
        tableId,
        scaleFactor,
        context,
        controller.tableInfoToMap(tableInfo),
      ),
    );
  }
}

// Extracted header component
class _ItemsHeader extends StatelessWidget {
  final OrderManagementController controller;
  final int tableId;
  final TableInfo? tableInfo;
  final TableOrderState tableState;

  const _ItemsHeader({
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
          'Items :',
          style: TextStyle(
            fontSize: 14.sp * OrderManagementView.scaleFactor,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const Spacer(),
        _UrgentButton(
          controller: controller,
          tableId: tableId,
          tableInfo: tableInfo,
          tableState: tableState,
        ),
        Gap(8.w * OrderManagementView.scaleFactor),
        _AddItemsButton(
          controller: controller,
          tableId: tableId,
          tableInfo: tableInfo,
        ),
      ],
    );
  }
}

// Urgent button component
class _UrgentButton extends StatelessWidget {
  final OrderManagementController controller;
  final int tableId;
  final TableInfo? tableInfo;
  final TableOrderState tableState;

  const _UrgentButton({
    required this.controller,
    required this.tableId,
    required this.tableInfo,
    required this.tableState,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isUrgent = tableState.isMarkAsUrgent.value;
      return OutlinedButton(
        onPressed: () =>
            controller.toggleUrgentForTable(tableId, context, tableInfo),
        style: OutlinedButton.styleFrom(
          backgroundColor:
              isUrgent ? Colors.orange.withOpacity(0.15) : Colors.transparent,
          side: BorderSide(
            color: isUrgent ? Colors.orange[600]! : Colors.grey[400]!,
            width: 1.5 * OrderManagementView.scaleFactor,
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(8.r * OrderManagementView.scaleFactor),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 16.w * OrderManagementView.scaleFactor,
            vertical: 10.h * OrderManagementView.scaleFactor,
          ),
          minimumSize: Size.zero,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isUrgent ? Icons.priority_high : Icons.schedule,
              size: 14.sp * OrderManagementView.scaleFactor,
              color: isUrgent ? Colors.orange[700] : Colors.grey[600],
            ),
            Gap(4.w * OrderManagementView.scaleFactor),
            Text(
              isUrgent ? 'urgent' : 'mark as urgent',
              style: TextStyle(
                fontSize: 12.sp * OrderManagementView.scaleFactor,
                fontWeight: FontWeight.w600,
                color: isUrgent ? Colors.orange[700] : Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    });
  }
}

// Add items button component
class _AddItemsButton extends StatelessWidget {
  final OrderManagementController controller;
  final int tableId;
  final TableInfo? tableInfo;

  const _AddItemsButton({
    required this.controller,
    required this.tableId,
    required this.tableInfo,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => controller.navigateToAddItems(tableId, tableInfo),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(8.r * OrderManagementView.scaleFactor),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 16.w * OrderManagementView.scaleFactor,
          vertical: 10.h * OrderManagementView.scaleFactor,
        ),
        minimumSize: Size.zero,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add, size: 16.sp * OrderManagementView.scaleFactor),
          Gap(4.w * OrderManagementView.scaleFactor),
          Text(
            'add items',
            style: TextStyle(
              fontSize: 12.sp * OrderManagementView.scaleFactor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Items list component
class _ItemsList extends StatelessWidget {
  final OrderManagementController controller;
  final int tableId;
  final TableOrderState tableState;

  const _ItemsList({
    required this.controller,
    required this.tableId,
    required this.tableState,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400.h * OrderManagementView.scaleFactor,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(8.r * OrderManagementView.scaleFactor),
        border: Border.all(
            color: Colors.grey[300]!,
            width: 1 * OrderManagementView.scaleFactor),
      ),
      child: Obx(() {
        // Loading state usage
        if (tableState.isLoadingOrder.value) {
          return const AppLoadingState(
            message: 'Loading existing order...',
          );
        }

            // Empty state usage
        if (tableState.orderItems.isEmpty) {
          return const AppEmptyState(
            icon: Icons.restaurant_menu,
            title: 'No items added yet',
            subtitle: 'Tap "add items" to start building your order',
          );
        }

        return Column(
          children: [
            if (tableState.hasFrozenItems) _FrozenBanner(),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w * OrderManagementView.scaleFactor,
                  vertical: 12.h * OrderManagementView.scaleFactor,
                ),
                itemCount: tableState.orderItems.length,
                itemBuilder: (context, index) => _OrderItemCard(
                  item: tableState.orderItems[index],
                  index: index,
                  controller: controller,
                  tableId: tableId,
                  tableState: tableState,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

// Frozen banner
class _FrozenBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 12.w * OrderManagementView.scaleFactor,
        vertical: 8.h * OrderManagementView.scaleFactor,
      ),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border(bottom: BorderSide(color: Colors.blue[200]!, width: 1)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16.sp * OrderManagementView.scaleFactor,
            color: Colors.blue[700],
          ),
          Gap(8.w * OrderManagementView.scaleFactor),
          Expanded(
            child: Text(
              'Some items have been sent to kitchen and are locked',
              style: TextStyle(
                fontSize: 11.sp * OrderManagementView.scaleFactor,
                color: Colors.blue[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Order item card
class _OrderItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final int index;
  final OrderManagementController controller;
  final int tableId;
  final TableOrderState tableState;

  const _OrderItemCard({
    required this.item,
    required this.index,
    required this.controller,
    required this.tableId,
    required this.tableState,
  });

  @override
  Widget build(BuildContext context) {
    final frozenQty = tableState.getFrozenQuantity(item['id'].toString());
    final currentQty = item['quantity'] as int;
    final availableQty = currentQty - frozenQty;
    final hasFrozen = frozenQty > 0;
    final canDecrement =
        frozenQty == 0 ? currentQty > 0 : currentQty > frozenQty;
    final canDelete = frozenQty == 0;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h * OrderManagementView.scaleFactor),
      padding: EdgeInsets.all(12.w * OrderManagementView.scaleFactor),
      decoration: BoxDecoration(
        color: hasFrozen ? Colors.orange[50] : Colors.grey[50],
        borderRadius:
            BorderRadius.circular(8.r * OrderManagementView.scaleFactor),
        border: Border.all(
          color: hasFrozen ? Colors.orange[300]! : Colors.grey[200]!,
          width: hasFrozen ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          if (hasFrozen)
            _FrozenIndicator(frozenQty: frozenQty, availableQty: availableQty),
          Row(
            children: [
              _DeleteButton(
                canDelete: canDelete,
                onTap: () =>
                    controller.removeItemFromTable(tableId, index, context),
              ),
              Gap(12.w * OrderManagementView.scaleFactor),
              _ItemDetails(item: item),
              Gap(12.w * OrderManagementView.scaleFactor),
              _QuantityControls(
                currentQty: currentQty,
                frozenQty: frozenQty,
                availableQty: availableQty,
                canDecrement: canDecrement,
                hasFrozen: hasFrozen,
                onIncrement: () =>
                    controller.incrementItemQuantity(tableId, index),
                onDecrement: () =>
                    controller.decrementItemQuantity(tableId, index, context),
              ),
              Gap(12.w * OrderManagementView.scaleFactor),
              _PriceColumn(item: item),
            ],
          ),
        ],
      ),
    );
  }
}

// Frozen indicator
class _FrozenIndicator extends StatelessWidget {
  final int frozenQty;
  final int availableQty;

  const _FrozenIndicator({required this.frozenQty, required this.availableQty});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 8.w * OrderManagementView.scaleFactor,
        vertical: 4.h * OrderManagementView.scaleFactor,
      ),
      margin: EdgeInsets.only(bottom: 8.h * OrderManagementView.scaleFactor),
      decoration: BoxDecoration(
        color: Colors.orange[100],
        borderRadius:
            BorderRadius.circular(4.r * OrderManagementView.scaleFactor),
        border: Border.all(color: Colors.orange[400]!, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.lock,
              size: 14.sp * OrderManagementView.scaleFactor,
              color: Colors.orange[700]),
          Gap(4.w * OrderManagementView.scaleFactor),
          Text(
            '$frozenQty already sent to kitchen',
            style: TextStyle(
              fontSize: 11.sp * OrderManagementView.scaleFactor,
              color: Colors.orange[700],
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          if (availableQty > 0)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 6.w * OrderManagementView.scaleFactor,
                vertical: 2.h * OrderManagementView.scaleFactor,
              ),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(
                    10.r * OrderManagementView.scaleFactor),
              ),
              child: Text(
                '+$availableQty new',
                style: TextStyle(
                  fontSize: 10.sp * OrderManagementView.scaleFactor,
                  color: Colors.green[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Delete button
class _DeleteButton extends StatelessWidget {
  final bool canDelete;
  final VoidCallback? onTap;

  const _DeleteButton({required this.canDelete, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: canDelete ? onTap : null,
      child: Container(
        width: 32.w * OrderManagementView.scaleFactor,
        height: 32.w * OrderManagementView.scaleFactor,
        decoration: BoxDecoration(
          color: canDelete ? const Color(0xFF2196F3) : Colors.grey[400],
          shape: BoxShape.circle,
        ),
        child: Icon(
          canDelete ? Icons.delete_outline : Icons.block,
          color: Colors.white,
          size: 18.sp * OrderManagementView.scaleFactor,
        ),
      ),
    );
  }
}

// Item details
class _ItemDetails extends StatelessWidget {
  final Map<String, dynamic> item;

  const _ItemDetails({required this.item});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item['item_name'] ?? 'Unknown Item',
            style: TextStyle(
              fontSize: 14.sp * OrderManagementView.scaleFactor,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (item['description'] != null &&
              item['description'].toString().isNotEmpty) ...[
            Gap(2.h * OrderManagementView.scaleFactor),
            Text(
              item['description'],
              style: TextStyle(
                fontSize: 11.sp * OrderManagementView.scaleFactor,
                color: Colors.grey[600],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

// Quantity controls
class _QuantityControls extends StatelessWidget {
  final int currentQty;
  final int frozenQty;
  final int availableQty;
  final bool canDecrement;
  final bool hasFrozen;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _QuantityControls({
    required this.currentQty,
    required this.frozenQty,
    required this.availableQty,
    required this.canDecrement,
    required this.hasFrozen,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: canDecrement ? onDecrement : null,
          child: Container(
            width: 28.w * OrderManagementView.scaleFactor,
            height: 28.w * OrderManagementView.scaleFactor,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(4.r * OrderManagementView.scaleFactor),
              border: Border.all(
                color: canDecrement ? const Color(0xFF2196F3) : Colors.red,
                width: 1.5,
              ),
            ),
            child: Icon(
              canDecrement ? Icons.remove : Icons.block,
              color: canDecrement ? const Color(0xFF2196F3) : Colors.red,
              size: 16.sp * OrderManagementView.scaleFactor,
            ),
          ),
        ),
        Gap(8.w * OrderManagementView.scaleFactor),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 12.w * OrderManagementView.scaleFactor,
            vertical: 4.h * OrderManagementView.scaleFactor,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF2196F3),
            borderRadius:
                BorderRadius.circular(4.r * OrderManagementView.scaleFactor),
          ),
          child: Text(
            hasFrozen
                ? '$currentQty ($frozenQty+$availableQty)'
                : '$currentQty',
            style: TextStyle(
              fontSize: hasFrozen
                  ? 12.sp * OrderManagementView.scaleFactor
                  : 14.sp * OrderManagementView.scaleFactor,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        Gap(8.w * OrderManagementView.scaleFactor),
        GestureDetector(
          onTap: onIncrement,
          child: Container(
            width: 28.w * OrderManagementView.scaleFactor,
            height: 28.w * OrderManagementView.scaleFactor,
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3),
              borderRadius:
                  BorderRadius.circular(4.r * OrderManagementView.scaleFactor),
            ),
            child: Icon(
              Icons.add,
              color: Colors.white,
              size: 16.sp * OrderManagementView.scaleFactor,
            ),
          ),
        ),
      ],
    );
  }
}

// Price column
class _PriceColumn extends StatelessWidget {
  final Map<String, dynamic> item;

  const _PriceColumn({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'price',
          style: TextStyle(
            fontSize: 10.sp * OrderManagementView.scaleFactor,
            color: Colors.grey[500],
          ),
        ),
        Text(
          '₹${(item['price'] as double).toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 12.sp * OrderManagementView.scaleFactor,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        Gap(2.h * OrderManagementView.scaleFactor),
        Text(
          'total',
          style: TextStyle(
            fontSize: 10.sp * OrderManagementView.scaleFactor,
            color: Colors.grey[500],
          ),
        ),
        Text(
          '₹${(item['total_price'] as double).toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 12.sp * OrderManagementView.scaleFactor,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2196F3),
          ),
        ),
      ],
    );
  }
}

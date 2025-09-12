import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../controllers/ChefController/accept_order_controller.dart';

Widget buildOrderCard(BuildContext context, AcceptOrderController controller,
    Map<String, dynamic> order, int index, double scaleFactor) {
  final tableNumber = order['tableNumber']?.toString() ?? '';
  final orderNumber = order['orderNumber']?.toString() ?? '';
  final items = List<Map<String, dynamic>>.from(order['items'] ?? []);
  final totalAmount = (order['totalAmount'] ?? 0.0).toDouble();
  final totalItems = controller.getTotalItemsCount(items);
  final tableId = order['tableId'] ?? 0;

  return Container(
    margin: EdgeInsets.only(bottom: (16 * scaleFactor).h),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular((12 * scaleFactor).r),
      border: Border.all(color: Colors.black26, width: 1), // Added black border
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Order Header
        Container(
          padding: EdgeInsets.all((16 * scaleFactor).w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order no. $orderNumber',
                    style: GoogleFonts.inter(
                      fontSize: (16 * scaleFactor).sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildInfoChip(
                      'table no: $tableNumber', Icons.chair, scaleFactor),
                ],
              ),
            ],
          ),
        ),
        // Items Summary
        Container(
          padding: EdgeInsets.symmetric(horizontal: (16 * scaleFactor).w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Food Items',
                style: GoogleFonts.inter(
                  fontSize: (14 * scaleFactor).sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              Gap((8 * scaleFactor).h),

              // Use Obx to watch for expansion changes
              Obx(() {
                final isExpanded = controller.expandedOrders.contains(tableId);
                final itemsToShow = isExpanded ? items : items.take(2).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Show items
                    ...itemsToShow
                        .map((item) => _buildItemSummary(item, scaleFactor)),

                    // Show expand/collapse button if more than 2 items
                    if (items.length > 2) ...[
                      Gap((4 * scaleFactor).h),
                      GestureDetector(
                        onTap: () => controller.toggleOrderExpansion(tableId),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: (4 * scaleFactor).h),
                          child: Row(
                            children: [
                              Text(
                                isExpanded
                                    ? 'Show less'
                                    : '+${items.length - 2} more items',
                                style: GoogleFonts.inter(
                                  fontSize: (12 * scaleFactor).sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blue[500],
                                ),
                              ),
                              Gap((4 * scaleFactor).w),
                              Icon(
                                isExpanded
                                    ? PhosphorIcons.caretUp(
                                        PhosphorIconsStyle.regular)
                                    : PhosphorIcons.caretDown(
                                        PhosphorIconsStyle.regular),
                                size: (12 * scaleFactor).sp,
                                color: Colors.blue[500],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              }),
            ],
          ),
        ),
        Gap((16 * scaleFactor).h),
        // Order Summary and Actions
        Container(
          padding: EdgeInsets.all((16 * scaleFactor).w),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular((12 * scaleFactor).r),
              bottomRight: Radius.circular((12 * scaleFactor).r),
            ),
          ),
          child: Column(
            children: [
              // Total Summary
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Items: $totalItems',
                    style: GoogleFonts.inter(
                      fontSize: (14 * scaleFactor).sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    controller.formatCurrency(totalAmount),
                    style: GoogleFonts.inter(
                      fontSize: (16 * scaleFactor).sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.green[600],
                    ),
                  ),
                ],
              ),
              Gap((16 * scaleFactor).h),
              // Action Buttons
              Row(
                children: [
                  // Reject Button
                  Expanded(
                    child: Obx(
                      () => ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () =>
                                controller.showRejectDialog(order['tableId']),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.grey[700],
                          elevation: 0,
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular((8 * scaleFactor).r),
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: (12 * scaleFactor).h),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              PhosphorIcons.x(PhosphorIconsStyle.regular),
                              size: (16 * scaleFactor).sp,
                            ),
                            Gap((6 * scaleFactor).w),
                            Text(
                              'Reject',
                              style: GoogleFonts.inter(
                                fontSize: (13 * scaleFactor).sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Gap((12 * scaleFactor).w),
                  // Accept Button
                  Expanded(
                    child: Obx(
                      () => ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () => controller.acceptOrder(
                                context, order['tableId']),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[500],
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular((8 * scaleFactor).r),
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: (12 * scaleFactor).h),
                        ),
                        child: controller.isLoading.value
                            ? SizedBox(
                                height: (18 * scaleFactor).h,
                                width: (18 * scaleFactor).w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    PhosphorIcons.check(
                                        PhosphorIconsStyle.regular),
                                    size: (16 * scaleFactor).sp,
                                  ),
                                  Gap((6 * scaleFactor).w),
                                  Text(
                                    'Accept',
                                    style: GoogleFonts.inter(
                                      fontSize: (13 * scaleFactor).sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildInfoChip(String text, IconData icon, double scaleFactor) {
  return Container(
    padding: EdgeInsets.symmetric(
        horizontal: (8 * scaleFactor).w, vertical: (4 * scaleFactor).h),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular((6 * scaleFactor).r),
      border: Border.all(color: Colors.grey[300]!),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: (12 * scaleFactor).sp,
          color: Colors.grey[600],
        ),
        Gap((4 * scaleFactor).w),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: (11 * scaleFactor).sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
      ],
    ),
  );
}

Widget _buildItemSummary(Map<String, dynamic> item, double scaleFactor) {
  final quantity = item['quantity'] ?? 0;
  final name = item['name'] ?? '';
  final isVegetarian = (item['is_vegetarian'] ?? 0) == 1;
  return Padding(
    padding: EdgeInsets.only(bottom: (6 * scaleFactor).h),
    child: Row(
      children: [
        // Vegetarian/Non-vegetarian indicator
        Container(
          width: (12 * scaleFactor).w,
          height: (12 * scaleFactor).w,
          decoration: BoxDecoration(
            border: Border.all(
              color: isVegetarian ? Colors.green : Colors.red,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular((2 * scaleFactor).r),
          ),
          child: Center(
            child: Container(
              width: (4 * scaleFactor).w,
              height: (4 * scaleFactor).w,
              decoration: BoxDecoration(
                color: isVegetarian ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular((1 * scaleFactor).r),
              ),
            ),
          ),
        ),
        Gap((8 * scaleFactor).w),
        // Item name
        Expanded(
          child: Text(
            name,
            style: GoogleFonts.inter(
              fontSize: (13 * scaleFactor).sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Quantity badge
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: (6 * scaleFactor).w, vertical: (2 * scaleFactor).h),
          decoration: BoxDecoration(
            color: Colors.blue[500],
            borderRadius: BorderRadius.circular((3 * scaleFactor).r),
          ),
          child: Text(
            '$quantity',
            style: GoogleFonts.inter(
              fontSize: (11 * scaleFactor).sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    ),
  );
}

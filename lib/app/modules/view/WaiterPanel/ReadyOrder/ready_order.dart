import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hotelbilling/app/modules/view/WaiterPanel/ReadyOrder/ready_order_widgets.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../data/models/ResponseModel/ready_order_model.dart';
import '../../../controllers/WaiterPanelController/ready_order_controller.dart';

class ReadyOrder extends StatelessWidget {
  const ReadyOrder({super.key});

  @override
  Widget build(BuildContext context) {
    final scaleFactor = 0.9;
    final controller = Get.put(ReadyOrderController(), permanent: true);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return _buildLoadingState(scaleFactor);
                    }

                    if (controller.errorMessage.value.isNotEmpty) {
                      return _buildErrorState(controller, scaleFactor);
                    }

                    return buildOrdersList(controller, scaleFactor);
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(double scaleFactor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green[600]!),
          ),
          Gap((16 * scaleFactor).h),
          Text(
            'Loading orders...',
            style: GoogleFonts.inter(
              fontSize: (14 * scaleFactor).sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ReadyOrderController controller, double scaleFactor) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all((24 * scaleFactor).w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIcons.warningCircle(PhosphorIconsStyle.regular),
              size: (64 * scaleFactor).sp,
              color: Colors.red[400],
            ),
            Gap((16 * scaleFactor).h),
            Text(
              'Failed to load orders',
              style: GoogleFonts.inter(
                fontSize: (16 * scaleFactor).sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            Gap((8 * scaleFactor).h),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: (13 * scaleFactor).sp,
                color: Colors.grey[600],
              ),
            ),
            Gap((24 * scaleFactor).h),
            ElevatedButton.icon(
              onPressed: () => controller.fetchReadyOrders(),
              icon: Icon(
                PhosphorIcons.arrowsClockwise(PhosphorIconsStyle.regular),
                size: (16 * scaleFactor).sp,
              ),
              label: Text(
                'Retry',
                style: GoogleFonts.inter(
                  fontSize: (14 * scaleFactor).sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: (24 * scaleFactor).w,
                  vertical: (12 * scaleFactor).h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular((8 * scaleFactor).r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildOrdersList(ReadyOrderController controller, double scaleFactor) {
    return Obx(() {
      if (controller.ordersData.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                PhosphorIcons.clipboard(PhosphorIconsStyle.regular),
                size: (64 * scaleFactor).sp,
                color: Colors.grey[400],
              ),
              Gap((16 * scaleFactor).h),
              Text(
                'No ready orders',
                style: GoogleFonts.inter(
                  fontSize: (16 * scaleFactor).sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
              Gap((8 * scaleFactor).h),
              Text(
                'Orders will appear here when ready',
                style: GoogleFonts.inter(
                  fontSize: (13 * scaleFactor).sp,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.refreshOrders(),
        color: Colors.green[600],
        child: ListView.builder(
          padding: EdgeInsets.symmetric(
            horizontal: (20 * scaleFactor).w,
            vertical: (16 * scaleFactor).h,
          ),
          itemCount: controller.ordersData.length,
          itemBuilder: (context, index) {
            final orderDetail = controller.ordersData[index];
            return buildOrderCard(
                context, controller, orderDetail, index, scaleFactor);
          },
        ),
      );
    });
  }

  Widget buildOrderCard(BuildContext context, ReadyOrderController controller,
      OrderDetail orderDetail, int index, double scaleFactor) {
    final order = orderDetail.order;
    final items = orderDetail.items;
    final totalAmount = double.tryParse(orderDetail.finalAmount) ?? 0.0;
    final totalItems = controller.getTotalItemsCount(items);

    return Container(
      margin: EdgeInsets.only(bottom: (16 * scaleFactor).h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular((12 * scaleFactor).r),
        border: Border.all(color: Colors.green.withOpacity(0.3), width: 1),
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
                      'Order no. ${order.billNumber}',
                      style: GoogleFonts.inter(
                        fontSize: (16 * scaleFactor).sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    buildInfoChip('table no: ${order.tableNumber}', Icons.chair,
                        scaleFactor),
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
                Obx(() {
                  final isExpanded =
                      controller.expandedOrders.contains(order.hotelTableId);
                  final itemsToShow =
                      isExpanded ? items : items.take(2).toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...itemsToShow
                          .map((item) => buildItemSummary(item, scaleFactor)),
                      if (items.length > 2) ...[
                        Gap((4 * scaleFactor).h),
                        GestureDetector(
                          onTap: () => controller
                              .toggleOrderExpansion(order.hotelTableId),
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
              color: Colors.green[50],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular((12 * scaleFactor).r),
                bottomRight: Radius.circular((12 * scaleFactor).r),
              ),
            ),
            child: Column(
              children: [
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
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => null,
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              PhosphorIcons.bowlFood(PhosphorIconsStyle.bold),
                              size: (16 * scaleFactor).sp,
                            ),
                            Gap((6 * scaleFactor).w),
                            Text(
                              'Mark as Served',
                              style: GoogleFonts.inter(
                                fontSize: (13 * scaleFactor).sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildItemSummary(OrderItem item, double scaleFactor) {
    // Default to vegetarian if not specified in model
    final isVegetarian =
        true; // You can add this field to OrderItem model if needed

    return Padding(
      padding: EdgeInsets.only(bottom: (6 * scaleFactor).h),
      child: Row(
        children: [
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
          Expanded(
            child: Text(
              item.itemName,
              style: GoogleFonts.inter(
                fontSize: (13 * scaleFactor).sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: (6 * scaleFactor).w, vertical: (2 * scaleFactor).h),
            decoration: BoxDecoration(
              color: Colors.blue[500],
              borderRadius: BorderRadius.circular((3 * scaleFactor).r),
            ),
            child: Text(
              '${item.quantity}',
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
}

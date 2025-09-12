import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class DoneOrder extends StatelessWidget {
  const DoneOrder({super.key});

  @override
  Widget build(BuildContext context) {
    // Get scale factor based on screen size
    final double scaleFactor = MediaQuery.of(context).size.width / 375.0;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: EdgeInsets.all((16 * scaleFactor).w),
        child: Column(
          children: [
            // First completed order
            _buildCompletedOrderCard(
              context,
              scaleFactor,
              orderNumber: '1001',
              tableNumber: '5',
              items: [
                {'name': 'Margherita Pizza', 'quantity': 2, 'is_vegetarian': 1},
                {'name': 'Caesar Salad', 'quantity': 1, 'is_vegetarian': 1},
                {'name': 'Garlic Bread', 'quantity': 3, 'is_vegetarian': 1},
              ],
              totalAmount: 1250.0,
              completedTime: '2:30 PM',
            ),

            // Second completed order
            _buildCompletedOrderCard(
              context,
              scaleFactor,
              orderNumber: '1002',
              tableNumber: '12',
              items: [
                {'name': 'Chicken Biryani', 'quantity': 1, 'is_vegetarian': 0},
                {'name': 'Butter Chicken', 'quantity': 2, 'is_vegetarian': 0},
                {'name': 'Naan Bread', 'quantity': 4, 'is_vegetarian': 1},
                {'name': 'Raita', 'quantity': 2, 'is_vegetarian': 1},
                {'name': 'Papad', 'quantity': 3, 'is_vegetarian': 1},
              ],
              totalAmount: 2150.0,
              completedTime: '1:45 PM',
            ),

            // Third completed order
            _buildCompletedOrderCard(
              context,
              scaleFactor,
              orderNumber: '1003',
              tableNumber: '8',
              items: [
                {'name': 'Pasta Carbonara', 'quantity': 1, 'is_vegetarian': 0},
                {'name': 'Cappuccino', 'quantity': 2, 'is_vegetarian': 1},
              ],
              totalAmount: 850.0,
              completedTime: '12:15 PM',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedOrderCard(
      BuildContext context,
      double scaleFactor, {
        required String orderNumber,
        required String tableNumber,
        required List<Map<String, dynamic>> items,
        required double totalAmount,
        required String completedTime,
      }) {
    // final totalItems = items.fold<int>(0, (sum, item) => sum + (item['quantity'] ?? 0));

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
          // Order Header with completed status
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
                    Gap((4 * scaleFactor).h),
                    Row(
                      children: [
                        Icon(
                          PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                          size: (14 * scaleFactor).sp,
                          color: Colors.green[600],
                        ),
                        Gap((4 * scaleFactor).w),
                        Text(
                          'Completed at $completedTime',
                          style: GoogleFonts.inter(
                            fontSize: (12 * scaleFactor).sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.green[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    _buildInfoChip('table no: $tableNumber', Icons.chair, scaleFactor),
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

                // Show first 2 items by default
                ...items.take(2).map((item) => _buildItemSummary(item, scaleFactor)),

                // Show expand button if more than 2 items
                if (items.length > 2) ...[
                  Gap((4 * scaleFactor).h),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: (4 * scaleFactor).h),
                    child: Text(
                      '+${items.length - 2} more items',
                      style: GoogleFonts.inter(
                        fontSize: (12 * scaleFactor).sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          Gap((16 * scaleFactor).h),

          // Order Summary - Completed Status
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
                // Total Summary
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Items: ',
                      style: GoogleFonts.inter(
                        fontSize: (14 * scaleFactor).sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      '₹${totalAmount.toStringAsFixed(0)}',
                      style: GoogleFonts.inter(
                        fontSize: (16 * scaleFactor).sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.green[600],
                      ),
                    ),
                  ],
                ),
                Gap((16 * scaleFactor).h),

                // Completed Status Badge
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: (12 * scaleFactor).h),
                  decoration: BoxDecoration(
                    color: Colors.green[600],
                    borderRadius: BorderRadius.circular((8 * scaleFactor).r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                        size: (16 * scaleFactor).sp,
                        color: Colors.white,
                      ),
                      Gap((6 * scaleFactor).w),
                      Text(
                        'Order Completed',
                        style: GoogleFonts.inter(
                          fontSize: (14 * scaleFactor).sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
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
              color: Colors.green[500], // Changed to green for completed orders
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
}
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class TableCardWidget extends StatelessWidget {
  final int tableNumber;
  final int price;
  final int time;
  final bool isOccupied;
  final VoidCallback onTap;

  const TableCardWidget({
    super.key,
    required this.tableNumber,
    required this.price,
    required this.time,
    required this.isOccupied,
    required this.onTap,
    required id,
  });

  @override
  Widget build(BuildContext context) {
    // Determine card color based on occupancy status
    Color cardColor;
    if (isOccupied) {
      if (price > 0) {
        cardColor = const Color(0xFFFF9999); // Light red for occupied with order
      } else {
        cardColor = const Color(0xFFFFB3B3); // Slightly different red shade
      }
    } else {
      cardColor = const Color(0xFF99FF99); // Light green for empty
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(8.r),
        ),
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Table number
            Text(
              tableNumber.toString(),
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),

            Gap(8.h),

            // Price
            Text(
              price > 0 ? '₹ $price' : '₹ 00',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            Gap(4.h),

            // Time
            Text(
              'time:$time',
              style: TextStyle(
                fontSize: 8.sp,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
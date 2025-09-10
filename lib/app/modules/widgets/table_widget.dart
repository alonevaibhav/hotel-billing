// lib/features/take_orders/views/widgets/table_card_widget.dart
import 'package:flutter/material.dart';
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
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Table number
            Text(
              tableNumber.toString(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),

            Gap(8),

            // Price
            Text(
              price > 0 ? '₹ $price' : '₹ 00',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),

            Gap(4),

            // Time
            Text(
              'time:$time',
              style: const TextStyle(
                fontSize: 12,
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
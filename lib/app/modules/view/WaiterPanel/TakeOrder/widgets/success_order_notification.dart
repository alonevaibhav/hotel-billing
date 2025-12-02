import 'dart:developer' as developer;
import '../../../../../core/services/notification_service.dart';

/// Show notification for successful order
Future<void> showOrderNotification({
  required int orderId,
  required String tableNumber,
  required int itemCount,
  required bool isNewOrder,
}) async {
  try {
    final notificationService = NotificationService.instance;

    final title = isNewOrder
        ? '🎉 Order Placed Successfully'
        : '✅ Items Added to Order';

    final body = isNewOrder
        ? 'Order Placed for Table $tableNumber with $itemCount ${itemCount == 1 ? 'item' : 'items'}'
        : '$itemCount new ${itemCount == 1 ? 'item' : 'items'} added (Table $tableNumber)';

    final bigText = isNewOrder
        ? 'Your order has been successfully placed for Table $tableNumber. Total items: $itemCount. The kitchen has been notified and will start preparing your order shortly.'
        : 'Successfully added $itemCount new ${itemCount == 1 ? 'item' : 'items'}  for Table $tableNumber. The kitchen has been notified about the additional items.';

    await notificationService.showBigTextNotification(
      title: title,
      body: body,
      bigText: bigText,
      payload: 'order_$orderId',
      priority: NotificationPriority.high,
    );

    developer.log(
      'Notification shown for order #$orderId',
      name: 'ORDER_NOTIFICATION',
    );
  } catch (e) {
    developer.log(
      'Failed to show notification: $e',
      name: 'ORDER_NOTIFICATION',
    );
    // Don't throw - notification failure shouldn't break the order flow
  }
}

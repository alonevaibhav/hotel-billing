import 'dart:developer' as developer;
import '../../core/services/notification_service.dart';

final notificationService = NotificationService.instance;

Future<void> showOrderNotification({
  required int orderId,
  required String tableNumber,
  required int itemCount,
  required bool isNewOrder,
}) async {
  try {

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



Future<void> showReadyToServeNotification(int orderId, String tableNumber) async {
  try {
    await notificationService.showBigTextNotification(
      title: '🍽️ Order Ready to Serve',
      body: 'Order #$orderId is ready for Table $tableNumber',
      bigText: 'The kitchen has finished preparing Order #$orderId for Table $tableNumber. Please serve the order to the customer.',
      payload: 'ready_order_$orderId',
      priority: NotificationPriority.high,
    );

    developer.log(
      'Ready to serve notification shown for order #$orderId',
      name: 'ReadyOrders.Notification',
    );
  } catch (e) {
    developer.log(
      'Failed to show ready notification: $e',
      name: 'ReadyOrders.Notification',
    );
  }
}

Future<void> showOrderServedNotification(int orderId, String tableNumber) async {
  try {
    await notificationService.showBigTextNotification(
      title: '✅ Order Served',
      body: 'Order #$orderId served to Table $tableNumber',
      bigText: 'Order #$orderId has been successfully served to Table $tableNumber. The order is now marked as served.',
      payload: 'served_order_$orderId',
    );

    developer.log(
      'Order served notification shown for order #$orderId',
      name: 'ReadyOrders.Notification',
    );
  } catch (e) {
    developer.log(
      'Failed to show served notification: $e',
      name: 'ReadyOrders.Notification',
    );
  }
}

Future<void> showOrderCompletedNotification(int orderId, String tableNumber) async {
  try {
    await notificationService.showBigTextNotification(
      title: '🎉 Order Completed',
      body: 'Order #$orderId completed for Table $tableNumber',
      bigText: 'Order #$orderId for Table $tableNumber has been completed. Thank you for your service!',
      payload: 'completed_order_$orderId',
      priority: NotificationPriority.low,
    );

    developer.log(
      'Order completed notification shown for order #$orderId',
      name: 'ReadyOrders.Notification',
    );
  } catch (e) {
    developer.log(
      'Failed to show completed notification: $e',
      name: 'ReadyOrders.Notification',
    );
  }
}
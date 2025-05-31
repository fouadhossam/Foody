import 'package:flutter/material.dart';
import '../models/order.dart';

class OrderTrackingTimeline extends StatelessWidget {
  final Order order;
  final bool isActive;

  const OrderTrackingTimeline({
    Key? key,
    required this.order,
    this.isActive = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final steps = [
      _TrackingStep(
        status: OrderStatus.pending,
        title: 'Order Placed',
        description: 'Your order has been received',
        icon: Icons.shopping_cart_outlined,
      ),
      _TrackingStep(
        status: OrderStatus.confirmed,
        title: 'Order Confirmed',
        description: 'Restaurant has confirmed your order',
        icon: Icons.check_circle_outline,
      ),
      _TrackingStep(
        status: OrderStatus.preparing,
        title: 'Preparing',
        description: 'Your food is being prepared',
        icon: Icons.restaurant_outlined,
      ),
      _TrackingStep(
        status: OrderStatus.ready,
        title: 'Ready for Delivery',
        description: 'Your order is ready for pickup',
        icon: Icons.delivery_dining_outlined,
      ),
      _TrackingStep(
        status: OrderStatus.delivered,
        title: 'Delivered',
        description: 'Order has been delivered',
        icon: Icons.home_outlined,
      ),
    ];

    // Find the current step index
    final currentStepIndex = steps.indexWhere(
      (step) => step.status == order.status,
    );

    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isCompleted = index < currentStepIndex;
        final isCurrent = index == currentStepIndex;
        final isUpcoming = index > currentStepIndex;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline line
            SizedBox(
              width: 24,
              child: Column(
                children: [
                  // Top line
                  if (index > 0)
                    Container(
                      width: 2,
                      height: 24,
                      color: isCompleted
                          ? Colors.green
                          : Colors.grey.withOpacity(0.3),
                    ),
                  // Icon
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? Colors.green
                          : isCurrent
                              ? Colors.deepOrange
                              : Colors.grey.withOpacity(0.3),
                    ),
                    child: Icon(
                      step.icon,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                  // Bottom line
                  if (index < steps.length - 1)
                    Container(
                      width: 2,
                      height: 24,
                      color: isCompleted
                          ? Colors.green
                          : Colors.grey.withOpacity(0.3),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Step content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isCurrent
                            ? Colors.deepOrange
                            : isCompleted
                                ? Colors.green
                                : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step.description,
                      style: TextStyle(
                        color: isUpcoming
                            ? Colors.grey.withOpacity(0.7)
                            : Colors.grey[600],
                      ),
                    ),
                    if (isCurrent && order.status != OrderStatus.delivered) ...[
                      const SizedBox(height: 8),
                      Text(
                        _getEstimatedTime(order.status),
                        style: const TextStyle(
                          color: Colors.deepOrange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  String _getEstimatedTime(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Estimated confirmation time: 2-3 minutes';
      case OrderStatus.confirmed:
        return 'Estimated preparation time: 15-20 minutes';
      case OrderStatus.preparing:
        return 'Estimated ready time: 10-15 minutes';
      case OrderStatus.ready:
        return 'Estimated delivery time: 20-30 minutes';
      default:
        return '';
    }
  }
}

class _TrackingStep {
  final OrderStatus status;
  final String title;
  final String description;
  final IconData icon;

  const _TrackingStep({
    required this.status,
    required this.title,
    required this.description,
    required this.icon,
  });
} 
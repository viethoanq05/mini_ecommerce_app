import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/order.dart';
import '../providers/checkout_provider.dart';
import '../screens/order_detail_screen.dart';
import '../utils/formatters.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  static const _tabs = [
    _OrderHistoryTab(label: 'Chờ xác nhận', status: OrderStatus.pending),
    _OrderHistoryTab(label: 'Đang giao', status: OrderStatus.delivering),
    _OrderHistoryTab(label: 'Đã giao', status: OrderStatus.delivered),
    _OrderHistoryTab(label: 'Đã hủy', status: OrderStatus.canceled),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Đơn mua'),
          bottom: TabBar(
            isScrollable: true,
            tabs: _tabs.map((tab) => Tab(text: tab.label)).toList(),
          ),
        ),
        body: TabBarView(
          children: _tabs.map((tab) => _OrderHistoryTabView(status: tab.status)).toList(),
        ),
      ),
    );
  }
}

class _OrderHistoryTab {
  const _OrderHistoryTab({required this.label, required this.status});

  final String label;
  final OrderStatus status;
}

class _OrderHistoryTabView extends StatelessWidget {
  const _OrderHistoryTabView({required this.status});

  final OrderStatus status;

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year} ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final orderHistory = context.watch<CheckoutProvider>().orderHistory;
    final orders = orderHistory.where((o) => o.status == status).toList();

    if (orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.history, size: 56, color: Colors.grey),
              const SizedBox(height: 12),
              const Text(
                'Chưa có đơn hàng nào trong mục này.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Bạn có thể quay lại trang chủ để tiếp tục mua sắm.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final order = orders[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          title: Text('Đơn #${order.id}'),
          subtitle: Text(_formatDate(order.createdAt)),
          trailing: Text(
            formatCurrency(order.total, 'VND'),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => OrderDetailScreen(order: order),
              ),
            );
          },
        );
      },
    );
  }
}

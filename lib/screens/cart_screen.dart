import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/cart_provider.dart';
import '../utils/formatters.dart';
import '../models/cart_item.dart';
import '../widgets/cart/cart_item_card.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final isLarge = width > 700;
    final horizontalPadding = isLarge ? (width - 700) / 2 + 16 : 16.0;
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Giỏ hàng',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: isLarge,
        actions: [
          if (cartProvider.items.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(right: isLarge ? horizontalPadding - 8 : 8),
              child: TextButton(
                onPressed: () => cartProvider.clearCart(),
                child: const Text('Xóa tất cả', style: TextStyle(color: Colors.red)),
              ),
            ),
        ],
      ),
      body: cartProvider.items.isEmpty
          ? _buildEmptyCart(context)
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(
                      isLarge ? horizontalPadding : 0,
                      8,
                      isLarge ? horizontalPadding : 0,
                      8,
                    ),
                    itemCount: cartProvider.items.length,
                    itemBuilder: (context, index) {
                      final item = cartProvider.items[index];
                      return CartItemCard(
                        item: item,
                        onToggleSelection: () => cartProvider.toggleSelection(item),
                        onIncrement: () => cartProvider.updateQuantity(item, 1),
                        onDecrement: () {
                          if (item.quantity <= 1) {
                            _showDeleteConfirmation(context, cartProvider, item);
                          } else {
                            cartProvider.updateQuantity(item, -1);
                          }
                        },
                        onRemove: () => cartProvider.removeItem(item),
                      );
                    },
                  ),
                ),
                _buildBottomBar(context, cartProvider, horizontalPadding),
              ],
            ),
    );
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    CartProvider provider,
    CartItem item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa sản phẩm?'),
        content: const Text('Bạn có chắc chắn muốn xóa sản phẩm này khỏi giỏ hàng?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      provider.removeItem(item);
    }
  }

  void _handlePurchase(BuildContext context, CartProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Đơn hàng thành công'),
          ],
        ),
        content: const Text('Cảm ơn bạn đã mua hàng tại TH4 Mobile!'),
        actions: [
          TextButton(
            onPressed: () {
              provider.clearCart();
              Navigator.pop(context);
            },
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            'Giỏ hàng của bạn đang trống',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Tiếp tục mua sắm'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    CartProvider provider,
    double horizontalPadding,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final width = MediaQuery.sizeOf(context).width;
    final isSmall = width < 360;

    return Container(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        12,
        horizontalPadding,
        12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Row(
              children: [
                SizedBox(
                  width: isSmall ? 24 : 40,
                  height: isSmall ? 24 : 40,
                  child: Checkbox(
                    value: provider.isSelectAll,
                    onChanged: (val) => provider.toggleSelectAll(val ?? false),
                    activeColor: colorScheme.primary,
                  ),
                ),
                Text(
                  'Tất cả',
                  style: TextStyle(fontSize: isSmall ? 12 : 14),
                ),
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Tổng thanh toán:',
                  style: TextStyle(fontSize: isSmall ? 11 : 13),
                ),
                Text(
                  formatCurrency(provider.totalAmount, 'VND'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: isSmall ? 14 : null,
                  ),
                ),
              ],
            ),
            SizedBox(width: isSmall ? 8 : 16),
            ElevatedButton(
              onPressed: provider.totalAmount > 0 ? () => _handlePurchase(context, provider) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isSmall ? 12 : 24,
                  vertical: isSmall ? 8 : 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Mua hàng',
                style: TextStyle(fontSize: isSmall ? 13 : 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

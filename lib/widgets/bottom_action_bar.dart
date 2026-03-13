import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';

class BottomActionBar extends StatelessWidget {
  final int cartCount;
  final GlobalKey cartIconKey;
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;

  const BottomActionBar({
    super.key,
    required this.cartCount,
    required this.cartIconKey,
    required this.onAddToCart,
    required this.onBuyNow,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(8, 8, 8, 8 + bottomInset),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 14,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            _iconButton(Icons.chat_bubble_outline_rounded, 'Chat', () {}),
            _cartButton(),
            const SizedBox(width: 8),
            Expanded(
              child: _actionButton(
                title: 'Thêm vào giỏ',
                color: const Color(0xFFFF8A34),
                onTap: onAddToCart,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _actionButton(
                title: 'Mua ngay',
                color: const Color(0xFFEE4D2D),
                onTap: onBuyNow,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconButton(IconData icon, String label, VoidCallback onTap) {
    return SizedBox(
      width: 58,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22),
            Text(label, style: const TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _cartButton() {
    return SizedBox(
      width: 58,
      child: InkWell(
        onTap: () {},
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            badges.Badge(
              showBadge: cartCount > 0,
              badgeContent: Text(
                '$cartCount',
                style: const TextStyle(color: Colors.white, fontSize: 9),
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                key: cartIconKey,
                size: 22,
              ),
            ),
            const Text('Cart', style: TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

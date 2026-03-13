import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../controllers/cart_controller.dart';
import 'quantity_selector.dart';

/// Loại hành động khi xác nhận trong BottomSheet.
enum BottomSheetAction { addToCart, buyNow }

/// BottomSheet chọn phân loại (size, màu) và số lượng trước khi thêm vào giỏ.
class VariationBottomSheet extends StatefulWidget {
  final Product product;
  final BottomSheetAction action;

  const VariationBottomSheet({
    super.key,
    required this.product,
    required this.action,
  });

  @override
  State<VariationBottomSheet> createState() => _VariationBottomSheetState();
}

class _VariationBottomSheetState extends State<VariationBottomSheet> {
  late String _selectedSize;
  late String _selectedColor;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _selectedSize = widget.product.sizes.first;
    _selectedColor = widget.product.colors.first;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Preview ảnh + giá ──────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      widget.product.images.first,
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 90,
                        height: 90,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatPrice(widget.product.price),
                          style: const TextStyle(
                            color: Color(0xFFEE4D2D),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Size: $_selectedSize  •  Màu: $_selectedColor',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.grey),
                  ),
                ],
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Divider(height: 1),
              ),

              // ── Chọn Size ─────────────────────────────────────────────
              const Text(
                'Chọn Size',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.product.sizes.map((size) {
                  final active = _selectedSize == size;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedSize = size),
                    child: _VariationChip(label: size, active: active),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // ── Chọn Màu ──────────────────────────────────────────────
              const Text(
                'Chọn Màu',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.product.colors.map((color) {
                  final active = _selectedColor == color;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: _VariationChip(label: color, active: active),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // ── Số lượng ──────────────────────────────────────────────
              Row(
                children: [
                  const Text(
                    'Số lượng',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  QuantitySelector(
                    quantity: _quantity,
                    onChanged: (value) => setState(() => _quantity = value),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Nút xác nhận ──────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEE4D2D),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    widget.action == BottomSheetAction.addToCart
                        ? 'Thêm Vào Giỏ Hàng'
                        : 'Mua Ngay',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onConfirm() {
    // Lưu tham chiếu trước khi pop để hiện SnackBar đúng context
    final scaffoldMsg = ScaffoldMessenger.of(context);
    context.read<CartController>().addToCart(
      widget.product,
      _selectedSize,
      _selectedColor,
      _quantity,
    );
    Navigator.pop(context);
    scaffoldMsg.showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Thêm vào giỏ hàng thành công!',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF27AE60),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatPrice(double price) {
    final str = price.toInt().toString();
    final buf = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write('.');
      buf.write(str[i]);
    }
    buf.write('đ');
    return buf.toString();
  }
}

/// Chip lựa chọn phân loại (size hoặc màu).
class _VariationChip extends StatelessWidget {
  final String label;
  final bool active;

  const _VariationChip({required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFFEE4D2D).withValues(alpha: 0.08)
            : Colors.white,
        border: Border.all(
          color: active ? const Color(0xFFEE4D2D) : Colors.grey.shade300,
          width: active ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? const Color(0xFFEE4D2D) : Colors.black87,
          fontWeight: active ? FontWeight.w600 : FontWeight.normal,
          fontSize: 13,
        ),
      ),
    );
  }
}

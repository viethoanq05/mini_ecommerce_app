import 'package:flutter/material.dart';

import '../models/product.dart';
import '../utils/formatters.dart';
import 'quantity_selector.dart';

/// BottomSheet để chọn phân loại hàng (size, màu) và số lượng trước khi thêm giỏ.
class VariationBottomSheet extends StatefulWidget {
  const VariationBottomSheet({
    super.key,
    required this.product,
    required this.onConfirm,
    required this.confirmLabel,
    this.initialVoucher,
    this.initialSize,
    this.initialColor,
  });

  final Product product;

  /// Callback khi xác nhận, trả về (size, màu, số lượng, voucher)
  final void Function(
    String size,
    String color,
    int quantity,
    ProductVoucher? voucher,
  ) onConfirm;

  /// Nhãn nút xác nhận, ví dụ 'Thêm vào giỏ' hoặc 'Mua ngay'
  final String confirmLabel;

  final ProductVoucher? initialVoucher;
  final String? initialSize;
  final String? initialColor;

  @override
  State<VariationBottomSheet> createState() => _VariationBottomSheetState();
}

class _VariationBottomSheetState extends State<VariationBottomSheet> {
  late String _selectedSize;
  late String _selectedColor;
  ProductVoucher? _selectedVoucher;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _selectedSize = widget.initialSize ??
        (widget.product.sizes.isNotEmpty ? widget.product.sizes.first : '');
    _selectedColor = widget.initialColor ??
        (widget.product.colors.isNotEmpty ? widget.product.colors.first : '');
    _selectedVoucher = widget.initialVoucher;
    _syncToAvailableVariant();
  }

  int get _currentStock =>
      widget.product.stockOf(_selectedSize, _selectedColor);

  double get _currentPrice =>
      widget.product.priceOf(_selectedSize, _selectedColor);

  double get _subtotal => _currentPrice * _quantity;

  double get _discount {
    if (_selectedVoucher == null) {
      return 0;
    }
    if (_subtotal < _selectedVoucher!.minOrderValue) {
      return 0;
    }
    return _selectedVoucher!.discountAmount;
  }

  double get _finalPrice => (_subtotal - _discount).clamp(0, double.infinity);

  void _syncToAvailableVariant() {
    if (_selectedSize.isEmpty || _selectedColor.isEmpty) {
      return;
    }

    if (_currentStock > 0) {
      if (_quantity > _currentStock) {
        _quantity = _currentStock;
      }
      return;
    }

    for (final color in widget.product.colors) {
      if (widget.product.stockOf(_selectedSize, color) > 0) {
        _selectedColor = color;
        _quantity = 1;
        return;
      }
    }

    for (final size in widget.product.sizes) {
      if (widget.product.stockOf(size, _selectedColor) > 0) {
        _selectedSize = size;
        _quantity = 1;
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final product = widget.product;
    final isOutOfStock = _currentStock <= 0;

    return Container(
      // Đảm bảo bottom sheet không bị keyboard che khuất
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Handle bar ────────────────────────────────────
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ── Ảnh + giá + phân loại đã chọn ────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    product.images.first,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 90,
                      height: 90,
                      color: const Color(0xFFF4E7DB),
                      child: const Icon(Icons.image_not_supported_outlined),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatCurrency(_currentPrice, 'VND'),
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: const Color(0xFFE03131),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (_selectedSize.isNotEmpty || _selectedColor.isNotEmpty)
                        Text(
                          [
                            if (_selectedSize.isNotEmpty) _selectedSize,
                            if (_selectedColor.isNotEmpty) _selectedColor,
                          ].join(' · '),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        isOutOfStock
                            ? 'Hết hàng'
                            : 'Còn $_currentStock sản phẩm',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isOutOfStock
                              ? const Color(0xFFC92A2A)
                              : const Color(0xFF2B8A3E),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Divider(height: 28),

            // ── Chọn Size ─────────────────────────────────────
            if (product.sizes.isNotEmpty) ...[
              Text(
                'Kích thước',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: product.sizes.map((size) {
                  final isAvailable = product.isSizeAvailableForColor(
                    size,
                    _selectedColor,
                  );
                  return _OptionChip(
                    label: size,
                    isSelected: size == _selectedSize,
                    isEnabled: isAvailable,
                    outOfStock: !isAvailable,
                    onTap: () {
                      setState(() {
                        _selectedSize = size;
                        _syncToAvailableVariant();
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
            ],

            // ── Chọn Màu sắc ──────────────────────────────────
            if (product.colors.isNotEmpty) ...[
              Text(
                'Màu sắc',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: product.colors.map((color) {
                  final isAvailable = product.isColorAvailableForSize(
                    color,
                    _selectedSize,
                  );
                  return _OptionChip(
                    label: color,
                    isSelected: color == _selectedColor,
                    isEnabled: isAvailable,
                    outOfStock: !isAvailable,
                    onTap: () {
                      setState(() {
                        _selectedColor = color;
                        _syncToAvailableVariant();
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
            ],

            if (product.vouchers.isNotEmpty) ...[
              Text(
                'Voucher',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: product.vouchers.map((voucher) {
                  final isSelected = _selectedVoucher?.id == voucher.id;
                  final meetsMin = _subtotal >= voucher.minOrderValue;
                  return _VoucherChip(
                    voucher: voucher,
                    isSelected: isSelected,
                    isEnabled: meetsMin,
                    onTap: () {
                      setState(() {
                        _selectedVoucher = isSelected ? null : voucher;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
            ],

            // ── Chọn số lượng ─────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Số lượng',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                QuantitySelector(
                  quantity: _quantity,
                  onIncrement: () {
                    if (_quantity < _currentStock) {
                      setState(() => _quantity++);
                    }
                  },
                  onDecrement: () {
                    if (_quantity > 1) setState(() => _quantity--);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                isOutOfStock
                    ? 'Sản phẩm đang hết hàng'
                    : 'Giới hạn tối đa: $_currentStock sản phẩm',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isOutOfStock
                      ? const Color(0xFFC92A2A)
                      : Colors.grey.shade600,
                ),
              ),
            ),

            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7F0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tạm tính',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    formatCurrency(_finalPrice, 'VND'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: const Color(0xFFE03131),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Nút xác nhận ──────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: isOutOfStock
                    ? null
                    : () => widget.onConfirm(
                          _selectedSize,
                          _selectedColor,
                          _quantity,
                          _selectedVoucher,
                        ),
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  widget.confirmLabel,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Chip tuỳ chọn (size hoặc màu) với hiệu ứng animated khi chọn
class _OptionChip extends StatelessWidget {
  const _OptionChip({
    required this.label,
    required this.isSelected,
    required this.isEnabled,
    required this.outOfStock,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final bool isEnabled;
  final bool outOfStock;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? primary : Colors.white,
          border: Border.all(
            color: isSelected
                ? primary
                : outOfStock
                    ? Colors.grey.shade300
                    : Colors.grey.shade400,
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          outOfStock ? '$label · Hết' : label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : outOfStock
                    ? Colors.grey.shade400
                    : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 13,
            decoration: outOfStock ? TextDecoration.lineThrough : null,
          ),
        ),
      ),
    );
  }
}

class _VoucherChip extends StatelessWidget {
  const _VoucherChip({
    required this.voucher,
    required this.isSelected,
    required this.isEnabled,
    required this.onTap,
  });

  final ProductVoucher voucher;
  final bool isSelected;
  final bool isEnabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primary : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? primary : Colors.grey.shade300,
          ),
        ),
        child: Text(
          voucher.title,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : isEnabled
                    ? Colors.black87
                    : Colors.grey.shade400,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

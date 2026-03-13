import 'package:flutter/material.dart';

/// Khối mô tả sản phẩm có thể mở rộng / thu gọn.
/// Mặc định hiện tối đa 5 dòng, bấm "Xem thêm" để đọc đầy đủ.
class ProductDescription extends StatefulWidget {
  final String description;

  const ProductDescription({super.key, required this.description});

  @override
  State<ProductDescription> createState() => _ProductDescriptionState();
}

class _ProductDescriptionState extends State<ProductDescription> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mô tả sản phẩm',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),

          // AnimatedCrossFade chuyển mượt giữa thu gọn / đầy đủ
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: Text(
              widget.description,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.65,
              ),
            ),
            secondChild: Text(
              widget.description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.65,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Nút Xem thêm / Thu gọn
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _expanded ? 'Thu gọn' : 'Xem thêm',
                  style: const TextStyle(
                    color: Color(0xFFEE4D2D),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: const Color(0xFFEE4D2D),
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

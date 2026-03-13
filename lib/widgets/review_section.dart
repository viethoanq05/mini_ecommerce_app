import 'package:flutter/material.dart';
import '../models/product.dart';

class ReviewSection extends StatelessWidget {
  final Product product;

  const ReviewSection({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final count = product.reviews.isEmpty ? 1 : product.reviews.length;
    final fiveStar = product.reviews.where((r) => r.rating >= 4.5).length;
    final fourStar = product.reviews
        .where((r) => r.rating >= 3.5 && r.rating < 4.5)
        .length;
    final threeStar = product.reviews
        .where((r) => r.rating >= 2.5 && r.rating < 3.5)
        .length;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Đánh giá sản phẩm',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '${product.rating.toStringAsFixed(1)} / 5',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFEE4D2D),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  children: [
                    _bar('5★', fiveStar, count),
                    _bar('4★', fourStar, count),
                    _bar('3★', threeStar, count),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...product.reviews
              .take(3)
              .map(
                (review) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ReviewTile(review: review),
                ),
              ),
        ],
      ),
    );
  }

  Widget _bar(String label, int value, int total) {
    final ratio = total == 0 ? 0.0 : value / total;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(label, style: const TextStyle(fontSize: 12)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                minHeight: 7,
                value: ratio,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation(Color(0xFFEE4D2D)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final ProductReview review;

  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: Colors.orange.shade100,
          child: Text(review.user.substring(0, 1).toUpperCase()),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                review.user,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    Icons.star_rounded,
                    size: 14,
                    color: index < review.rating.floor()
                        ? const Color(0xFFFFC107)
                        : Colors.grey.shade300,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                review.comment,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 2),
              Text(
                review.date,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

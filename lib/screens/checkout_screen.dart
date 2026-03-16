import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/cart_provider.dart';
import '../models/address.dart';
import '../providers/checkout_provider.dart';
import '../widgets/checkout_item_card.dart';
import '../widgets/order_summary.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _voucherController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final checkoutProvider = context.read<CheckoutProvider>();
      final cartProvider = context.read<CartProvider>();
      checkoutProvider.updateFromCartProvider(cartProvider);
      _voucherController.text = checkoutProvider.voucherCode ?? '';
    });
  }

  @override
  void dispose() {
    _voucherController.dispose();
    super.dispose();
  }

  Future<void> _showAddressPicker(BuildContext context) async {
    final checkoutProvider = context.read<CheckoutProvider>();

    final selected = await showModalBottomSheet<Address>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 14),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Chọn địa chỉ giao hàng',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
              const SizedBox(height: 12),
              ...checkoutProvider.availableAddresses.map(
                (address) => ListTile(
                  title: Text(address.name),
                  subtitle: Text(address.display),
                  trailing: checkoutProvider.selectedAddress?.id == address.id
                      ? const Icon(Icons.check, color: Color(0xFFE03131))
                      : null,
                  onTap: () {
                    Navigator.of(context).pop(address);
                  },
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add_location_alt),
                    label: const Text('Thêm địa chỉ mới'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE03131),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      final newAddress = await showDialog<Address>(
                        context: context,
                        builder: (context) {
                          final nameController = TextEditingController();
                          final phoneController = TextEditingController();
                          final addressLineController = TextEditingController();
                          final cityController = TextEditingController();
                          return AlertDialog(
                            title: const Text('Thêm địa chỉ mới'),
                            content: SingleChildScrollView(
                              child: Column(
                                children: [
                                  TextField(
                                    controller: nameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Tên người nhận',
                                    ),
                                  ),
                                  TextField(
                                    controller: phoneController,
                                    decoration: const InputDecoration(
                                      labelText: 'Số điện thoại',
                                    ),
                                    keyboardType: TextInputType.phone,
                                  ),
                                  TextField(
                                    controller: addressLineController,
                                    decoration: const InputDecoration(
                                      labelText: 'Địa chỉ',
                                    ),
                                  ),
                                  TextField(
                                    controller: cityController,
                                    decoration: const InputDecoration(
                                      labelText: 'Thành phố',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Hủy'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  if (nameController.text.isEmpty ||
                                      phoneController.text.isEmpty ||
                                      addressLineController.text.isEmpty ||
                                      cityController.text.isEmpty) {
                                    return;
                                  }
                                  final address = Address(
                                    id: 'addr_${DateTime.now().millisecondsSinceEpoch}',
                                    name: nameController.text,
                                    phone: phoneController.text,
                                    addressLine: addressLineController.text,
                                    city: cityController.text,
                                  );
                                  Navigator.of(context).pop(address);
                                },
                                child: const Text('Thêm'),
                              ),
                            ],
                          );
                        },
                      );
                      if (newAddress != null) {
                        checkoutProvider.addNewAddress(newAddress);
                        Navigator.of(context).pop(newAddress);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selected != null) {
      checkoutProvider.selectAddress(selected);
    }
  }

  Future<void> _onPlaceOrder(BuildContext context) async {
    final checkoutProvider = context.read<CheckoutProvider>();
    final cartProvider = context.read<CartProvider>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final order = await checkoutProvider.placeOrder(
        userId: 'user_1',
        cartProvider: cartProvider,
      );

      if (!mounted) return;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Đặt hàng thành công'),
          content: const Text('Đơn hàng của bạn đã được đặt thành công!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                navigator.popUntil((route) => route.isFirst);
              },
              child: const Text('Về trang chủ'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                navigator.push(
                  MaterialPageRoute(
                    builder: (_) => OrderSuccessScreen(order: order),
                  ),
                );
              },
              child: const Text('Xem chi tiết đơn hàng'),
            ),
          ],
        ),
      );
    } catch (e) {
      final message = checkoutProvider.errorMessage ?? e.toString();
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final checkoutProvider = context.watch<CheckoutProvider>();

    final isWide = MediaQuery.of(context).size.width >= 760;

    final cartItems = checkoutProvider.cartItems;

    Widget cartSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Giỏ hàng'),
        if (cartItems.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Column(
              children: [
                const Text('Giỏ hàng của bạn đang trống.'),
                const SizedBox(height: 10),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Quay về mua sắm'),
                ),
              ],
            ),
          )
        else
          ...cartItems.map((item) => CheckoutItemCard(item: item)),
      ],
    );

    Widget addressSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Địa chỉ giao hàng'),
        GestureDetector(
          onTap: () => _showAddressPicker(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFEAEAEA)),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (checkoutProvider.selectedAddress != null) ...[
                  Text(
                    checkoutProvider.selectedAddress!.display,
                    style: const TextStyle(fontSize: 14),
                  ),
                ] else ...[
                  const Text(
                    'Chưa có địa chỉ. Nhấn để chọn địa chỉ giao hàng.',
                    style: TextStyle(color: Color(0xFF6F6F6F)),
                  ),
                ],
                const SizedBox(height: 10),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Thay đổi địa chỉ',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFE03131),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 14),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );

    Widget shippingSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Phương thức vận chuyển'),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFEAEAEA)),
          ),
          child: Column(
            children: ShippingMethod.values.map((method) {
              final label = method == ShippingMethod.standard
                  ? 'Tiêu chuẩn'
                  : 'Nhanh (Express)';
              final subtitle = method == ShippingMethod.standard
                  ? 'Giao trong 3-5 ngày'
                  : 'Giao trong 1-2 ngày';
              return RadioListTile<ShippingMethod>(
                title: Text(label),
                subtitle: Text(subtitle),
                value: method,
                groupValue: checkoutProvider.shippingMethod,
                onChanged: (value) {
                  if (value != null) {
                    checkoutProvider.selectShippingMethod(value);
                  }
                },
              );
            }).toList(),
          ),
        ),
      ],
    );

    Widget paymentSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Phương thức thanh toán'),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFEAEAEA)),
          ),
          child: Column(
            children: PaymentMethod.values.map((method) {
              final label = method == PaymentMethod.cod
                  ? 'Thanh toán khi nhận hàng (COD)'
                  : 'Thanh toán trực tuyến';
              final subtitle = method == PaymentMethod.online
                  ? 'Tùy chọn placeholder cho thanh toán online.'
                  : null;
              return RadioListTile<PaymentMethod>(
                title: Text(label),
                subtitle: subtitle != null ? Text(subtitle) : null,
                value: method,
                groupValue: checkoutProvider.paymentMethod,
                onChanged: (value) {
                  if (value != null) {
                    checkoutProvider.selectPaymentMethod(value);
                  }
                },
              );
            }).toList(),
          ),
        ),
      ],
    );

    Widget voucherSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Voucher / mã giảm giá'),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _voucherController,
                decoration: const InputDecoration(
                  hintText: 'Nhập mã giảm giá',
                  border: OutlineInputBorder(),
                ),
                onChanged: checkoutProvider.updateVoucherCode,
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: () {
                  checkoutProvider.applyVoucher();
                  if (checkoutProvider.errorMessage != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(checkoutProvider.errorMessage!)),
                    );
                  }
                },
                child: const Text('Áp dụng'),
              ),
            ),
          ],
        ),
      ],
    );

    Widget summarySection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Tổng đơn hàng'),
        OrderSummary(
          subtotal: checkoutProvider.subtotal,
          shippingFee: checkoutProvider.shippingFee,
          discount: checkoutProvider.discount,
          total: checkoutProvider.total,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton(
            onPressed: cartItems.isEmpty || checkoutProvider.isPlacingOrder
                ? null
                : () => _onPlaceOrder(context),
            child: checkoutProvider.isPlacingOrder
                ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  )
                : const Text('Đặt hàng'),
          ),
        ),
      ],
    );

    final content = SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      cartSection,
                      const SizedBox(height: 12),
                      addressSection,
                      const SizedBox(height: 12),
                      shippingSection,
                      const SizedBox(height: 12),
                      paymentSection,
                      const SizedBox(height: 12),
                      voucherSection,
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [summarySection],
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                cartSection,
                const SizedBox(height: 12),
                addressSection,
                const SizedBox(height: 12),
                shippingSection,
                const SizedBox(height: 12),
                paymentSection,
                const SizedBox(height: 12),
                voucherSection,
                const SizedBox(height: 12),
                summarySection,
              ],
            ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán')),
      backgroundColor: const Color(0xFFF7F7F7),
      body: content,
    );
  }
}

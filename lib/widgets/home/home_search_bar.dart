import 'package:flutter/material.dart';

class HomeSearchBar extends StatefulWidget {
  const HomeSearchBar({
    super.key,
    required this.isCollapsed,
    required this.height,
    required this.onChanged,
    required this.query,
    this.onSubmitted,
  });

  final bool isCollapsed;
  final double height;
  final ValueChanged<String> onChanged;
  final String query;
  final ValueChanged<String>? onSubmitted;

  @override
  State<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<HomeSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.query);
  }

  @override
  void didUpdateWidget(covariant HomeSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.query != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.query,
        selection: TextSelection.collapsed(offset: widget.query.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCollapsed = widget.isCollapsed;
    final height = widget.height;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      height: height,
      decoration: BoxDecoration(
        color: isCollapsed
            ? Colors.white.withValues(alpha: 0.18)
            : Colors.white,
        borderRadius: BorderRadius.circular(height / 2),
        border: Border.all(
          color: isCollapsed
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: isCollapsed
            ? const []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
      ),
      child: Row(
        children: [
          SizedBox(width: height * 0.3),
          Icon(
            Icons.search_rounded,
            size: height * 0.5,
            color: isCollapsed
                ? Colors.white.withValues(alpha: 0.92)
                : const Color(0xFF7A5C4D),
          ),
          SizedBox(width: height * 0.22),
          Expanded(
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _controller,
              builder: (context, value, _) {
                return TextField(
                  controller: _controller,
                  onChanged: widget.onChanged,
                  onSubmitted: widget.onSubmitted,
                  textInputAction: TextInputAction.search,
                  textAlignVertical: TextAlignVertical.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isCollapsed
                        ? Colors.white.withValues(alpha: 0.96)
                        : const Color(0xFF3B2E29),
                    fontWeight: FontWeight.w500,
                  ),
                  cursorColor: isCollapsed
                      ? Colors.white
                      : const Color(0xFF7A5C4D),
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintText: 'Tìm đồ hot, deal sốc, voucher...',
                    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isCollapsed
                          ? Colors.white.withValues(alpha: 0.78)
                          : const Color(0xFF6B5B53),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (context, value, _) {
              final visible = value.text.isNotEmpty;
              return SizedBox(
                width: height * 0.9,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 160),
                  child: visible
                      ? IconButton(
                          key: const ValueKey('clearSearch'),
                          onPressed: () {
                            _controller.clear();
                            widget.onChanged('');
                          },
                          splashRadius: 18,
                          icon: Icon(
                            Icons.close_rounded,
                            size: height * 0.42,
                            color: isCollapsed
                                ? Colors.white.withValues(alpha: 0.92)
                                : const Color(0xFF7A5C4D),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              );
            },
          ),
          SizedBox(width: height * 0.08),
        ],
      ),
    );
  }
}

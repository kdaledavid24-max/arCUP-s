import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Smooth, continuously moving ticker marquee ribbon for cafe slogans and highlights.
class AnimatedMarquee extends StatefulWidget {
  final List<String> items;
  final double height;

  const AnimatedMarquee({
    super.key,
    required this.items,
    this.height = 36,
  });

  @override
  State<AnimatedMarquee> createState() => _AnimatedMarqueeState();
}

class _AnimatedMarqueeState extends State<AnimatedMarquee> {
  late final ScrollController _scrollController;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startMarqueeLoop();
    });
  }

  Future<void> _startMarqueeLoop() async {
    while (!_isDisposed && mounted) {
      if (_scrollController.hasClients) {
        final maxExtent = _scrollController.position.maxScrollExtent;
        if (maxExtent > 0) {
          final current = _scrollController.offset;
          final remaining = maxExtent - current;
          // ~30-35ms per pixel gives a relaxed, elegant cafe crawl speed
          final durationMs = (remaining * 35).clamp(1000, 120000).toInt();

          await _scrollController.animateTo(
            maxExtent,
            duration: Duration(milliseconds: durationMs),
            curve: Curves.linear,
          );

          if (!_isDisposed && mounted && _scrollController.hasClients) {
            _scrollController.jumpTo(0.0);
          }
        } else {
          await Future.delayed(const Duration(milliseconds: 400));
        }
      } else {
        await Future.delayed(const Duration(milliseconds: 200));
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildTickerItem(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.2,
            color: AppTheme.textMuted,
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            color: AppTheme.caramelAccent,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Repeat items multiple times to provide a seamless continuous stream
    final repeatedItems = [
      ...widget.items,
      ...widget.items,
      ...widget.items,
      ...widget.items,
    ];

    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0D1728),
        border: Border.symmetric(
          horizontal: BorderSide(
            color: AppTheme.cardBorder.withValues(alpha: 0.8),
          ),
        ),
      ),
      child: IgnorePointer(
        child: ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: repeatedItems.length,
          itemBuilder: (context, index) {
            return _buildTickerItem(repeatedItems[index]);
          },
        ),
      ),
    );
  }
}

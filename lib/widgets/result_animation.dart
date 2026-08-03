import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class ResultAnimation extends StatefulWidget {
  final int stars;
  final String performance;

  const ResultAnimation({
    super.key,
    required this.stars,
    required this.performance,
  });

  @override
  State<ResultAnimation> createState() => _ResultAnimationState();
}

class _ResultAnimationState extends State<ResultAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0, curve: Curves.easeIn)),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Icon(
                _getIcon(),
                size: 80,
                color: _getColor(),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Text(
                widget.performance,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: _getColor(),
                    ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Icon(
                    index < widget.stars ? Icons.star : Icons.star_border,
                    color: AppTheme.accentColor,
                    size: 36,
                  );
                }),
              ),
            );
          },
        ),
      ],
    );
  }

  IconData _getIcon() {
    if (widget.stars >= 3) return Icons.emoji_events;
    if (widget.stars >= 2) return Icons.sentiment_very_satisfied;
    if (widget.stars >= 1) return Icons.sentiment_satisfied;
    return Icons.sentiment_dissatisfied;
  }

  Color _getColor() {
    if (widget.stars >= 3) return AppTheme.accentColor;
    if (widget.stars >= 2) return AppTheme.correctGreen;
    if (widget.stars >= 1) return Colors.orange;
    return AppTheme.wrongRed;
  }
}

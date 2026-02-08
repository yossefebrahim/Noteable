import 'package:flutter/material.dart';

class EmptyState extends StatefulWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.inbox_outlined,
    this.action,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget? action;

  @override
  State<EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<EmptyState> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 64, color: Theme.of(context).hintColor),
              const SizedBox(height: 12),
              Text(widget.title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(widget.subtitle, style: Theme.of(context).textTheme.bodyMedium),
              if (widget.action != null) ...[const SizedBox(height: 16), widget.action!],
            ],
          ),
        ),
      ),
    );
  }
}

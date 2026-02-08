import 'dart:async';

import 'package:flutter/material.dart';

class EmptyState extends StatefulWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.inbox_outlined,
    this.action,
    this.tips,
    this.tipCycleDuration = const Duration(seconds: 6),
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget? action;
  final List<String>? tips;
  final Duration tipCycleDuration;

  @override
  State<EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<EmptyState> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // Tips cycling state
  int _currentTipIndex = 0;
  Timer? _tipTimer;
  late AnimationController _tipFadeController;
  late Animation<double> _tipFadeAnimation;

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

    _tipFadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _tipFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _tipFadeController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    _tipFadeController.forward();

    // Start tips cycling if tips are provided
    if (widget.tips != null && widget.tips!.isNotEmpty) {
      _startTipCycling();
    }
  }

  void _startTipCycling() {
    _tipTimer = Timer.periodic(widget.tipCycleDuration, (_) {
      if (mounted && widget.tips != null && widget.tips!.length > 1) {
        // Fade out
        _tipFadeController.reverse().then((_) {
          if (mounted) {
            setState(() {
              _currentTipIndex = (_currentTipIndex + 1) % widget.tips!.length;
            });
            // Fade in
            _tipFadeController.forward();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _tipTimer?.cancel();
    _tipFadeController.dispose();
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
              Text(
                widget.subtitle,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              if (widget.tips != null && widget.tips!.isNotEmpty) ...[
                const SizedBox(height: 16),
                FadeTransition(
                  opacity: _tipFadeAnimation,
                  child: _buildTip(context),
                ),
              ],
              if (widget.action != null) ...[const SizedBox(height: 16), widget.action!],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              widget.tips![_currentTipIndex],
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

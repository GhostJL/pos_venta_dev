import 'package:flutter/material.dart';

class ProductListSkeleton extends StatelessWidget {
  final bool isDesktop;

  const ProductListSkeleton({super.key, this.isDesktop = false});

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return _buildDesktopSkeleton(context);
    }
    return _buildMobileSkeleton(context);
  }

  Widget _buildDesktopSkeleton(BuildContext context) {
    final color = Theme.of(
      context,
    ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          _Box(width: 48, height: 48, color: color), // Photo
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Box(width: 150, height: 14, color: color),
                const SizedBox(height: 8),
                _Box(width: 80, height: 10, color: color),
              ],
            ),
          ),
          if (MediaQuery.of(context).size.width > 1100)
            Expanded(
              flex: 2,
              child: _Box(width: 100, height: 12, color: color),
            ),
          Expanded(flex: 2, child: _Box(width: 60, height: 14, color: color)),
          Expanded(flex: 2, child: _Box(width: 40, height: 12, color: color)),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildMobileSkeleton(BuildContext context) {
    final color = Theme.of(
      context,
    ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4);
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Box(width: 48, height: 48, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Box(width: double.infinity, height: 14, color: color),
                  const SizedBox(height: 8),
                  _Box(width: 100, height: 10, color: color),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _Box(width: 60, height: 14, color: color),
                      _Box(width: 40, height: 12, color: color),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Box extends StatelessWidget {
  final double width;
  final double height;
  final Color color;

  const _Box({required this.width, required this.height, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

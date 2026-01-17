import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class RightClickMenuWrapper extends StatelessWidget {
  final Widget child;
  final VoidCallback? onRightClick;
  final List<PopupMenuEntry<String>>? menuItems;
  final void Function(String)? onSelected;

  const RightClickMenuWrapper({
    super.key,
    required this.child,
    this.onRightClick,
    this.menuItems,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) async {
        if (event.kind == PointerDeviceKind.mouse &&
            event.buttons == kSecondaryMouseButton) {
          if (menuItems != null && menuItems!.isNotEmpty) {
            final overlay = Overlay.of(context).context.findRenderObject();
            if (overlay is! RenderBox) return;

            final position = RelativeRect.fromRect(
              Rect.fromPoints(event.position, event.position),
              Offset.zero & overlay.size,
            );

            final value = await showMenu<String>(
              context: context,
              position: position,
              items: menuItems!,
            );

            if (value != null && onSelected != null) {
              onSelected!(value);
            }
          } else if (onRightClick != null) {
            onRightClick!();
          }
        }
      },
      child: child,
    );
  }
}

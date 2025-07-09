import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_toolkit_app/view_model/selected_index_provider.dart';

class NavItemWidget extends ConsumerWidget {
  final String iconPath;
  final String label;
  final int index;

  const NavItemWidget({
    super.key,
    required this.iconPath,
    required this.label,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedIndexProvider);
    final isActive = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        ref.read(selectedIndexProvider.notifier).state = index;
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ImageIcon(
            AssetImage(iconPath),
            size: 24,
            color: isActive ? Colors.green : Colors.black54,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.green : Colors.black54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

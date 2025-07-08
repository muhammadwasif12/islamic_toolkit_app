import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_toolkit_app/view_model/selected_index_provider.dart';

class NavItemWidget extends ConsumerWidget {
  final IconData icon;
  final String label;
  final int index;

  const NavItemWidget({
    super.key,
    required this.icon,
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

        switch (index) {
          case 0:
            Navigator.pushNamed(context, '/home');
            break;
          case 1:
            Navigator.pushNamed(context, '/qibla');
            break;
          case 2:
            Navigator.pushNamed(context, '/duas');
            break;
          case 3:
            Navigator.pushNamed(context, '/counter');
            break;
          case 4:
            Navigator.pushNamed(context, '/settings');
            break;
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? Colors.green : Colors.white54),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.green : Colors.white54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

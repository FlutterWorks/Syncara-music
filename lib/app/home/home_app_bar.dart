import 'package:flutter/material.dart';
import 'package:tubesync/app/app_theme.dart';
import 'package:tubesync/app/home/avatar.dart';
import 'package:window_manager/window_manager.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return DragToMoveArea(
      child: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(12),
          child: Image.asset(
            "assets/tubesync.png",
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        titleSpacing: 0,
        title: const Text("TubeSync"),
        actions: [
          if (!AppTheme.isDesktop) ...{
            Avatar(),
            SizedBox(width: 12),
          } else ...{
            IconButton(
              tooltip: "Minimize",
              onPressed: WindowManager.instance.minimize,
              icon: Icon(Icons.horizontal_rule_rounded),
            ),
            IconButton(
              tooltip: "Close",
              onPressed: WindowManager.instance.close,
              icon: Icon(Icons.close_rounded),
            ),
            SizedBox(width: 12),
          }
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

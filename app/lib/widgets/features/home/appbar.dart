import 'package:flutter/material.dart';
import 'package:melotune/utils/colors.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: KColors.appPrimary,
      title: const Text("MeloTune", style: TextStyle(color: Colors.white)),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: () => Scaffold.of(context).openEndDrawer(),
          icon: const Icon(
            Icons.menu,
            color: Colors.white,
            size: 34,
          ),
        ),
        const SizedBox(width: 22)
      ],
    );
  }
}

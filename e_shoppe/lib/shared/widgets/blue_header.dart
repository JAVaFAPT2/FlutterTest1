import 'package:flutter/material.dart';

import 'package:e_shoppe/theme/app_theme.dart';

class BlueHeader extends StatelessWidget implements PreferredSizeWidget {
  const BlueHeader({
    super.key,
    this.title,
    this.leading,
    this.trailing,
    this.height = 60,
  });

  final Widget? leading;
  final Widget? trailing;
  final String? title;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: AppColors.cyan,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SafeArea(
        bottom: false,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (leading != null)
              Align(alignment: Alignment.centerLeft, child: leading!),
            if (title != null)
              Center(
                  child: Text(title!,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold))),
            if (trailing != null)
              Align(alignment: Alignment.centerRight, child: trailing!),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: context.colors.onSurfaceVariant,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
    );
  }
}

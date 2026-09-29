import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final double borderRadius;
  final bool showGlow;
  final bool showShadow;

  const AppLogo({
    super.key,
    this.size = 48,
    this.borderRadius = 12,
    this.showGlow = false,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          if (showShadow)
            BoxShadow(
              color: const Color(0xFF0284C7).withAlpha(showGlow ? 80 : 30),
              blurRadius: showGlow ? 20 : 8,
              spreadRadius: showGlow ? 2 : 0,
              offset: const Offset(0, 2),
            ),
          if (showShadow)
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.asset(
          'assets/images/app_logo.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: Icon(
                Icons.tsunami_rounded,
                color: Colors.white,
                size: size * 0.55,
              ),
            );
          },
        ),
      ),
    );
  }
}

/// A branded logo row with text, used in the AppBar and Drawer header
class AppLogoWithTitle extends StatelessWidget {
  final double logoSize;
  final double titleFontSize;
  final double subtitleFontSize;
  final bool showSubtitle;
  final Color? titleColor;
  final Color? subtitleColor;

  const AppLogoWithTitle({
    super.key,
    this.logoSize = 34,
    this.titleFontSize = 17,
    this.subtitleFontSize = 11,
    this.showSubtitle = false,
    this.titleColor,
    this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = titleColor ?? const Color(0xFF0F172A);
    final textSecondary = subtitleColor ?? const Color(0xFF64748B);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppLogo(
          size: logoSize,
          borderRadius: logoSize * 0.22,
          showShadow: true,
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'FLUVIA',
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                color: textPrimary,
                height: 1.1,
              ),
            ),
            if (showSubtitle)
              Text(
                'Flash Flood Intelligence',
                style: TextStyle(
                  fontSize: subtitleFontSize,
                  fontWeight: FontWeight.w500,
                  color: textSecondary,
                  letterSpacing: -0.1,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

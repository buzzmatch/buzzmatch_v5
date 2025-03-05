import 'package:buzzmatch_v5/app/theme/app_colors.dart';
import 'package:buzzmatch_v5/app/theme/app_text.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class HexagonButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color color;
  final Color textColor;
  final double size;
  final bool isSelected;

  const HexagonButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.color = AppColors.honeycombMedium,
    this.textColor = Colors.white,
    this.size = 120.0,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomPaint(
            size: Size(
                size, size * 0.866), // Height is approximately width * √3/2
            painter: HexagonPainter(
              color: color,
              isSelected: isSelected,
              strokeColor:
                  isSelected ? AppColors.honeycombBrown : Colors.transparent,
              strokeWidth: isSelected ? 2.0 : 0.0,
            ),
            child: Container(
              width: size,
              height: size * 0.866,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null)
                    Icon(
                      icon,
                      color: textColor,
                      size: size / 4,
                    ),
                  if (icon != null) const SizedBox(height: 8),
                  Text(
                    text,
                    textAlign: TextAlign.center,
                    style: AppText.withColor(
                      icon != null ? AppText.body2 : AppText.button,
                      textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HexagonPainter extends CustomPainter {
  final Color color;
  final Color strokeColor;
  final double strokeWidth;
  final bool isSelected;

  HexagonPainter({
    required this.color,
    this.strokeColor = Colors.transparent,
    this.strokeWidth = 0.0,
    this.isSelected = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = _createHexagonPath(size);

    // Apply honeycomb gradient
    final Paint gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isSelected
            ? [
                AppColors.honeycombLight,
                AppColors.honeycombMedium,
                AppColors.honeycombDark
              ]
            : [
                AppColors.honeycombMedium.withOpacity(0.9),
                AppColors.honeycombDark
              ],
        stops: isSelected ? [0.0, 0.5, 1.0] : [0.3, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // For selected state, add a subtle glow effect
    if (isSelected) {
      final Paint glowPaint = Paint()
        ..color = AppColors.honeycombLight.withOpacity(0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      // Draw a slightly larger path for the glow
      final Path glowPath =
          _createHexagonPath(Size(size.width * 1.05, size.height * 1.05));
      canvas.drawPath(glowPath, glowPaint);
    }

    // Draw the main hexagon
    canvas.drawPath(path, gradientPaint);

    // Add honeycomb texture effect
    _drawHoneycombTexture(canvas, path, size);

    // Add inner shadow for depth
    _drawInnerShadow(canvas, path, size);

    // Draw stroke if needed
    if (strokeWidth > 0) {
      final Paint strokePaint = Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;

      canvas.drawPath(path, strokePaint);
    }

    // Add a small honey drip effect for selected buttons
    if (isSelected) {
      _drawHoneyDrip(canvas, size);
    }
  }

  void _drawHoneycombTexture(Canvas canvas, Path path, Size size) {
    // Create a clip to keep the texture within the hexagon
    canvas.save();
    canvas.clipPath(path);

    final Paint texturePaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Draw simple texture lines
    final random = math.Random(12); // Fixed seed for consistent pattern
    for (int i = 0; i < 10; i++) {
      final double startX = random.nextDouble() * size.width;
      final double startY = random.nextDouble() * size.height;
      final double endX = startX + random.nextDouble() * 20 - 10;
      final double endY = startY + random.nextDouble() * 20 - 10;

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        texturePaint,
      );
    }

    canvas.restore();
  }

  void _drawInnerShadow(Canvas canvas, Path path, Size size) {
    // Create a subtle inner shadow for depth
    canvas.save();
    canvas.clipPath(path);

    // Top-left to bottom-right inner shadow gradient
    final Paint shadowPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.2),
          Colors.black.withOpacity(0.1),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Draw a smaller hexagon path for inner shadow
    final Path innerPath =
        _createHexagonPath(Size(size.width * 0.95, size.height * 0.95));

    canvas.drawPath(innerPath, shadowPaint);
    canvas.restore();
  }

  void _drawHoneyDrip(Canvas canvas, Size size) {
    // Draw a small honey drip at the bottom of the hexagon
    final double centerX = size.width / 2;
    final double bottomY = size.height;

    final Path dripPath = Path()
      ..moveTo(centerX - 5, bottomY - 2)
      ..quadraticBezierTo(centerX, bottomY + 15, centerX + 5, bottomY - 2);

    final Paint dripPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.honeycombMedium,
          AppColors.honeycombDark,
        ],
      ).createShader(Rect.fromLTWH(centerX - 5, bottomY - 2, 10, 17));

    canvas.drawPath(dripPath, dripPaint);

    // Add a highlight to the drip
    final Paint highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(centerX - 2, bottomY),
      Offset(centerX - 1, bottomY + 8),
      highlightPaint,
    );
  }

  Path _createHexagonPath(Size size) {
    final double width = size.width;
    final double height = size.height;
    final double centerX = width / 2;
    final double centerY = height / 2;
    final double radius = width / 2;

    final Path path = Path();

    // Calculate the points of the hexagon
    for (int i = 0; i < 6; i++) {
      final double angle = (i * 60.0 - 30.0) *
          (math.pi / 180.0); // Convert to radians and offset by 30 degrees
      final double x = centerX +
          radius *
              0.95 *
              math.cos(angle); // 0.95 to slightly shrink the hexagon
      final double y = centerY + radius * 0.95 * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(HexagonPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeColor != strokeColor ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.isSelected != isSelected;
  }
}

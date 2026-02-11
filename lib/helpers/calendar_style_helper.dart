import 'package:flutter/material.dart';
import 'dart:math';

/// Helper class for Calendar UI Styling — Zen Modernity Theme
class CalendarStyleHelper {
  // === COLORS ===
  static const Color primaryColor = Color(0xFF2E5C55);     // Jade Green (Ngọc Bích)
  static const Color accentColor = Color(0xFFC5A059);      // Antique Gold (Vàng Cổ)
  static const Color goldShimmer = Color(0xFFD4AF37);      // Gold Shimmer
  static const Color backgroundColor = Color(0xFFF7F5F0);  // Warm Paper (Giấy Dó)
  static const Color lunarTextColor = Color(0xFF718096);    // Slate Grey
  static const Color eventMarkerColor = Color(0xFFE53935); // Imperial Red

  // === SHADOWS ===
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Color(0xFF2E5C55).withOpacity(0.08),
      blurRadius: 20,
      offset: Offset(0, 8),
      spreadRadius: -2,
    ),
  ];

  static List<BoxShadow> goldShadow = [
    BoxShadow(
      color: accentColor.withOpacity(0.25),
      blurRadius: 15,
      offset: Offset(0, 4),
    ),
  ];

  // --- COLORS (Tet Theme additions) ---
  static const Color tetRed = Color(0xFFD32F2F);
  static const Color tetGold = Color(0xFFFFD700);
  static const List<Color> tetGradient = [Color(0xFFD32F2F), Color(0xFFFFC107)];
  static const List<Color> tetBackgroundGradient = [Color(0xFFFFF5F5), Color(0xFFFFEBEE)]; // Nền đỏ rất nhạt

  // --- SHADOWS ---
  static List<BoxShadow> get defaultShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ];

  static List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 16,
      offset: Offset(0, 6),
      spreadRadius: -2,
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  // === DECORATIONS ===
  static BoxDecoration dialogDecoration = BoxDecoration(
    color: backgroundColor,
    borderRadius: BorderRadius.circular(28),
    border: Border.all(color: Colors.white.withOpacity(0.6), width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 30,
        offset: Offset(0, 15),
      ),
    ],
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFFDFCFB),
        Color(0xFFF7F5F0),
      ],
    ),
  );

  /// Header decoration with gradient based on zodiac colors
  static BoxDecoration headerDecoration(List<Color> zodiacGradient) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          zodiacGradient[0].withOpacity(0.15),
          zodiacGradient[1].withOpacity(0.08),
          Colors.white.withOpacity(0.95),
        ],
        stops: [0.0, 0.4, 1.0],
      ),
      border: Border(
        bottom: BorderSide(
          color: zodiacGradient[0].withOpacity(0.2),
          width: 1.5,
        ),
      ),
    );
  }

  static BoxDecoration cellDecorationSelected = BoxDecoration(
    color: primaryColor,
    shape: BoxShape.circle,
    boxShadow: [
      BoxShadow(
        color: primaryColor.withOpacity(0.3),
        blurRadius: 12,
        offset: Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration cellDecorationToday = BoxDecoration(
    color: accentColor.withOpacity(0.1),
    shape: BoxShape.circle,
    border: Border.all(color: accentColor, width: 1.5),
  );

  // === TEXT STYLES ===
  
  /// Title text "Lịch Vạn Niên" — thư pháp sang trọng
  static TextStyle calendarTitleStyle(Color zodiacColor) {
    return TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w900,
      color: zodiacColor,
      fontFamily: 'serif',
      letterSpacing: 2.0,
      shadows: [
        Shadow(
          color: zodiacColor.withOpacity(0.3),
          offset: Offset(1, 2),
          blurRadius: 4,
        ),
        Shadow(
          color: Colors.black12,
          offset: Offset(0, 1),
          blurRadius: 2,
        ),
      ],
    );
  }

  /// Subtitle "Năm ..." style
  static TextStyle calendarSubtitleStyle(Color zodiacColor) {
    return TextStyle(
      fontSize: 14,
      color: zodiacColor.withOpacity(0.7),
      fontFamily: 'serif',
      fontStyle: FontStyle.italic,
      letterSpacing: 0.8,
    );
  }

  static TextStyle dayOfWeekStyle = TextStyle(
    color: primaryColor,
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );

  /// Solar date style (ngày dương) — To, đậm, rõ ràng
  static TextStyle solarDateStyle(bool isSelected, bool isToday, bool isWeekend) {
    return TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w800,
      color: isSelected
          ? Colors.white
          : (isToday
              ? primaryColor
              : (isWeekend ? Color(0xFFD32F2F) : Color(0xFF263238))),
    );
  }

  /// Lunar date style (ngày âm) — Nhỏ hơn, nhạt hơn
  static TextStyle lunarDateStyle(bool isSelected) {
    return TextStyle(
      fontSize: 9,
      fontWeight: FontWeight.w500,
      color: isSelected ? Colors.white70 : lunarTextColor,
      fontStyle: FontStyle.italic,
    );
  }

  // === CELL DECORATIONS FOR CALENDAR ===

  /// Decoration cho ô ngày được chọn — Gradient nổi bật + shadow
  static BoxDecoration selectedCellDecoration(List<Color> zodiacGradient) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: zodiacGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: zodiacGradient[0].withOpacity(0.5),
          blurRadius: 10,
          offset: Offset(0, 4),
          spreadRadius: -1,
        ),
      ],
    );
  }

  /// Decoration cho ô "Hôm nay" — Viền gradient đặc biệt
  static BoxDecoration todayCellDecoration(List<Color> zodiacGradient) {
    return BoxDecoration(
      color: zodiacGradient[1].withOpacity(0.12),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: zodiacGradient[0].withOpacity(0.6),
        width: 2,
      ),
    );
  }

  /// Decoration cho ô ngày thường
  static BoxDecoration defaultCellDecoration() {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.4),
      borderRadius: BorderRadius.circular(10),
    );
  }

  /// Decoration cho ô có ngày lễ
  static BoxDecoration holidayCellDecoration() {
    return BoxDecoration(
      color: Color(0xFFFFF3E0).withOpacity(0.5),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: Color(0xFFE53935).withOpacity(0.15),
        width: 1,
      ),
    );
  }

  // === EVENT CARD STYLES ===

  /// Event card decoration
  static BoxDecoration eventCardDecoration({bool hasReminder = false}) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border(
        left: BorderSide(
          color: hasReminder ? Color(0xFFE53935) : Color(0xFF42A5F5),
          width: 3.5,
        ),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 10,
          offset: Offset(0, 3),
          spreadRadius: -1,
        ),
      ],
    );
  }

  /// Holiday banner decoration
  static BoxDecoration holidayBannerDecoration(List<Color> zodiacGradient) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          zodiacGradient[0].withOpacity(0.08),
          Color(0xFFE53935).withOpacity(0.06),
          zodiacGradient[1].withOpacity(0.08),
        ],
      ),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: Color(0xFFE53935).withOpacity(0.2),
        width: 1,
      ),
    );
  }

  // === WIDGETS ===

  /// Widget trang trí góc (Corner Ornament) — Mây/Hoa
  static Widget buildCornerOrnament(bool isTopLeft, {List<Color>? zodiacGradient}) {
    final color = zodiacGradient != null ? zodiacGradient[0] : accentColor;
    return Positioned(
      top: isTopLeft ? -15 : null,
      bottom: isTopLeft ? null : -15,
      left: isTopLeft ? -15 : null,
      right: isTopLeft ? null : -15,
      child: Opacity(
        opacity: 0.06,
        child: CustomPaint(
          size: Size(120, 120),
          painter: _LotusOrnamentPainter(
            color: color,
            isTopLeft: isTopLeft,
          ),
        ),
      ),
    );
  }

  /// Divider decorative với họa tiết
  static Widget buildDecorativeDivider(List<Color> zodiacGradient) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    zodiacGradient[0].withOpacity(0.3),
                    zodiacGradient[0].withOpacity(0.5),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Icon(
              Icons.spa,
              size: 16,
              color: zodiacGradient[0].withOpacity(0.4),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    zodiacGradient[0].withOpacity(0.5),
                    zodiacGradient[0].withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Holiday/Special day marker (đèn lồng nhỏ hoặc hoa sen)
  static Widget buildHolidayMarker({bool isLunar = false}) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            eventMarkerColor,
            eventMarkerColor.withOpacity(0.6),
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: eventMarkerColor.withOpacity(0.4),
            blurRadius: 3,
            spreadRadius: 0.5,
          ),
        ],
      ),
    );
  }

  /// Rằm / Mùng 1 marker (chấm vàng kim)
  static Widget buildLunarSpecialMarker() {
    return Container(
      width: 5,
      height: 5,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [goldShimmer, accentColor],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: goldShimmer.withOpacity(0.5),
            blurRadius: 2,
          ),
        ],
      ),
    );
  }

  /// Close button xịn
  static Widget buildCloseButton(VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Icon(Icons.close_rounded, color: Colors.grey[700], size: 20),
        ),
      ),
    );
  }
}

/// Lotus flower ornament painter cho trang trí góc
class _LotusOrnamentPainter extends CustomPainter {
  final Color color;
  final bool isTopLeft;

  _LotusOrnamentPainter({required this.color, required this.isTopLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = color.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final center = isTopLeft
        ? Offset(size.width * 0.3, size.height * 0.3)
        : Offset(size.width * 0.7, size.height * 0.7);

    // Draw lotus petals
    for (int i = 0; i < 8; i++) {
      final angle = (i * pi / 4);
      final petalPath = Path();
      
      petalPath.moveTo(center.dx, center.dy);
      
      final controlX1 = center.dx + cos(angle - 0.3) * size.width * 0.35;
      final controlY1 = center.dy + sin(angle - 0.3) * size.height * 0.35;
      final controlX2 = center.dx + cos(angle + 0.3) * size.width * 0.35;
      final controlY2 = center.dy + sin(angle + 0.3) * size.height * 0.35;
      final endX = center.dx + cos(angle) * size.width * 0.45;
      final endY = center.dy + sin(angle) * size.height * 0.45;

      petalPath.cubicTo(controlX1, controlY1, endX, endY, controlX2, controlY2);
      petalPath.close();

      canvas.drawPath(petalPath, paint);
      canvas.drawPath(petalPath, strokePaint);
    }

    // Draw center circle
    canvas.drawCircle(center, size.width * 0.06, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

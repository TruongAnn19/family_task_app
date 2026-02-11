import 'package:flutter/material.dart';
import 'dart:math';

/// Helper class cho 12 con giáp Việt Nam
class ZodiacHelper {
  /// Danh sách 12 con giáp (index = year % 12)
  static const List<String> zodiacNames = [
    "Thân (Khỉ)",    // 0
    "Dậu (Gà)",      // 1
    "Tuất (Chó)",     // 2
    "Hợi (Lợn)",     // 3
    "Tý (Chuột)",    // 4
    "Sửu (Trâu)",    // 5
    "Dần (Hổ)",      // 6
    "Mão (Mèo)",     // 7
    "Thìn (Rồng)",   // 8
    "Tỵ (Rắn)",      // 9
    "Ngọ (Ngựa)",    // 10
    "Mùi (Dê)",      // 11
  ];

  /// Emoji tương ứng cho 12 con giáp
  static const List<String> zodiacEmojis = [
    "🐵", // 0: Khỉ
    "🐓", // 1: Gà
    "🐕", // 2: Chó
    "🐖", // 3: Lợn
    "🐀", // 4: Chuột
    "🐂", // 5: Trâu
    "🐅", // 6: Hổ
    "🐈", // 7: Mèo
    "🐉", // 8: Rồng
    "🐍", // 9: Rắn
    "🐎", // 10: Ngựa
    "🐐", // 11: Dê
  ];

  /// Màu sắc chủ đạo cho từng con giáp (Pastel & Elegant)
  static const List<List<Color>> zodiacGradients = [
    [Color(0xFFE6B980), Color(0xFFEACDA3)],   // Khỉ (Vàng đồng)
    [Color(0xFFE57373), Color(0xFFFFCCBC)],   // Gà (Đỏ gạch)
    [Color(0xFF8D6E63), Color(0xFFD7CCC8)],   // Chó (Nâu đất)
    [Color(0xFFF06292), Color(0xFFF8BBD0)],   // Lợn (Hồng phấn)
    [Color(0xFF90A4AE), Color(0xFFCFD8DC)],   // Chuột (Xám xanh)
    [Color(0xFF795548), Color(0xFFA1887F)],   // Trâu (Nâu cafe)
    [Color(0xFFFF8A65), Color(0xFFFFCCBC)],   // Hổ (Cam san hô)
    [Color(0xFF9575CD), Color(0xFFD1C4E9)],   // Mèo (Tím hoa cà)
    [Color(0xFFE53935), Color(0xFFFFCDD2)],   // Rồng (Đỏ thắm)
    [Color(0xFF66BB6A), Color(0xFFA5D6A7)],   // Rắn (Xanh ngọc)
    [Color(0xFF42A5F5), Color(0xFFBBDEFB)],   // Ngựa (Xanh thiên thanh)
    [Color(0xFF26A69A), Color(0xFF80CBC4)],   // Dê (Ngọc bích)
  ];

  /// Lấy tên con giáp theo năm
  static String getName(int year) => zodiacNames[year % 12];
  
  /// Lấy Can Chi (ví dụ: Ất Tỵ) - Giả lập đơn giản
  static String getCanChi(int year) {
    const List<String> can = ["Canh", "Tân", "Nhâm", "Quý", "Giáp", "Ất", "Bính", "Đinh", "Mậu", "Kỷ"];
    const List<String> chi = ["Thân", "Dậu", "Tuất", "Hợi", "Tý", "Sửu", "Dần", "Mão", "Thìn", "Tỵ", "Ngọ", "Mùi"];
    return "${can[year % 10]} ${chi[year % 12]}";
  }

  /// Lấy emoji con giáp theo năm
  static String getEmoji(int year) => zodiacEmojis[year % 12];

  /// Lấy gradient màu theo năm
  static List<Color> getGradient(int year) => zodiacGradients[year % 12];

  /// Widget background con giáp (Premium & Artistic)
  /// Widget background con giáp (Premium & Artistic)
  static Widget buildZodiacBackground(int year, {double opacity = 0.08, bool isTet = false, HolidayTheme? holidayTheme}) {
    List<Color> gradient;
    if (holidayTheme != null) {
      gradient = holidayTheme.gradient;
    } else if (isTet) {
      gradient = [Color(0xFFD32F2F), Color(0xFFFFCC80)]; // Red to Gold for Tet
    } else {
      gradient = getGradient(year);
    }
    
    final canChi = getCanChi(year);
    final String watermarkChar = holidayTheme?.emoji ?? getEmoji(year);

    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        // 1. Nền giấy ấm áp (Base layer) - đổi sang đỏ nhạt nếu là Tết/Lễ đỏ
        Container(
          decoration: BoxDecoration(
            gradient: (isTet || (holidayTheme != null && holidayTheme.isRedTheme))
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFFF8F8), Color(0xFFFFEBEB)], 
                  )
                : null,
            color: (isTet || (holidayTheme != null && holidayTheme.isRedTheme)) ? null : Color(0xFFF9F7F2),
          ),
        ),
        
        // 2. Pattern họa tiết phương Đông (Cloud/Wave)
        Positioned.fill(
          child: Opacity(
            opacity: (isTet || holidayTheme != null) ? 0.2 : 0.25, // Tăng độ rõ nét (trước là 0.15 - 0.1)
            child: CustomPaint(
              painter: _OrientalPatternPainter(
                color: gradient[0], 
              ),
            ),
          ),
        ),

        // 3. Gradient phủ nhẹ tạo chiều sâu (Vignette)
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.2,
              colors: [
                Colors.white.withOpacity(0.0),
                gradient[0].withOpacity(0.08), // Viền đậm hơn chút
              ],
            ),
          ),
        ),

        // 4. Con dấu triện "Can Chi" (Góc phải)
        Positioned(
          top: 20,
          right: 20,
          child: _buildYinYangStamp(year, canChi, gradient[0]),
        ),

        // 5. Hình bóng con giáp/Sự kiện nghệ thuật (Watermark lớn góc trái dưới)
        Positioned(
          bottom: -40,
          left: -20,
          child: Opacity(
            opacity: 0.18, // Tăng gấp đôi độ rõ (trước là 0.08)
            child: watermarkChar == "🥁" 
            ? Container(
                width: 280,
                height: 280,
                child: CustomPaint(
                  painter: _DongSonDrumPainter(color: gradient[0]),
                ),
              )
            : Text(
              watermarkChar,
              style: TextStyle(
                fontSize: 280,
                color: gradient[0],
                shadows: [
                  // Tăng hiệu ứng Glow/Shadow để hình ảnh "pop" lên
                  Shadow(blurRadius: 30, color: gradient[1].withOpacity(0.6), offset: Offset(4, 4)),
                  Shadow(blurRadius: 10, color: gradient[0].withOpacity(0.4), offset: Offset(-2, -2)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Lấy theme cho ngày lễ đặc biệt (Dương lịch & Âm lịch)
  static HolidayTheme? getSpecialHolidayTheme(DateTime date, {int? lunarDay, int? lunarMonth}) {
    // --- Âm lịch Events ---
    if (lunarDay != null && lunarMonth != null) {
      // Giỗ tổ Hùng Vương (10/3 Âm)
      if (lunarDay == 10 && lunarMonth == 3) {
        return HolidayTheme(
          emoji: "🥁", // Trống đồng (tượng trưng)
          gradient: [Color(0xFF8D6E63), Color(0xFFFFD54F)], // Nâu đất & Vàng đồng
          isRedTheme: false,
        );
      }
    }

    // --- Dương lịch Events ---
    // 14/2: Valentine
    if (date.day == 14 && date.month == 2) {
      return HolidayTheme(emoji: "💘", gradient: [Color(0xFFE91E63), Color(0xFFFF80AB)], isRedTheme: true);
    }
    // 27/2: Thầy thuốc VN
    if (date.day == 27 && date.month == 2) {
      return HolidayTheme(emoji: "⚕️", gradient: [Color(0xFF1E88E5), Color(0xFF90CAF9)], isRedTheme: false);
    }
    // 8/3: Quốc tế phụ nữ
    if (date.day == 8 && date.month == 3) {
      return HolidayTheme(emoji: "🌹", gradient: [Color(0xFFD81B60), Color(0xFFF48FB1)], isRedTheme: true);
    }
    // 30/4 & 1/5
    if ((date.day == 30 && date.month == 4) || (date.day == 1 && date.month == 5)) {
      return HolidayTheme(emoji: "🇻🇳", gradient: [Color(0xFFD32F2F), Color(0xFFFFD700)], isRedTheme: true);
    }
    // 1/6: Quốc tế thiếu nhi
    if (date.day == 1 && date.month == 6) {
      return HolidayTheme(emoji: "🎈", gradient: [Color(0xFF43A047), Color(0xFFFFEB3B)], isRedTheme: false);
    }
    // 27/7: Thương binh liệt sĩ
    if (date.day == 27 && date.month == 7) {
      return HolidayTheme(emoji: "🕯️", gradient: [Color(0xFFFB8C00), Color(0xFFFFCC80)], isRedTheme: false);
    }
    // 2/9: Quốc khánh
    if (date.day == 2 && date.month == 9) {
      return HolidayTheme(emoji: "🇻🇳", gradient: [Color(0xFFD32F2F), Color(0xFFFFD700)], isRedTheme: true);
    }
    // 20/10: Phụ nữ VN
    if (date.day == 20 && date.month == 10) {
      return HolidayTheme(emoji: "💐", gradient: [Color(0xFF8E24AA), Color(0xFFCE93D8)], isRedTheme: false);
    }
    // 31/10: Halloween
    if (date.day == 31 && date.month == 10) {
      return HolidayTheme(emoji: "🎃", gradient: [Color(0xFFE65100), Color(0xFFFF9800)], isRedTheme: false);
    }
    // 20/11: Nhà giáo VN
    if (date.day == 20 && date.month == 11) {
      return HolidayTheme(emoji: "📖", gradient: [Color(0xFFEF6C00), Color(0xFFFFB74D)], isRedTheme: false);
    }
    // 22/12: Quân đội nhân dân VN
    if (date.day == 22 && date.month == 12) {
      return HolidayTheme(emoji: "🎖️", gradient: [Color(0xFF2E7D32), Color(0xFF81C784)], isRedTheme: false);
    }
    // 24/12 & 25/12: Noel
    if ((date.day == 24 || date.day == 25) && date.month == 12) {
      return HolidayTheme(emoji: "🎄", gradient: [Color(0xFF1B5E20), Color(0xFFC62828)], isRedTheme: false);
    }
    
    return null;
  }

  /// Widget con dấu triện (Stamp)
  static Widget _buildYinYangStamp(int year, String text, Color color) {
    return Container(
      width: 76,
      height: 76,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        border: Border.all(color: color.withOpacity(0.5), width: 2),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(4, 4),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Năm",
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
              fontFamily: 'serif',
              letterSpacing: 2,
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                text,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontFamily: 'serif',
                ),
              ),
            ),
          ),
          SizedBox(height: 2),
          Container(
            width: 36,
            height: 1,
            color: color.withOpacity(0.3),
          )
        ],
      ),
    );
  }

  /// Widget hiển thị info con giáp — Premium Design
  static Widget buildZodiacBadge(int year) {
    final emoji = getEmoji(year);
    final name = getName(year);
    final canChi = getCanChi(year);
    final gradient = getGradient(year);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [gradient[0], gradient[1], gradient[0].withOpacity(0.9)],
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Color(0xFFD4AF37).withOpacity(0.7), // Gold shimmer border
          width: 1.5,
        ),
        boxShadow: [
          // Outer glow
          BoxShadow(
            color: gradient[0].withOpacity(0.35),
            blurRadius: 12,
            offset: Offset(0, 4),
            spreadRadius: -1,
          ),
          // Inner subtle shadow
          BoxShadow(
            color: Color(0xFFD4AF37).withOpacity(0.15),
            blurRadius: 6,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Emoji with container 
          Container(
            padding: EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Text(emoji, style: TextStyle(fontSize: 22)),
          ),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Năm $name',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  shadows: [
                    Shadow(color: Colors.black38, blurRadius: 3),
                  ],
                ),
              ),
              Text(
                canChi,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 10,
                  fontFamily: 'serif',
                  fontStyle: FontStyle.italic,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HolidayTheme {
  final String emoji;
  final List<Color> gradient;
  final bool isRedTheme;

  HolidayTheme({required this.emoji, required this.gradient, this.isRedTheme = false});
}

/// Custom Paisley/Cloud Pattern Painter
class _OrientalPatternPainter extends CustomPainter {
  final Color color;

  _OrientalPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    double step = 50; 
    
    // Vẽ họa tiết vảy cá / mây đơn giản (Seigaiha inspired)
    for (double y = step; y < size.height + step; y += step * 0.6) {
      bool isEvenRow = (y / (step * 0.6)).floor() % 2 == 0;
      double xOffset = isEvenRow ? 0 : step / 2;
      
      for (double x = -step; x < size.width + step; x += step) {
        canvas.drawArc(
          Rect.fromCircle(center: Offset(x + xOffset, y), radius: step * 0.4),
          pi,
          pi, // Half circle (top arc)
          false,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom Dong Son Drum Painter (Detailed)
class _DongSonDrumPainter extends CustomPainter {
  final Color color;

  _DongSonDrumPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    
    // Style chung
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final fillPaint = Paint()
      ..color = color // Màu solid
      ..style = PaintingStyle.fill;

    // === 1. MẶT TRỜI TRUNG TÂM (14 cánh) ===
    final starRadius = radius * 0.22;
    final int points = 14;
    final pathStar = Path();
    for (int i = 0; i < points * 2; i++) {
        double angle = (i * pi) / points - (pi / 2); // Bắt đầu từ 12h
        double r = (i % 2 == 0) ? starRadius : starRadius * 0.3; // Độ sâu cánh sao
        double x = center.dx + r * cos(angle);
        double y = center.dy + r * sin(angle);
        if (i == 0) pathStar.moveTo(x, y);
        else pathStar.lineTo(x, y);
    }
    pathStar.close();
    canvas.drawPath(pathStar, fillPaint);
    
    // Họa tiết kẽ lông công giữa các cánh sao (Tam giác nhỏ)
    for (int i = 0; i < points; i++) {
       double angle = (i * 2 * pi) / points - (pi / 2) + (pi / points); // Góc giữa 2 cánh
       double rStart = starRadius * 0.35;
       double rEnd = starRadius * 0.9;
       
       Path triPath = Path();
       triPath.moveTo(center.dx + rStart * cos(angle), center.dy + rStart * sin(angle));
       triPath.lineTo(center.dx + rEnd * cos(angle - 0.05), center.dy + rEnd * sin(angle - 0.05));
       triPath.lineTo(center.dx + rEnd * cos(angle + 0.05), center.dy + rEnd * sin(angle + 0.05));
       triPath.close();
       canvas.drawPath(triPath, strokePaint..strokeWidth = 0.8);
    }

    // === 2. CÁC VÒNG TRÒN ĐỒNG TÂM ===
    // Vẽ khung các vòng
    double r1 = radius * 0.32; // Vòng bao mặt trời
    double r2 = radius * 0.50; // Vòng người
    double r3 = radius * 0.70; // Vòng chim
    double r4 = radius * 0.88; // Vòng ngoài rìa
    
    canvas.drawCircle(center, r1, strokePaint);
    canvas.drawCircle(center, r2, strokePaint);
    canvas.drawCircle(center, r3, strokePaint);
    canvas.drawCircle(center, r4, strokePaint);
    canvas.drawCircle(center, radius * 0.98, strokePaint..strokeWidth=3); // Viền ngoài cùng đậm

    // === 3. VÒNG HỌA TIẾT NGƯỜI (Cách điệu hình học) ===
    // Vẽ chuỗi hình tượng trưng người nắm tay/nhảy múa
    int numHumans = 16;
    for (int i = 0; i < numHumans; i++) {
       double angle = (2 * pi * i) / numHumans;
       double rMid = (r1 + r2) / 2;
       
       canvas.save();
       canvas.translate(center.dx + rMid * cos(angle), center.dy + rMid * sin(angle));
       canvas.rotate(angle + pi/2);
       
       // Vẽ người cách điệu (Thân + Mũ lông chim)
       Path human = Path();
       // Mũ lông chim cao
       human.moveTo(0, -8);
       human.lineTo(4, -16);
       human.lineTo(-2, -8);
       // Đầu & Thân
       human.addOval(Rect.fromCircle(center: Offset(0, -6), radius: 2));
       human.moveTo(0, -4);
       human.lineTo(0, 6);
       // Tay giang ra
       human.moveTo(-5, -2);
       human.lineTo(5, -2);
       // Chân dáng múa
       human.moveTo(0, 6);
       human.lineTo(-4, 10);
       human.moveTo(0, 6);
       human.lineTo(4, 10);
       
       canvas.drawPath(human, strokePaint..strokeWidth=1.0);
       canvas.restore();
    }

    // === 4. VÒNG CHIM LẠC (Bay ngược chiều kim đồng hồ) ===
    int numBirds = 12;
    for (int i = 0; i < numBirds; i++) {
       double angle = (2 * pi * i) / numBirds;
       double rMid = (r2 + r3) / 2;
       
       canvas.save();
       // Dịch chuyển
       canvas.translate(center.dx + rMid * cos(angle), center.dy + rMid * sin(angle));
       // Xoay hướng chim bay (Ngược chiều kim đồng hồ)
       canvas.rotate(angle + pi); 

       // Vẽ Chim Lạc (Chi tiết hơn)
       Path birdBody = Path();
       birdBody.moveTo(18, -3); // Mỏ dài
       birdBody.lineTo(6, 0); // Đầu
       birdBody.lineTo(-8, 0); // Thân
       birdBody.lineTo(-20, -4); // Đuôi dài vút lên
       birdBody.lineTo(-10, 3); // Bụng
       birdBody.lineTo(0, 3); 
       birdBody.close();
       
       canvas.drawPath(birdBody, fillPaint..color = color.withOpacity(0.9));
       
       // Cánh vươn lên
       canvas.drawLine(Offset(-6, 0), Offset(-2, 10), strokePaint..strokeWidth=1.2);
       
       canvas.restore();
    }

    // === 5. VÒNG RĂNG LƯỢC / CHẤM TRÒN ===
    // Vẽ các chấm tròn nhỏ (vòng hạt)
    double rDot = (r3 + r4) / 2;
    int dots = 48;
    for (int i = 0; i < dots; i++) {
       double angle = (2 * pi * i) / dots;
       canvas.drawCircle(
         Offset(center.dx + rDot * cos(angle), center.dy + rDot * sin(angle)), 
         2.0, 
         fillPaint
       );
    }
    
    // Vòng răng cưa ngoài cùng
    double rSaw = (r4 + radius*0.98) / 2;
    int saws = 60;
    for (int i = 0; i < saws; i++) {
       double angle = (2 * pi * i) / saws;
       double x = center.dx + rSaw * cos(angle);
       double y = center.dy + rSaw * sin(angle);
       canvas.drawLine(
         Offset(center.dx + r4 * cos(angle), center.dy + r4 * sin(angle)), 
         Offset(center.dx + radius * 0.98 * cos(angle), center.dy + radius * 0.98 * sin(angle)), 
         strokePaint..strokeWidth=0.8
       );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

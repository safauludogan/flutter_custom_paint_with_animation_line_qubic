import 'package:flutter/material.dart';
import 'package:flutter_ddd/features/weight_tracking/domain/enums/weight_goal.dart';

class WeightProgressPainter extends CustomPainter {
  final double progress;
  final double bubbleScale;
  final WeightGoal weightGoal;

  WeightProgressPainter(this.progress, this.bubbleScale, this.weightGoal);

  void _drawStartDot(Canvas canvas, Offset position) {
    // Dış beyaz halka
    canvas.drawCircle(
      position,
      8,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );

    // İçi boş turuncu halka
    canvas.drawCircle(
      position,
      8,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            const Color(0xffF59841),
            const Color(0xffEB6B50),
          ],
        ).createShader(Rect.fromLTWH(position.dx - 8, position.dy - 8, 16, 16))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _drawMovingDot(Canvas canvas, Offset position) {
    // Dış beyaz halka
    canvas.drawCircle(
      position,
      10,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );

    // İçi dolu turuncu daire
    canvas.drawCircle(
        position,
        10,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              const Color(0xffF59841),
              const Color(0xffEB6B50),
            ],
          ).createShader(
              Rect.fromLTWH(position.dx - 10, position.dy - 10, 20, 20))
          ..style = PaintingStyle.fill);
  }

  void _drawWeightBubble(
      Canvas canvas, Offset position, String weight, double scale) {
    canvas.save();

    // Baloncuk için path
    final bubblePath = Path();
    const bubbleWidth = 70.0;
    const bubbleHeight = 35.0;
    const cornerRadius = 8.0;
    const verticalOffset = 25.0; // Dot'tan yukarı mesafe

    final rect = Rect.fromLTWH(
      position.dx - bubbleWidth / 2,
      position.dy - bubbleHeight - verticalOffset, // Mesafeyi artırdık
      bubbleWidth,
      bubbleHeight,
    );

    bubblePath.addRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(cornerRadius)));

    // Üçgen (ok) çizimi - pozisyonu da yukarı taşıyoruz
    bubblePath.moveTo(position.dx, position.dy - verticalOffset + 5);
    bubblePath.lineTo(position.dx - 8, position.dy - verticalOffset);
    bubblePath.lineTo(position.dx + 8, position.dy - verticalOffset);
    bubblePath.close();

    // Scale transformasyonu uygula
    canvas.translate(position.dx, position.dy - verticalOffset);
    canvas.scale(scale);
    canvas.translate(-position.dx, -(position.dy - verticalOffset));

    // Baloncuğu çiz
    canvas.drawPath(
      bubblePath,
      Paint()
        ..color = const Color(0xFF4A4A4A)
        ..style = PaintingStyle.fill,
    );

    // Metni çiz
    final textSpan = TextSpan(
      text: weight,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        rect.center.dx - textPainter.width / 2,
        rect.center.dy - textPainter.height / 2,
      ),
    );

    canvas.restore();
  }

  void _drawText(Canvas canvas, String text, Offset position) {
    final textSpan = TextSpan(
      text: text,
      style: const TextStyle(
        color: Colors.black54,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        position.dx - textPainter.width / 2,
        position.dy - textPainter.height * -.1,
      ),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final drawingWidth = size.width * 0.85;

    // Üst çizgi için gradient paint
    final strokePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          const Color(0xffF59841),
          const Color(0xffEB6B50),
        ],
      ).createShader(Rect.fromLTWH(0, 0, drawingWidth, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    // Dolgu için paint
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.orange.withOpacity(0.4),
          Colors.orange.withOpacity(0.06),
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();

    // Başlangıç ve bitiş noktalarını hedefe göre ayarla
    final startPoint = Offset(0, _getStartPointY(size));
    final endPoint = Offset(drawingWidth, _getEndPointY(size));

    path.moveTo(startPoint.dx, startPoint.dy);

    // Kontrol noktalarını hedefe göre ayarla
    path.cubicTo(
      drawingWidth * 0.3,
      _getFirstControlPointY(size),
      drawingWidth * 0.3,
      _getSecondControlPointY(size),
      endPoint.dx,
      endPoint.dy,
    );

    // Progress'e göre kırpma path'i
    final clipPath = Path();
    clipPath.addRect(Rect.fromLTRB(0, 0, drawingWidth * progress, size.height));

    // Kırpılmış path'i oluştur
    final currentPath = Path();
    currentPath.moveTo(startPoint.dx, startPoint.dy);

    if (progress > 0) {
      final metrics = path.computeMetrics().first;
      final extractPath = metrics.extractPath(0, metrics.length * progress);
      currentPath.addPath(extractPath, Offset.zero);

      // Dolgu için path'i tamamla
      currentPath.lineTo(currentPath.getBounds().right, size.height);
      currentPath.lineTo(0, size.height);
      currentPath.close();
    }

    // Önce dolguyu çiz
    canvas.drawPath(currentPath, fillPaint);

    // Sonra üst çizgiyi çiz
    if (progress > 0) {
      final metrics = path.computeMetrics().first;
      final extractPath = metrics.extractPath(0, metrics.length * progress);
      canvas.drawPath(extractPath, strokePaint);
    }

    // Eğer ana animasyon tamamlandıysa baloncuğu göster
    if (progress >= 1.0) {
      _drawWeightBubble(canvas, endPoint, '89.0 KG', bubbleScale);
    }

    // Başlangıç noktası dot'unu çiz (içi boş)
    _drawStartDot(canvas, startPoint);

    // Hareketli nokta (içi dolu)
    if (progress > 0) {
      final pathMetrics = path.computeMetrics().first;
      final tangent =
          pathMetrics.getTangentForOffset(pathMetrics.length * progress);

      if (tangent != null) {
        _drawMovingDot(canvas, tangent.position);
      }
    }

    // Metin pozisyonlarını hesapla
    final startTextPosition = Offset(10, size.height); // 20'den 10'a düşürdük
    final middleTextPosition = Offset(
      drawingWidth * 0.5 + 10, // 20'den 10'a düşürdük
      size.height,
    );
    final endTextPosition = Offset(
      drawingWidth - 5, // 10'dan 5'e düşürdük
      size.height,
    );

    // Metinleri çiz
    _drawText(canvas, 'Bugün', startTextPosition);
    _drawText(canvas, 'Şubat', middleTextPosition);
    _drawText(canvas, 'Bitiş', endTextPosition);
  }

  // Y koordinatlarını hesaplayan yardımcı metodlar
  double _getStartPointY(Size size) {
    switch (weightGoal) {
      case WeightGoal.gain:
        return size.height * 0.94; // Aşağıdan başla
      case WeightGoal.loss:
        return size.height * 0.55; // Yukarıdan başla
      case WeightGoal.maintain:
        return size.height * 0.75; // Ortadan başla
    }
  }

  double _getEndPointY(Size size) {
    switch (weightGoal) {
      case WeightGoal.gain:
        return size.height * 0.55; // Yukarıda bitir
      case WeightGoal.loss:
        return size.height * 0.94; // Aşağıda bitir
      case WeightGoal.maintain:
        return size.height * 0.75; // Aynı seviyede bitir
    }
  }

  double _getFirstControlPointY(Size size) {
    switch (weightGoal) {
      case WeightGoal.gain:
        return size.height * 0.95;
      case WeightGoal.loss:
        return size.height * 0.55;
      case WeightGoal.maintain:
        return size.height * 0.70; // Hafif aşağı
    }
  }

  double _getSecondControlPointY(Size size) {
    switch (weightGoal) {
      case WeightGoal.gain:
        return size.height * 0.55;
      case WeightGoal.loss:
        return size.height * 0.95;
      case WeightGoal.maintain:
        return size.height * 0.80; // Hafif yukarı
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

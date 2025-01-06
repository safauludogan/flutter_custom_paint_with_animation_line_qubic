import 'package:flutter/material.dart';

class AnimationScreen extends StatefulWidget {
  const AnimationScreen({super.key});

  @override
  State<AnimationScreen> createState() => _AnimationScreenState();
}

class _AnimationScreenState extends State<AnimationScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late AnimationController _bubbleController;
  late Animation<double> _bubbleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );

    _bubbleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _bubbleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _bubbleController,
        curve: Curves.easeOutBack,
      ),
    );

    _animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _bubbleController.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _bubbleController.dispose();
    super.dispose();
  }

  void _startAnimation() {
    _controller.reset();
    _bubbleController.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kilo Takibi'),
        backgroundColor: Colors.orange,
      ),
      body: ColoredBox(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kilo Takibi',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: AnimatedBuilder(
                          animation:
                              Listenable.merge([_animation, _bubbleAnimation]),
                          builder: (context, child) {
                            return CustomPaint(
                              size: const Size(double.infinity, 300),
                              painter: PathPainter(
                                  _animation.value, _bubbleAnimation.value),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startAnimation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Animasyonu Başlat',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PathPainter extends CustomPainter {
  final double progress;
  final double bubbleScale;

  PathPainter(this.progress, this.bubbleScale);

  void _drawDot(Canvas canvas, Offset position) {
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
    final startPoint = Offset(0, size.height * 0.94);
    final endPoint = Offset(drawingWidth, size.height * 0.55);

    path.moveTo(startPoint.dx, startPoint.dy);

    path.cubicTo(
      drawingWidth * 0.3,
      size.height * 0.95,
      drawingWidth * 0.3,
      size.height * 0.55,
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

    // Başlangıç noktası dot'unu çiz
    _drawDot(canvas, startPoint);

    // Hareketli nokta
    if (progress > 0) {
      final pathMetrics = path.computeMetrics().first;
      final tangent =
          pathMetrics.getTangentForOffset(pathMetrics.length * progress);

      if (tangent != null) {
        _drawDot(canvas, tangent.position);
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

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

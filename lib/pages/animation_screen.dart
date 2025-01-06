import 'package:flutter/material.dart';
import '../widgets/weight_progress_painter.dart';
import '../features/weight_tracking/domain/enums/weight_goal.dart';

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

  final WeightGoal weightGoal = WeightGoal.gain; // veya loss veya maintain

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
                              painter: WeightProgressPainter(
                                _animation.value,
                                _bubbleAnimation.value,
                                weightGoal,
                              ),
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

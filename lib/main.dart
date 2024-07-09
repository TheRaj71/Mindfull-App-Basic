import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() => runApp(MindfulnessApp());

class MindfulnessApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mindfulness Breathing',
      theme: ThemeData(primarySwatch: Colors.green),
      home: BreathingScreen(),
    );
  }
}

class BreathingScreen extends StatefulWidget {
  @override
  _BreathingScreenState createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen> {
  int _countdown = 4;
  String _breathingState = "Inhale...";
  Timer? _timer;
  int _totalSeconds = 5 * 60 + 4; // 5 minutes and 4 seconds
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
  }

  void _toggleBreathing() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _startBreathingCycle();
      } else {
        _timer?.cancel();
      }
    });
  }

  void _startBreathingCycle() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_totalSeconds > 0) {
        setState(() {
          _totalSeconds--;
          _countdown--;
          if (_countdown == 0) {
            _countdown = 4;
            _breathingState = _breathingState == "Inhale..." ? "Exhale..." : "Inhale...";
          }
        });
      } else {
        timer.cancel();
        _resetSession();
      }
    });
  }

  void _resetSession() {
    setState(() {
      _countdown = 4;
      _breathingState = "Inhale...";
      _totalSeconds = 5 * 60 + 4;
      _isPlaying = false;
    });
  }

  String get timerString {
    int minutes = _totalSeconds ~/ 60;
    int seconds = _totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')} mins ${seconds.toString().padLeft(2, '0')} secs';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE0F2E9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Mindfulness Breathing', style: TextStyle(color: Colors.black, fontSize: 20)),
        actions: [
          Icon(Icons.volume_up, color: Colors.black),
          Icon(Icons.wifi_off, color: Colors.black),
          Icon(Icons.battery_full, color: Colors.black),
          Icon(Icons.camera, color: Colors.black),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$_countdown',
                    style: TextStyle(fontSize: 120, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  SizedBox(height: 20),
                  Text(
                    _breathingState,
                    style: TextStyle(fontSize: 30, color: Colors.green),
                  ),
                  SizedBox(height: 40),
                  GestureDetector(
                    onTap: _toggleBreathing,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 40,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    timerString,
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
            _buildStressGraph(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStressGraph() {
    return Container(
      height: 200,
      child: CustomPaint(
        size: Size(double.infinity, 200),
        painter: StressGraphPainter(),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class StressGraphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw vertical line
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height * 0.8),
      paint,
    );

    // Draw curved lines
    final path = Path()
      ..moveTo(0, size.height * 0.8)
      ..quadraticBezierTo(size.width / 4, size.height * 0.2, size.width / 2, size.height * 0.8)
      ..quadraticBezierTo(3 * size.width / 4, size.height * 1.4, size.width, size.height * 0.8);

    canvas.drawPath(path, paint);

    // Draw circles
    _drawCircle(canvas, Offset(size.width * 0.25, size.height * 0.5), Colors.red);
    _drawCircle(canvas, Offset(size.width * 0.5, size.height * 0.1), Colors.yellow);
    _drawCircle(canvas, Offset(size.width * 0.75, size.height * 0.5), Colors.blue);

    // Add labels
    _drawText(canvas, 'PAST', Offset(size.width * 0.25, size.height * 0.9));
    _drawText(canvas, 'PRESENT', Offset(size.width * 0.5, size.height * 0.9));
    _drawText(canvas, 'FUTURE', Offset(size.width * 0.75, size.height * 0.9));
    _drawText(canvas, 'STRESS', Offset(size.width * 0.52, size.height * 0.1), rotation: -pi/2);
  }

  void _drawCircle(Canvas canvas, Offset center, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 10, paint);
  }

  void _drawText(Canvas canvas, String text, Offset offset, {double rotation = 0}) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: Colors.black, fontSize: 14)),
      textDirection: TextDirection.ltr,
    )..layout();

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.rotate(rotation);
    textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
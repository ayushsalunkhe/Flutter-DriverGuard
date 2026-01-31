import 'package:driver_guard/ui/theme.dart';
import 'package:flutter/material.dart';

class LiveWaveform extends StatefulWidget {
  final double value; // Expecting normalized value (e.g. EAR 0.0 - 0.5)
  final double min;
  final double max;
  final Color color;

  const LiveWaveform({
    super.key,
    required this.value,
    this.min = 0.0,
    this.max = 0.5,
    this.color = AppTheme.cyan,
  });

  @override
  State<LiveWaveform> createState() => _LiveWaveformState();
}

class _LiveWaveformState extends State<LiveWaveform> {
  final List<double> _history = [];
  final int _maxSamples = 50;

  @override
  void didUpdateWidget(LiveWaveform oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _addSample(widget.value);
    }
  }

  void _addSample(double val) {
    setState(() {
      _history.add(val);
      if (_history.length > _maxSamples) {
        _history.removeAt(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      width: 100,
      child: CustomPaint(
        painter: WaveformPainter(
          data: _history,
          min: widget.min,
          max: widget.max,
          color: widget.color,
        ),
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  final List<double> data;
  final double min;
  final double max;
  final Color color;

  WaveformPainter({
    required this.data,
    required this.min,
    required this.max,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Gradient fill below line
    final Paint fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withOpacity(0.3), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final Path path = Path();
    final double stepX =
        size.width / (data.length - 1 > 0 ? data.length - 1 : 1);

    // Normalize and map points
    for (int i = 0; i < data.length; i++) {
      // Clamp value
      double val = data[i].clamp(min, max);
      // Normalize 0.0 - 1.0
      double normalized = (val - min) / (max - min);
      // Invert Y (Canvas 0 is top)
      double y = size.height - (normalized * size.height);
      double x = i * stepX;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Close path for fill
    Path fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return true; // Always repaint on new data
  }
}

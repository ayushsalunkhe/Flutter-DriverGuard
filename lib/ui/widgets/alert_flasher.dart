import 'dart:async';
import 'package:driver_guard/providers/driver_state_provider.dart';
import 'package:flutter/material.dart';

class AlertFlasher extends StatefulWidget {
  final DriverState state;

  const AlertFlasher({super.key, required this.state});

  @override
  State<AlertFlasher> createState() => _AlertFlasherState();
}

class _AlertFlasherState extends State<AlertFlasher> {
  Timer? _timer;
  bool _isVisible = false;

  @override
  void didUpdateWidget(covariant AlertFlasher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state != oldWidget.state) {
      _handleStateChange();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _handleStateChange() {
    _timer?.cancel();

    if (widget.state == DriverState.DROWSY ||
        widget.state == DriverState.NO_FACE) {
      _startFlashing();
    } else {
      setState(() {
        _isVisible = false;
      });
    }
  }

  void _startFlashing() {
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          _isVisible = !_isVisible;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.state == DriverState.AWAKE ||
        widget.state == DriverState.HIGH_LOAD) {
      return const SizedBox.shrink();
    }

    Color flashColor;
    if (widget.state == DriverState.DROWSY) {
      flashColor = Colors.red.withOpacity(0.5); // Drowsy -> Red
    } else {
      flashColor = Colors.yellow.withOpacity(0.5); // No Face -> Yellow
    }

    return IgnorePointer(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        color: _isVisible ? flashColor : Colors.transparent,
        child: _isVisible
            ? Center(
                child: Icon(
                  widget.state == DriverState.DROWSY
                      ? Icons.warning
                      : Icons.visibility_off,
                  size: 100,
                  color: Colors.white,
                ),
              )
            : null,
      ),
    );
  }
}

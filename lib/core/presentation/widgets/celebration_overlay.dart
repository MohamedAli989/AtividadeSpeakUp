import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

class CelebrationOverlay extends StatefulWidget {
  final Widget child;

  const CelebrationOverlay({super.key, required this.child});

  @override
  CelebrationOverlayState createState() => CelebrationOverlayState();

  /// Helper to access the state from descendants: `CelebrationOverlay.of(context)?.play()`
  static CelebrationOverlayState? of(BuildContext context) {
    return context.findAncestorStateOfType<CelebrationOverlayState>();
  }
}

class CelebrationOverlayState extends State<CelebrationOverlay> {
  late final ConfettiController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(duration: const Duration(seconds: 2));
  }

  /// Play the confetti animation
  void play() {
    _controller.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        // Top-center confetti
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _controller,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              emissionFrequency: 0.02,
              numberOfParticles: 30,
              maxBlastForce: 20,
              minBlastForce: 5,
              gravity: 0.3,
            ),
          ),
        ),
      ],
    );
  }
}

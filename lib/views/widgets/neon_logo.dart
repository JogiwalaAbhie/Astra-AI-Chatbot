import 'package:flutter/material.dart';

class NeonLogo extends StatelessWidget {
  final double size;
  const NeonLogo({super.key, this.size = 100});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Colors.blueAccent, Colors.purpleAccent, Colors.cyan],
      ).createShader(bounds),
      child: Text(
        "Astra",
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [
            Shadow(color: Colors.blueAccent, blurRadius: 40),
            Shadow(color: Colors.purpleAccent, blurRadius: 40),
          ],
        ),
      ),
    );
  }
}

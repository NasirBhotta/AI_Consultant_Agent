import 'package:flutter/material.dart';

class GoogleMark extends StatelessWidget {
  const GoogleMark({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      height: 18,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: 10,
              height: 4,
              decoration: const BoxDecoration(
                color: Color(0xFF4285F4),
                borderRadius: BorderRadius.all(Radius.circular(6)),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 4,
              height: 10,
              decoration: const BoxDecoration(
                color: Color(0xFF34A853),
                borderRadius: BorderRadius.all(Radius.circular(6)),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 10,
              height: 4,
              decoration: const BoxDecoration(
                color: Color(0xFFFBBC05),
                borderRadius: BorderRadius.all(Radius.circular(6)),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 4,
              height: 10,
              decoration: const BoxDecoration(
                color: Color(0xFFEA4335),
                borderRadius: BorderRadius.all(Radius.circular(6)),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF1B2431),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

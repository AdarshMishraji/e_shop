import 'package:flutter/material.dart';

class Badge extends StatelessWidget {
  final String value;
  final Widget child;

  const Badge({
    Key? key,
    required this.value,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          bottom: 8,
          right: 8,
          child: Container(
            height: 24,
            padding: const EdgeInsets.all(5),
            decoration: const BoxDecoration(
              color: Colors.redAccent,
              shape: BoxShape.circle,
            ),
            child: Text(
              value,
              textAlign: TextAlign.center,
              softWrap: true,
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

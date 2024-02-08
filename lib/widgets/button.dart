import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final void Function() onTap;
  final Widget child;

  const Button({super.key, required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 150,
            vertical: 12.0,
          ),
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(9.0)),
        ),
        onPressed: onTap,
        child: child,
      ),
    );
  }
}

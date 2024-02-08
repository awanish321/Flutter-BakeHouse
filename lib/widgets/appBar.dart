import 'package:flutter/material.dart';

PreferredSizeWidget ApplicationBar(
    {required String title,
    List<Widget>? actions,
    required BuildContext context}) {
  return AppBar(
    backgroundColor: Theme.of(context).colorScheme.onSecondary,
    title: Text(
      title,
      style: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
    ),
    actions: actions,
  );
}

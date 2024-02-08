import 'package:flutter/material.dart';

class SnackbarMessage extends SnackBar {
  SnackbarMessage({
    Key? key,
    required IconData iconData,
    required String title,
    required String subtitle,
    required Color backgroundColor,
    required BuildContext context,
  }) : super(
          key: key,
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 3,
          content: Container(
            padding: const EdgeInsets.all(8),
            height: MediaQuery.of(context).size.height * 0.1,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: const BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  iconData,
                  size: 40,
                  color: Colors.white,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
}

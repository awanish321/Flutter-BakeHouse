import 'package:flutter/material.dart';

class InputTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? lableText;
  final String hintText;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final TextInputType keyBordType;

  const InputTextField(
      {super.key,
      required this.controller,
      this.lableText,
      required this.hintText,
      this.validator,
      this.prefixIcon,
      required this.keyBordType});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: TextFormField(
          controller: controller,
          keyboardType: keyBordType,
          style: Theme.of(context)
              .textTheme
              .labelLarge!
              .copyWith(color: Theme.of(context).colorScheme.secondary),
          decoration: InputDecoration(
            labelText: lableText,
            labelStyle: Theme.of(context)
                .textTheme
                .labelLarge!
                .copyWith(color: Theme.of(context).colorScheme.secondary),
            hintText: hintText,
            hintStyle: Theme.of(context)
                .textTheme
                .labelLarge!
                .copyWith(color: Theme.of(context).colorScheme.secondary),
            prefixIcon: prefixIcon,
            border: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.amber,
              ),
            ),
          ),
          validator: validator),
    );
  }
}

import 'package:flutter/material.dart';

class PasswordTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? lableText;
  final String hintText;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final TextInputType? keyBordType;

  const PasswordTextField(
      {super.key,
      required this.controller,
      this.lableText,
      required this.hintText,
      this.validator,
      this.prefixIcon,
      this.keyBordType});

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool isVisible = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: TextFormField(
        obscureText: isVisible,
        keyboardType: widget.keyBordType,
        controller: widget.controller,
        style: Theme.of(context)
            .textTheme
            .bodyMedium!
            .copyWith(color: Theme.of(context).colorScheme.secondary),
        decoration: InputDecoration(
          labelText: widget.lableText,
          labelStyle: Theme.of(context).textTheme.labelMedium!.copyWith(
              color: Theme.of(context).colorScheme.secondary, fontSize: 18),
          hintText: widget.hintText,
          hintStyle: Theme.of(context).textTheme.labelMedium!.copyWith(
              color: Theme.of(context).colorScheme.secondary, fontSize: 18),
          prefixIcon: widget.prefixIcon,
          suffixIcon: IconButton(
            onPressed: () {
              setState(() {
                isVisible = !isVisible;
              });
            },
            icon: Icon(isVisible ? Icons.visibility_off : Icons.visibility),
          ),
          border: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.amber,
            ),
          ),
        ),
        validator: widget.validator,
      ),
    );
  }
}

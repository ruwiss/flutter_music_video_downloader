import 'package:flutter/material.dart';

class InputWidget extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final bool isSecret;
  final String? errorText;
  final Function()? onTap;
  const InputWidget(
      {super.key,
      this.controller,
      this.hintText,
      this.isSecret = false,
      this.errorText,
      this.onTap});

  @override
  State<InputWidget> createState() => _InputWidgetState();
}

class _InputWidgetState extends State<InputWidget> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: widget.isSecret,
      decoration: InputDecoration(
        hintText: widget.hintText,
        errorText: widget.errorText,
        errorStyle: const TextStyle(color: Colors.red),
        border: const OutlineInputBorder(),
        isDense: true,
        suffixIcon: widget.onTap == null
            ? null
            : IconButton(
                onPressed: widget.onTap,
                icon: const Icon(
                  Icons.keyboard_arrow_right,
                  size: 40,
                ),
              ),
      ),
    );
  }
}

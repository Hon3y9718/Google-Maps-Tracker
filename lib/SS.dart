import 'package:flutter/material.dart';

class SS extends StatefulWidget {
  const SS({Key? key, required this.image}) : super(key: key);
  final image;
  @override
  State<SS> createState() => _SSState();
}

class _SSState extends State<SS> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: widget.image,
    );
  }
}

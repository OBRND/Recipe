import 'package:flutter/material.dart';

const Color greyCustom = Colors.white;

const textinputdecoration = InputDecoration(
  fillColor: Colors.white,
  filled: true,
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xFFD8D3D3), width: 1),
    borderRadius: BorderRadius.all(Radius.circular(12)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xFFD8D3D3), width: 1),
    borderRadius: BorderRadius.all(Radius.circular(12)),
  ),
);

BoxDecoration boxDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(12),
  border: Border.all(color: greyCustom),
);
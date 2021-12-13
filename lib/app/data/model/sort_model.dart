import 'package:flutter/material.dart';

class Sort {
  final int id;
  final Icon icon;
  final String text;
  final VoidCallback action;

  Sort({
    required this.id,
    required this.icon,
    required this.text,
    required this.action,
  });
}
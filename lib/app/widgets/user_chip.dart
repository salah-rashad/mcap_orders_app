import 'package:flutter/material.dart';
import 'package:mcap_orders_app/app/theme/color_theme.dart';

class UserChip extends StatelessWidget {
  final String labelText;
  final String? toolTipText;
  final Color? color;
  final VoidCallback? onDelete;

  final bool _isTooltipped;

  const UserChip({
    Key? key,
    required this.labelText,
    this.toolTipText,
    this.color = Colors.grey,
    this.onDelete,
  })  : _isTooltipped = false,
        super(key: key);

  const UserChip.isTooltipped({
    Key? key,
    required this.labelText,
    required this.toolTipText,
    this.color = Colors.indigo,
    this.onDelete,
  })  : _isTooltipped = true,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    if (_isTooltipped) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: Tooltip(
          // decoration: BoxDecoration(color: color?.withOpacity(0.7)),
          message: toolTipText!,
          // textStyle: TextStyle(color: color?.inverted),
          margin: const EdgeInsets.only(bottom: 16.0),
          enableFeedback: true,
          preferBelow: false,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Chip(
              label: Text(labelText),
              labelStyle: TextStyle(color: color?.inverted),
              deleteIcon: const Icon(Icons.close),
              deleteIconColor: color?.inverted,
              onDeleted: onDelete,
              useDeleteButtonTooltip: false,
              backgroundColor: color,
            ),
          ),
        ),
      );
    } else {
      return Chip(
        label: Text(
          labelText,
          textDirection: TextDirection.ltr,
        ),
        deleteIcon: const Icon(Icons.close),
        deleteIconColor: Colors.red,
        onDeleted: onDelete,
        useDeleteButtonTooltip: false,
      );
    }
  }
}

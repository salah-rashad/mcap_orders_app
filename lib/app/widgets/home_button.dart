import 'package:flutter/material.dart';
import 'package:mcap_orders_app/app/theme/color_theme.dart';

class HomeButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? primaryColor;
  final Color? onPrimaryColor;
  final VoidCallback onPressed;
  final double? elevation;
  final bool noBackground;
  final String? badge;
  final bool badgeTapThrough;

  const HomeButton({
    Key? key,
    required this.onPressed,
    required this.title,
    required this.icon,
    this.primaryColor,
    this.onPrimaryColor,
    this.elevation,
    this.noBackground = false,
    this.badge,
    this.badgeTapThrough = true,
  }) : super(key: key);

  Color get _onPrimary =>
      onPrimaryColor ??
      (noBackground
          ? primaryColor ?? Colors.white
          : (primaryColor ?? Colors.white).inverted);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ElevatedButton(
          onPressed: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 32.0,
                ),
                Flexible(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          style: ElevatedButton.styleFrom(
            primary: noBackground ? Colors.transparent : primaryColor,
            onPrimary: _onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            shadowColor: noBackground ? Colors.transparent : primaryColor,
            elevation: elevation ?? 2.0,
          ),
        ),
        if (badge != null)
          IgnorePointer(
            ignoring: badgeTapThrough,
            child: Align(
              heightFactor: 0.5,
              alignment: Alignment.topRight,
              child: Chip(
                label: Text(
                  badge ?? "",
                  style: TextStyle(
                    color: _onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                backgroundColor: primaryColor!.withAlpha(180),
                elevation: 10.0,
              ),
              widthFactor: 5.0,
            ),
          )
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:music_player/constants/app_colors.dart';

class MyButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPress;
  final EdgeInsetsGeometry? padding;
  final bool isPressed;
  final Color btnBackGround;
  final Color blurFirstColor;
  final Color blurSecondColor;
  const MyButton({
    super.key,
    required this.child,
    required this.onPress,
    this.padding,
    this.isPressed = false,
    this.btnBackGround = AppColors.secondary,
    this.blurFirstColor = AppColors.blurColor,
    this.blurSecondColor = AppColors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: AnimatedContainer(duration: Duration(milliseconds: 100),
        padding: padding ?? const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: btnBackGround,
            boxShadow: isPressed ? [
              BoxShadow(
                color: blurFirstColor,
                offset: Offset(2, 2),
                blurRadius: 5,
                spreadRadius: 1
              ),
              BoxShadow(
                color: blurFirstColor,
                offset: Offset(-2, -2),
                blurRadius: 5,
                spreadRadius: 1
              )
            ] : [
              BoxShadow(
                  color: blurFirstColor,
                  offset: Offset(6, 6),
                  blurRadius: 8,
                  spreadRadius: 1
              ),
              BoxShadow(
                  color: blurFirstColor,
                  offset: Offset(-6, -6),
                  blurRadius: 8,
                  spreadRadius: 1
              )
            ]
          ),
      ),
    );
  }
}

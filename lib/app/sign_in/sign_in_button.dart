import 'package:ds_loyalty_user/common_widgets/custom_button.dart';
import 'package:flutter/cupertino.dart';

class SignInButton extends CustomButton {
  final double height;
  SignInButton({
    @required String text,
    Color color,
    Color textColor,
    VoidCallback onPressed,
    this.height: 50,
  }) : assert(text != null),
        super(
          child: Text(
            text,
            style: TextStyle(color: textColor, fontSize: 16),
          ),
          color: color,
          onPressed: onPressed,
          height: height,
        );
}

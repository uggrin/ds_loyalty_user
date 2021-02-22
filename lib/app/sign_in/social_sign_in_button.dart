import 'package:ds_loyalty_user/common_widgets/custom_button.dart';
import 'package:flutter/cupertino.dart';

class SocialSignInButton extends CustomButton {
  final double height;
  final double width;
  SocialSignInButton({
    @required String assetName,
    String text,
    Color color,
    Color textColor,
    VoidCallback onPressed,
    this.height: 50,
    this.width: 200,
  })  : assert(assetName != null),
        assert(text != null),
        super(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image.asset('assets/images/$assetName.png'),
              Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                ),
              ),
              Opacity(
                child: Image.asset('assets/images/$assetName.png'),
                opacity: 0,
              ),
            ],
          ),
          color: color,
          onPressed: onPressed,
          height: height,
        );
}

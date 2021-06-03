import 'package:ds_loyalty_user/common_widgets/custom_button.dart';
import 'package:flutter/material.dart';

class FormSubmitButton extends CustomButton {
  FormSubmitButton({
    required String text,
    VoidCallback? onPressed,
  }) : super(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 20,
            ),
          ),
          height: 44,
          color: Colors.amber,
          borderRadius: 4,
          onPressed: onPressed,
        );
}

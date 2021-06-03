import 'dart:async';

import 'package:ds_loyalty_user/app/helpers/format.dart';
import 'package:flutter/material.dart';

import 'input_dropdown.dart';

class DatePicker extends StatelessWidget {
  const DatePicker({
    Key? key,
    this.labelText,
    this.selectedDate,
    this.onSelectedDate,
  }) : super(key: key);

  final String? labelText;
  final DateTime? selectedDate;
  final ValueChanged<DateTime>? onSelectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate!,
      firstDate: DateTime(2020, 1),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      onSelectedDate!(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final valueStyle = Theme.of(context).textTheme.headline6;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          flex: 5,
          child: InputDropdown(
            labelText: labelText,
            valueText: Format.date(selectedDate!),
            valueStyle: valueStyle,
            onPressed: () => _selectDate(context),
          ),
        ),
      ],
    );
  }
}

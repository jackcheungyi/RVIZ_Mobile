import 'package:flutter/material.dart';
import 'package:ros_control/Pages/SubPages/generic_dialog.dart';


Future<void> showErrorDialog(
  BuildContext context,
  String text,
) {
  return showGenericDialog<void>(
    context: context,
    title: 'ERROR',
    content: text,
    optionsBuilder: () => {
      'OK': DialogOption(title: 'OK', color: Colors.black, value: null),
    },
  );
}

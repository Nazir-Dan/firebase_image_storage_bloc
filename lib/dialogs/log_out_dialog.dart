import 'package:firebase_image_storage_bloc/dialogs/generic_dialog.dart';
import 'package:flutter/widgets.dart';

Future<bool> showLogOutDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Log out',
    content: 'Are you sure you want to log out?',
    optionsBuilder: () => {
      'Cancel': false,
      'log out': true,
    },
  ).then((value) => value ?? false);
}

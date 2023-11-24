import 'package:firebase_image_storage_bloc/auth/auth_errors.dart';
import 'package:firebase_image_storage_bloc/dialogs/generic_dialog.dart';
import 'package:flutter/widgets.dart';

Future<void> showAuthErrorDialog(
    {required BuildContext context, required AuthError authError}) {
  return showGenericDialog<void>(
    context: context,
    title: authError.dialogTitle,
    content: authError.dialogText,
    optionsBuilder: () => {
      'Ok': true,
    },
  );
}

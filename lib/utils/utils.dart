import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toastification/toastification.dart';

pickImage(ImageSource source) async {
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _file = await _imagePicker.pickImage(source: source);

  if (_file != null) {
    return await _file.readAsBytes();
  }

  print("No Image Selected");
}

showToastNotification(String content, BuildContext context) {
  String tempStr = content.substring(content.indexOf(']') + 1);
  toastification.show(
    context: context, // optional if you use ToastificationWrapper
    type: content == "success"
        ? ToastificationType.success
        : ToastificationType.info,
    style: ToastificationStyle.fillColored,
    title: Text(tempStr),
    applyBlurEffect: true,
    alignment: Alignment.topRight,
    borderRadius: BorderRadius.circular(12),
    boxShadow: const [
      BoxShadow(
        color: Color(0x07000000),
        blurRadius: 16,
        offset: Offset(0, 16),
        spreadRadius: 0,
      )
    ],
  );
}

showSnackBar(String text, BuildContext context) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
    ),
  );
}

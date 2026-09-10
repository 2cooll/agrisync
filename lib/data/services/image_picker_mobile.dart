import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

Future<Uint8List?> pickImageCustom({required bool isCamera}) async {
  try {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: isCamera ? ImageSource.camera : ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked != null) {
      return await picked.readAsBytes();
    }
  } catch (_) {}
  return null;
}

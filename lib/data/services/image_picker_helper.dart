import 'dart:typed_data';
import 'image_picker_stub.dart'
    if (dart.library.html) 'image_picker_web.dart'
    if (dart.library.io) 'image_picker_mobile.dart';

class AppImagePicker {
  static Future<Uint8List?> pickImage({required bool isCamera}) async {
    return await pickImageCustom(isCamera: isCamera);
  }
}

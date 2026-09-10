// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';

Future<Uint8List?> pickImageCustom({required bool isCamera}) {
  final completer = Completer<Uint8List?>();
  final input = html.FileUploadInputElement();
  input.accept = 'image/*';
  if (isCamera) {
    input.setAttribute('capture', 'environment');
  }

  input.onChange.listen((event) {
    final files = input.files;
    if (files != null && files.isNotEmpty) {
      final file = files[0];
      final url = html.Url.createObjectUrlFromBlob(file);
      final img = html.ImageElement();
      img.src = url;

      img.onLoad.listen((_) {
        try {
          // Downscale to max 800x800 for optimal memory and storage quota
          const maxDim = 800;
          var width = img.naturalWidth;
          var height = img.naturalHeight;

          if (width == 0) width = img.width ?? 800;
          if (height == 0) height = img.height ?? 800;

          if (width > maxDim || height > maxDim) {
            if (width > height) {
              height = (height * (maxDim / width)).round();
              width = maxDim;
            } else {
              width = (width * (maxDim / height)).round();
              height = maxDim;
            }
          }

          final canvas = html.CanvasElement(width: width, height: height);
          final ctx = canvas.context2D;
          ctx.drawImageScaled(img, 0, 0, width, height);

          // Compress to JPEG 75% quality (~50KB-80KB)
          final dataUrl = canvas.toDataUrl('image/jpeg', 0.75);
          html.Url.revokeObjectUrl(url);

          final base64String = dataUrl.split(',').last;
          final bytes = base64Decode(base64String);
          completer.complete(bytes);
        } catch (err) {
          html.Url.revokeObjectUrl(url);
          // Fallback: read directly
          final reader = html.FileReader();
          reader.readAsArrayBuffer(file);
          reader.onLoadEnd.listen((_) {
            final res = reader.result;
            if (res is Uint8List) {
              completer.complete(res);
            } else if (res is List<int>) {
              completer.complete(Uint8List.fromList(res));
            } else {
              completer.complete(null);
            }
          });
          reader.onError.listen((_) => completer.complete(null));
        }
      });

      img.onError.listen((_) {
        html.Url.revokeObjectUrl(url);
        completer.complete(null);
      });
    } else {
      completer.complete(null);
    }
  });

  input.click();
  return completer.future;
}

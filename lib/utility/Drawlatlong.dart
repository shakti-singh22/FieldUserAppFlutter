import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';

class Drawlatlong {
  static img.Image drawlatlong(String path, String lat, String long) {
    final now = DateTime.now();
    final formatter = DateFormat('dd/MM/yyyy HH:mm a');
    final timestamp = formatter.format(now);

    final originalImage = img.decodeImage(File(path).readAsBytesSync());

    final img.Image watermarkedImage =
    img.copyResize(originalImage!, width: 480, height: 680);

    img.drawString(
      watermarkedImage,
      x: 12,
      y: 580,
      'Date: $timestamp\nLat: ${lat ?? ""}/ Long: ${long ?? ""}',
      font: img.arial14,
      color: img.ColorRgb8(255, 0, 0), // ✅ Correct for v4
    );

    return watermarkedImage;
  }
}

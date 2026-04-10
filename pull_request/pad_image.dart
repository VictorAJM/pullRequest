import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final file = File('assets/icons/pullRequest.png');
  final image = img.decodeImage(file.readAsBytesSync());
  if (image == null) {
    print('Failed to load image');
    exit(1);
  }

  // Create a canvas that is about 1.7x the size to add plenty of margin
  final canvasSize = (image.width * 1.7).toInt();

  // Create empty image
  final canvas = img.Image(width: canvasSize, height: canvasSize, numChannels: 4);

  // Calculate position to center the original image
  final dstX = (canvasSize - image.width) ~/ 2;
  final dstY = (canvasSize - image.height) ~/ 2;

  // Draw the original image onto the canvas center
  img.compositeImage(canvas, image, dstX: dstX, dstY: dstY);

  // Save the new image
  File('assets/icons/pullRequest_splash.png').writeAsBytesSync(img.encodePng(canvas));
  print('Padded image generated successfully!');
}

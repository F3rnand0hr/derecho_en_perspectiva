import 'package:flutter/services.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:image/image.dart' as img;

/// Renders every page of the PDF at [assetPath] into in‑memory PNGs.
Future<List<Uint8List>> renderPdfAsImages(String assetPath) async {
  // 1) Open the PDF
  final data = await rootBundle.load(assetPath);
  final pdfBytes = data.buffer.asUint8List();

  final doc = await PdfDocument.openData(pdfBytes);
  final images = <Uint8List>[];

  // 2) Loop through pages
  for (var i = 1; i <= doc.pageCount; i++) {
    final page = await doc.getPage(i);
    final pageImg = await page.render(
      width: page.width.toInt(),
      height: page.height.toInt(),
    );
    final raw = pageImg.pixels;
    final frame = img.Image.fromBytes(
      width: pageImg.width,
      height: pageImg.height,
      bytes: raw.buffer,
      numChannels: 4,
    );
    images.add(Uint8List.fromList(img.encodePng(frame)));
  }

  // 7) Clean up the document
  doc.dispose();

  return images;
}

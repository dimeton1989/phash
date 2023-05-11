import 'package:image/image.dart';
import 'dart:math' show cos, pi, sqrt;

List<double> _calculateDCT(List<double> matrix) {
  List<double> transformed = [];

  for (int i = 0; i < matrix.length; i++) {
    double sum = 0.0;
    for (int j = 0; j < matrix.length; j++) {
      sum += matrix[j] * cos((i * pi * (j + 0.5)) / matrix.length);
    }
    sum *= sqrt(2 / matrix.length);
    if (i == 0) sum *= 1 / sqrt(2);
    transformed.add(sum);
  }

  return transformed;
}

double _toGrayScale(Pixel pixel) {
  return pixel.r * 0.299 + pixel.g * 0.587 + pixel.b * 0.114;
}

List<List<double>> _rows(ImageData data) {
  List<List<double>> rows = [];
  for (int y = 0; y < data.height; y++) {
    List<double> row = [];
    for (int x = 0; x < data.width; x++) {
      row.add(_toGrayScale(data.getPixel(x, y)));
    }
    rows.add(_calculateDCT(row));
  }
  return rows;
}

List<List<double>> _matrix(List<List<double>> rows) {
  List<List<double>> matrix = [];
  for (int x = 0; x < 32; x++) {
    List<double> col = [];
    for (int y = 0; y < 32; y++) {
      col.add(rows[y][x]);
    }
    matrix.add(_calculateDCT(col));
  }
  return matrix;
}

List<double> _values(List<List<double>> matrix) {
  List<double> values = [];
  for (int y = 0; y < 8; y++) {
    for (int x = 0; x < 8; x++) {
      values.add(matrix[y][x]);
    }
  }
  return values;
}

double _average(List<double> values) {
  final n = values.length - 1;
  return values.sublist(1, n).reduce((a, b) => a + b) / n;
}

String _hex(List<double> values, double average) {
  final hex = StringBuffer();
  int byte = 0;
  int counter = 0;
  for (final value in values) {
    byte <<= 1;
    byte += value > average ? 1 : 0;
    counter += 1;
    if (counter % 4 != 0) continue;
    hex.write(byte.toRadixString(16));
    byte = 0;
    counter = 0;
  }
  return hex.toString();
}

String phash(Image image) {
  final values = _values(
    _matrix(
      _rows(
        copyResize(image, width: 32, height: 32).data!,
      ),
    ),
  );

  return _hex(
    values,
    _average(values),
  );
}
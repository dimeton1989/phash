import 'package:args/args.dart';
import 'package:phash/phash.dart';
import 'package:image/image.dart';
import 'dart:io';
import 'package:path/path.dart' show absolute;

final home = Platform.isWindows ? absolute(Platform.environment['USERPROFILE'] ?? '') : absolute(Platform.environment['HOME'] ?? '');

Future<void> main(Iterable<String> args) async {
  final result = (ArgParser()..addOption('IFS', abbr: 'i', defaultsTo: '\n')).parse(args);
  final hashes = await Stream.fromIterable(result.rest)
      .map((path) => path.replaceFirst('~', home))
      .asyncMap((path) => decodeImageFile(path))
      .where((image) => image != null)
      .cast<Image>()
      .asyncMap((image) => phash(image))
      .toList();
  print(hashes.join(result['IFS']));
}

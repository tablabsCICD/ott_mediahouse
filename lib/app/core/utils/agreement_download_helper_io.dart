import 'dart:io' as io;
import 'dart:typed_data';

import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

Future<void> saveAgreementFile(Uint8List bytes, String fileName) async {
  final directory = await getTemporaryDirectory();
  final file = io.File('${directory.path}${io.Platform.pathSeparator}$fileName');
  await file.writeAsBytes(bytes, flush: true);
  await OpenFile.open(file.path);
}

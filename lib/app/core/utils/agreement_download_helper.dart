import 'dart:typed_data';

import 'agreement_download_helper_stub.dart'
    if (dart.library.html) 'agreement_download_helper_web.dart'
    if (dart.library.io) 'agreement_download_helper_io.dart' as impl;

Future<void> saveAgreementFile(Uint8List bytes, String fileName) {
  return impl.saveAgreementFile(bytes, fileName);
}

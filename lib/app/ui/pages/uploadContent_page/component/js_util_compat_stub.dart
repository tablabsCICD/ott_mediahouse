T allowInterop<T extends Function>(T function) => function;

dynamic getProperty(dynamic object, dynamic name) {
  throw UnsupportedError('js_util is only available on web targets.');
}

T callConstructor<T>(dynamic constructor, List<dynamic> arguments) {
  throw UnsupportedError('js_util is only available on web targets.');
}

T callMethod<T>(dynamic object, String method, List<dynamic> arguments) {
  throw UnsupportedError('js_util is only available on web targets.');
}

dynamic jsify(dynamic object) {
  throw UnsupportedError('js_util is only available on web targets.');
}

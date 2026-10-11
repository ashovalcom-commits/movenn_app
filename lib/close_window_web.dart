import 'dart:js_interop' as js;

@js.JS('window.close')
external void _jsCloseWindow();

void closeWindow() => _jsCloseWindow();

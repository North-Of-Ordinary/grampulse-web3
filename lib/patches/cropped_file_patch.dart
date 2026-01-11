import 'dart:typed_data';
import 'package:typed_data/typed_data.dart';

// This extension adds the UnmodifiableUint8ListView method to the Uint8List class
extension Uint8ListExtension on Uint8List {
  Uint8List UnmodifiableUint8ListView(Uint8List list) {
    return Uint8List.fromList(list);
  }
}

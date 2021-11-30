import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';

class Magnetica {
  static Magnetica? _instance;

  factory Magnetica() {
    _instance ??= Magnetica._private();
    return _instance!;
  }

  Magnetica._private();

  static Map<String, Function> hotKeyFunctions = {};

  static const MethodChannel _channel = MethodChannel('magnetica');

  static const EventChannel _eventChannel = EventChannel('magnetica/stream');

  Stream<String>? _onStreamChanged;

  void createStream() {
    _onStreamChanged ??= _eventChannel
        .receiveBroadcastStream()
        .map((dynamic event) => event as String);
    _onStreamChanged?.listen(_onEvent, onError: _onError);
  }

  void _onEvent(Object? event) {
    hotKeyFunctions[event]!();
  }

  void _onError(Object error) {
    print(error);
  }

  static Future<void> receiveBroadcastStream(
      void Function(dynamic) onEvent, Function onError) async {}

  static Future<void> register(
      {required KeyCombo keyCombo,
      required String hotKeyName,
      required Function hotKeyFunction}) async {
    await _channel.invokeMethod('register', <String, dynamic>{
      "keyCombo": keyCombo.encode,
      "hotKeyName": hotKeyName,
    });
    hotKeyFunctions[hotKeyName] = hotKeyFunction;
  }

  static Future<void> unregister({required String hotKeyName}) async {
    await _channel.invokeMethod('unregister', <String, dynamic>{
      "hotKeyName": hotKeyName,
    });
    hotKeyFunctions.removeWhere((key, _) => key == hotKeyName);
  }

  static Future<void> get unregisterAll async {
    await _channel.invokeMethod('unregisterAll');
  }
}

enum Modifier { shift, control, option, command }

extension on Modifier {
  int encode() {
    switch (this) {
      case Modifier.shift:
        return 512;
      case Modifier.control:
        return 4096;
      case Modifier.option:
        return 2048;
      case Modifier.command:
        return 256;
      default:
        return 0;
    }
  }
}

typedef Modifiers = List<Modifier>;

extension on Modifiers {
  int encode() {
    return fold(0, (int value, Modifier element) {
      return value + element.encode();
    });
  }
}

class KeyCombo {
  KeyCombo({required this.key, this.modifiers = const []});

  final KeyCharacter key;
  final Modifiers modifiers;

  Uint8List get encode {
    return Uint8List.fromList(json.encode({
      "key": key.encode(),
      "doubledModifiers": false,
      "modifiers": modifiers.encode()
    }).codeUnits);
  }
}

enum KeyCharacter {
  one,
  two,
  three,
  four,
  five,
  six,
  seven,
  eight,
  nine,
  zero,
  hyphen,
  circumflex,
  backslash,
  q,
  w,
  e,
  r,
  t,
  y,
  u,
  i,
  o,
  p,
  atmark,
  openingBracket,
  a,
  s,
  d,
  f,
  g,
  h,
  j,
  k,
  l,
  semicolon,
  colon,
  closingBracket,
  z,
  x,
  c,
  v,
  b,
  n,
  m,
  comma,
  dot,
  slash,
  underscore,
  tab,
  enter,
  backspace,
  up,
  right,
  down,
  left,
  eisu,
  kana,
}

extension on KeyCharacter {
  String encode() {
    switch (this) {
      case KeyCharacter.one:
        return "1";
      case KeyCharacter.two:
        return "2";
      case KeyCharacter.three:
        return "3";
      case KeyCharacter.four:
        return "4";
      case KeyCharacter.five:
        return "5";
      case KeyCharacter.six:
        return "6";
      case KeyCharacter.seven:
        return "7";
      case KeyCharacter.eight:
        return "8";
      case KeyCharacter.nine:
        return "9";
      case KeyCharacter.zero:
        return "0";
      case KeyCharacter.hyphen:
        return "-";
      case KeyCharacter.circumflex:
        return "^";
      case KeyCharacter.backslash:
        return "\\";
      case KeyCharacter.q:
        return "q";
      case KeyCharacter.w:
        return "w";
      case KeyCharacter.e:
        return "e";
      case KeyCharacter.r:
        return "r";
      case KeyCharacter.t:
        return "t";
      case KeyCharacter.y:
        return "y";
      case KeyCharacter.u:
        return "u";
      case KeyCharacter.i:
        return "i";
      case KeyCharacter.o:
        return "o";
      case KeyCharacter.p:
        return "p";
      case KeyCharacter.atmark:
        return "@";
      case KeyCharacter.openingBracket:
        return "[";
      case KeyCharacter.a:
        return "a";
      case KeyCharacter.s:
        return "s";
      case KeyCharacter.d:
        return "d";
      case KeyCharacter.f:
        return "f";
      case KeyCharacter.g:
        return "g";
      case KeyCharacter.h:
        return "h";
      case KeyCharacter.j:
        return "j";
      case KeyCharacter.k:
        return "k";
      case KeyCharacter.l:
        return "l";
      case KeyCharacter.semicolon:
        return ";";
      case KeyCharacter.colon:
        return ":";
      case KeyCharacter.closingBracket:
        return "]";
      case KeyCharacter.z:
        return "z";
      case KeyCharacter.x:
        return "x";
      case KeyCharacter.c:
        return "c";
      case KeyCharacter.v:
        return "v";
      case KeyCharacter.b:
        return "b";
      case KeyCharacter.n:
        return "n";
      case KeyCharacter.m:
        return "m";
      case KeyCharacter.comma:
        return ",";
      case KeyCharacter.dot:
        return ".";
      case KeyCharacter.slash:
        return "/";
      case KeyCharacter.underscore:
        return "_";
      case KeyCharacter.tab:
        return "tab";
      case KeyCharacter.enter:
        return "enter";
      case KeyCharacter.backspace:
        return "backspace";
      case KeyCharacter.up:
        return "↑";
      case KeyCharacter.right:
        return "→";
      case KeyCharacter.down:
        return "↓";
      case KeyCharacter.left:
        return "←";
      case KeyCharacter.eisu:
        return "英数";
      case KeyCharacter.kana:
        return "かな";
      default:
        return "";
    }
  }
}

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

  static final Map<String, Function> _hotKeyFunctions = {};

  static const MethodChannel _channel = MethodChannel('magnetica');

  static const EventChannel _eventChannel = EventChannel('magnetica/stream');

  static Stream<String>? _onStreamChanged;

  static void createStream() {
    if (_onStreamChanged != null) {
      return;
    }
    _onStreamChanged ??= _eventChannel
        .receiveBroadcastStream()
        .map((dynamic event) => event as String);
    _onStreamChanged?.listen(_onEvent, onError: _onError);
  }

  static void _onEvent(Object? event) {
    _hotKeyFunctions[event]!();
  }

  static void _onError(Object error) {
    throw(error);
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
    _hotKeyFunctions[hotKeyName] = hotKeyFunction;
  }

  static Future<void> unregister({required String hotKeyName}) async {
    await _channel.invokeMethod('unregister', <String, dynamic>{
      "hotKeyName": hotKeyName,
    });
    _hotKeyFunctions.removeWhere((key, _) => key == hotKeyName);
  }

  static Future<void> get unregisterAll async {
    await _channel.invokeMethod('unregisterAll');
  }
}

enum Modifier { shift, control, option, command }

extension ModifierExtension on Modifier {
  static Modifier fromString(String modifier) {
    switch (modifier) {
      case "shift":
        return Modifier.shift;
      case "control":
        return Modifier.control;
      case "option":
        return Modifier.option;
      case "command":
        return Modifier.command;
      default:
        return throw "unsupported string";
    }
  }

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

  static KeyCombo fromJSON(dynamic json) {

    return KeyCombo(key: KeyCharacter.b, modifiers: [Modifier.command]);
  }


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
  caret,
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
  at,
  leftBracket,
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
  rightBracket,
  z,
  x,
  c,
  v,
  b,
  n,
  m,
  comma,
  period,
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

extension KeyCharacterExtension on KeyCharacter {
  static KeyCharacter fromString(String modifier) {
    switch (modifier) {
      case "1":
        return KeyCharacter.one;
      case "2":
        return KeyCharacter.two;
      case "3":
        return KeyCharacter.three;
      case "4":
        return KeyCharacter.four;
      case "5":
        return KeyCharacter.five;
      case "6":
        return KeyCharacter.six;
      case "7":
        return KeyCharacter.seven;
      case "8":
        return KeyCharacter.eight;
      case "9":
        return KeyCharacter.nine;
      case "0":
        return KeyCharacter.zero;
      case "-":
        return KeyCharacter.hyphen;
      case "^":
        return KeyCharacter.caret;
      case "\\":
        return KeyCharacter.backslash;
      case "q":
        return KeyCharacter.q;
      case "w":
        return KeyCharacter.w;
      case "e":
        return KeyCharacter.e;
      case "r":
        return KeyCharacter.r;
      case "t":
        return KeyCharacter.t;
      case "y":
        return KeyCharacter.y;
      case "u":
        return KeyCharacter.u;
      case "i":
        return KeyCharacter.i;
      case "o":
        return KeyCharacter.o;
      case "p":
        return KeyCharacter.p;
      case "@":
        return KeyCharacter.at;
      case "[":
        return KeyCharacter.leftBracket;
      case "a":
        return KeyCharacter.a;
      case "s":
        return KeyCharacter.s;
      case "d":
        return KeyCharacter.d;
      case "f":
        return KeyCharacter.f;
      case "g":
        return KeyCharacter.g;
      case "h":
        return KeyCharacter.h;
      case "j":
        return KeyCharacter.j;
      case "k":
        return KeyCharacter.k;
      case "l":
        return KeyCharacter.l;
      case ";":
        return KeyCharacter.semicolon;
      case ":":
        return KeyCharacter.colon;
      case "]":
        return KeyCharacter.rightBracket;
      case "z":
        return KeyCharacter.z;
      case "x":
        return KeyCharacter.x;
      case "c":
        return KeyCharacter.c;
      case "v":
        return KeyCharacter.v;
      case "b":
        return KeyCharacter.b;
      case "n":
        return KeyCharacter.n;
      case "m":
        return KeyCharacter.m;
      case ",":
        return KeyCharacter.comma;
      case ".":
        return KeyCharacter.period;
      case "/":
        return KeyCharacter.slash;
      case "_":
        return KeyCharacter.underscore;
      case "tab":
        return KeyCharacter.tab;
      case "enter":
        return KeyCharacter.enter;
      case "backspace":
        return KeyCharacter.backspace;
      case "up":
        return KeyCharacter.up;
      case "right":
        return KeyCharacter.right;
      case "down":
        return KeyCharacter.down;
      case "left":
        return KeyCharacter.left;
      case "eisu":
        return KeyCharacter.eisu;
      case "kana":
        return KeyCharacter.kana;
      default:
        return throw "unsupported string";
    }
  }


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
      case KeyCharacter.caret:
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
      case KeyCharacter.at:
        return "@";
      case KeyCharacter.leftBracket:
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
      case KeyCharacter.rightBracket:
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
      case KeyCharacter.period:
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
        return "up";
      case KeyCharacter.right:
        return "right";
      case KeyCharacter.down:
        return "down";
      case KeyCharacter.left:
        return "left";
      case KeyCharacter.eisu:
        return "eisu";
      case KeyCharacter.kana:
        return "kana";
      default:
        return throw "unsupported KeyCharacter";
    }
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:magnetica/magnetica.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    Magnetica.createStream();
    super.initState();
  }

  Future<void> registerCommandBHotKey() async {
    final keyCombo =
        KeyCombo(key: KeyCharacter.b, modifiers: [Modifier.command]);
    await Magnetica.register(
        keyCombo: keyCombo,
        hotKeyName: "commandB",
        hotKeyFunction: () {
          print("pressed command B");
        });
  }

  Future<void> registerCommandEnterHotKey() async {
    final keyCombo =
        KeyCombo(key: KeyCharacter.enter, modifiers: [Modifier.command]);
    await Magnetica.register(
        keyCombo: keyCombo,
        hotKeyName: "commandEnter",
        hotKeyFunction: () {
          print("pressed command Enter");
        });
  }

  Future<void> unregisterCommandBHotKey() async {
    await Magnetica.unregister(hotKeyName: "commandB");
  }

  Future<void> registerCtrlCommandAHotKey() async {
    final keyCombo = KeyCombo(
        key: KeyCharacter.a, modifiers: [Modifier.control, Modifier.command]);
    await Magnetica.register(
        keyCombo: keyCombo,
        hotKeyName: "ctrlCommandA",
        hotKeyFunction: () {
          print("pressed ctrl command A");
        });
  }

  Future<void> unregister() async {
    await Magnetica.unregisterAll;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Magnetica example app'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: registerCommandBHotKey,
                child: const Text('Register shortcut cmd+b'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: registerCtrlCommandAHotKey,
                child: const Text('Register shortcut ctrl+cmd+a'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: registerCommandEnterHotKey,
                child: const Text('Register shortcut cmd+enter'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: unregisterCommandBHotKey,
                child: const Text('Unregister shortcut cmd+b'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: unregister,
                child: const Text('Clear shortcut'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

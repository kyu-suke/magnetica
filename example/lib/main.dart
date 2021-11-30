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
    Magnetica().createStream();
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
                child: const Text('Register shortcut cmd+b'),
                onPressed: registerCommandBHotKey,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text('Register shortcut ctrl+cmd+a'),
                onPressed: registerCtrlCommandAHotKey,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text('Unregister shortcut cmd+b'),
                onPressed: unregisterCommandBHotKey,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text('Clear shortcut'),
                onPressed: unregister,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

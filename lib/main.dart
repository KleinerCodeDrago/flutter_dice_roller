import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math' as math;
import 'package:three_dart/three_dart.dart' as THREE;
import 'package:flutter_gl/flutter_gl.dart';

void main() {
  runApp(DiceRollerApp());
}

THREE.Mesh generateDice(int sides) {
  final geometry = THREE.BoxGeometry(1, 1, 1);
  final material = THREE.MeshBasicMaterial(
      {'color': 0xffffff}); // Corrected parameters to Map
  final dice = THREE.Mesh(geometry, material);

  // Add dice faces based on the number of sides
  for (int i = 0; i < sides; i++) {
    final dot = THREE.Mesh(
      THREE.SphereGeometry(0.1, 16, 16),
      THREE.MeshBasicMaterial(
          {'color': 0x000000}), // Corrected parameters to Map
    );

    // Position the dot on the dice face
    final angle = i * (math.pi * 2) / sides;
    final x = 0.5 * math.cos(angle);
    final y = 0.5 * math.sin(angle);
    dot.position.set(x, y, 0.5); // Corrected method name

    dice.add(dot);
  }

  return dice;
}

class DiceRollerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '3D Dice Roller',
      home: DiceRollerPage(),
    );
  }
}

class DiceRollerPage extends StatefulWidget {
  @override
  _DiceRollerPageState createState() => _DiceRollerPageState();
}

class _DiceRollerPageState extends State<DiceRollerPage> {
  late THREE.Scene _scene;
  late THREE.Camera _camera;
  List<THREE.Mesh> _diceList = [];
  bool _useShake = false;
  bool _useGravity = false;

  @override
  void initState() {
    super.initState();
    accelerometerEvents.listen((AccelerometerEvent event) {
      if (_useShake && event.x.abs() > 20 ||
          event.y.abs() > 20 ||
          event.z.abs() > 20) {
        _rollDice();
      }
    });
  }

  void _addDice(int sides) {
    final dice = generateDice(sides);
    dice.rotation.x = math.Random().nextDouble() * 2 * math.pi;
    dice.rotation.y = math.Random().nextDouble() * 2 * math.pi;
    dice.rotation.z = math.Random().nextDouble() * 2 * math.pi;
    _scene.add(dice);
    _diceList.add(dice);
  }

  void _rollDice() {
    for (final dice in _diceList) {
      final newRotation = THREE.Vector3(
        math.Random().nextDouble() * 2 * math.pi,
        math.Random().nextDouble() * 2 * math.pi,
        math.Random().nextDouble() * 2 * math.pi,
      );

      dice.rotation.setFromVector3(newRotation);

      if (_useGravity) {
        // Apply a random torque to simulate gravity
        final torque = THREE.Vector3(
          math.Random().nextDouble() * 2 - 1,
          math.Random().nextDouble() * 2 - 1,
          math.Random().nextDouble() * 2 - 1,
        );
        // Corrected torque application
        dice.rotation.setFromVector3(
            dice.rotation.toVector3().add(torque.multiplyScalar(0.1)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('3D Dice Roller')),
      body: Column(
        children: [
          Expanded(
            child: THREE.WebGLRenderer(
              // Corrected to WebGLRenderer
              onRendererCreated: (renderer) {
                _scene = THREE.Scene();
                _scene.background = THREE.Color(0xffffff);

                _camera = THREE.PerspectiveCamera(45, 1, 1, 1000);
                _camera.position.z = 5;
                _scene.add(_camera);
              },
            ),
          ),
          Row(
            children: [
              ElevatedButton(
                child: Text('D4'),
                onPressed: () => _addDice(4),
              ),
              ElevatedButton(
                child: Text('D6'),
                onPressed: () => _addDice(6),
              ),
              ElevatedButton(
                child: Text('D8'),
                onPressed: () => _addDice(8),
              ),
              ElevatedButton(
                child: Text('D10'),
                onPressed: () => _addDice(10),
              ),
              ElevatedButton(
                child: Text('D12'),
                onPressed: () => _addDice(12),
              ),
              ElevatedButton(
                child: Text('D20'),
                onPressed: () => _addDice(20),
              ),
            ],
          ),
          Row(
            children: [
              Text('Roll by shaking:'),
              Switch(
                value: _useShake,
                onChanged: (value) => setState(() => _useShake = value),
              ),
              Text('Use gravity:'),
              Switch(
                value: _useGravity,
                onChanged: (value) => setState(() => _useGravity = value),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.casino),
        onPressed: _rollDice,
      ),
    );
  }
}

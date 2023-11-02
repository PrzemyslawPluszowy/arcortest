import 'package:ar_geometric_shapes_app/custom_3d_objects_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter AR Geometric Shapes App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const Camera3d());
  }
}

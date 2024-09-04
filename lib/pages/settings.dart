import '../config/global_preference.dart'; // Ensure this imports the correct API class
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // This variable will be used to display the current zoom level on the Slider
  double _currentZoom = API.zoom;
  double _seZoom = API.seZoom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Added padding for better UI
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              '加载地图时缩放大小',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16), // Add space between text and slider
            Slider(
              value: _currentZoom,
              min: 10, // Minimum zoom level
              max: 30, // Maximum zoom level
              divisions: 20, // Number of steps in the slider
              label: _currentZoom.toStringAsFixed(1), // Show current zoom value
              onChanged: (double value) {
                setState(() {
                  _currentZoom = value; // Update the local state
                  API.zoom = value; // Update the global zoom value
                });
              },
            ),
            Text(
              '当前缩放等级: ${_currentZoom.toStringAsFixed(1)}',
              style: const TextStyle(fontSize: 14),
            ),
            const Divider(
              height: 20,
              thickness: 1,
              color: Colors.grey,
            ),
            const Text(
              '跳转定位时缩放大小',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16), // Add space between text and slider
            Slider(
              value: _seZoom,
              min: 20, // Minimum zoom level
              max: 30, // Maximum zoom level
              divisions: 10, // Number of steps in the slider
              label: _seZoom.toStringAsFixed(1), // Show current zoom value
              onChanged: (double value) {
                setState(() {
                  _seZoom = value; // Update the local state
                  API.seZoom = value; // Update the global zoom value
                });
              },
            ),
            Text(
              '当前缩放等级: ${_seZoom.toStringAsFixed(1)}',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

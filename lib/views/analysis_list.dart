// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class AnalysisList extends StatelessWidget {
  AnalysisList({
    super.key,
    required this.packages,
    required this.isDetected,
  });

  List<String> packages;
  bool isDetected;

  @override
  Widget build(BuildContext context) {
    if (packages.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          isDetected
              ? 'No linter packages detected.'
              : 'All required linter packages are installed!',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: packages.length,
      itemBuilder: (context, index) {
        return Card(
          color: isDetected ? Colors.green.shade50 : Colors.red.shade50,
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            leading: Icon(
              isDetected ? Icons.check_circle : Icons.warning,
              color: isDetected ? Colors.green : Colors.red,
            ),
            title: Text(
              packages[index],
              style: const TextStyle(fontSize: 16),
            ),
          ),
        );
      },
    );
  }
}

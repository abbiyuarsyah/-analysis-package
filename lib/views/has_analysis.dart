import 'package:flutter/material.dart';

class HasAnalysis extends StatelessWidget {
  const HasAnalysis({super.key, required this.hasAnalysisOptions});

  final bool hasAnalysisOptions;

  @override
  Widget build(Object context) {
    return Card(
      elevation: 2,
      color: hasAnalysisOptions ? Colors.green.shade50 : Colors.red.shade50,
      child: ListTile(
        leading: Icon(
          hasAnalysisOptions ? Icons.check_circle : Icons.error,
          color: hasAnalysisOptions ? Colors.green : Colors.red,
        ),
        title: Text(
          hasAnalysisOptions
              ? 'analysis_options.yaml is present'
              : 'analysis_options.yaml is missing',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: hasAnalysisOptions ? Colors.green : Colors.red,
          ),
        ),
        subtitle: const Text(
          'This file is used to define static analysis rules for your project.',
          style: TextStyle(fontSize: 14),
        ),
      ),
    );
  }
}

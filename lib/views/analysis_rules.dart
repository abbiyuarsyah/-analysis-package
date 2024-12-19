import 'package:flutter/material.dart';

class AnalyisRules extends StatelessWidget {
  const AnalyisRules({super.key, required this.rules});

  final Map<String, dynamic> rules;

  @override
  Widget build(BuildContext context) {
    if (rules.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          'No rules found.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rules.length,
      itemBuilder: (context, index) {
        final key = rules.keys.elementAt(index);
        final value = rules[key];

        return Card(
          color: Colors.blue.shade50,
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            title: Text(
              key,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              value.toString(),
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

class AnalyisRules extends StatefulWidget {
  const AnalyisRules({super.key, required this.rules});

  final Map<String, dynamic> rules;

  @override
  State<AnalyisRules> createState() => _AnalyisRulesState();
}

class _AnalyisRulesState extends State<AnalyisRules> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return ExpansionPanelList(
      elevation: 2,
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      children: [
        ExpansionPanel(
          headerBuilder: (context, isExpanded) {
            return const ListTile(
              title: Text(
                'Linter Rules',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
          body: widget.rules.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'No rules found.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.rules.length,
                  itemBuilder: (context, index) {
                    final key = widget.rules.keys.elementAt(index);
                    final value = widget.rules[key];

                    return Card(
                      color: Colors.blue.shade50,
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        trailing: SizedBox(
                          width: 140,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: Text(value ? 'Disable' : 'Enable'),
                          ),
                        ),
                        title: Text(
                          key,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          value.toString(),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    );
                  },
                ),
          isExpanded: _isExpanded,
        ),
      ],
    );
  }
}

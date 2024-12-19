import 'package:analysis_package/analysis_package.dart';
import 'package:analysis_package/views/analysis_list.dart';
import 'package:analysis_package/views/analysis_rules.dart';
import 'package:analysis_package/views/button_add_package.dart';
import 'package:analysis_package/views/has_analysis.dart';
import 'package:flutter/material.dart';

class AnalysisView extends StatefulWidget {
  final String projectPath;

  const AnalysisView({Key? key, required this.projectPath}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AnalysisViewState createState() => _AnalysisViewState();
}

class _AnalysisViewState extends State<AnalysisView> {
  late AnalysisChceker checker;
  Map<String, dynamic> linterResults = {};
  List<String> missingPackages = [];

  @override
  void initState() {
    super.initState();
    checker = AnalysisChceker(widget.projectPath);
    linterResults = checker.scan();
  }

  @override
  Widget build(BuildContext context) {
    final packages = linterResults['linter_packages'] as List<String>? ?? [];
    missingPackages = linterResults['missing_packages'] as List<String>? ?? [];
    final rules = linterResults['linter_rules'] as Map<String, dynamic>? ?? {};
    final hasAnalysisOptions =
        linterResults['has_analysis_options'] as bool? ?? false;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _TitleLabel(
              icon: Icons.check_circle,
              title: 'Packages',
              iconColor: Colors.green,
            ),
            AnalysisList(packages: packages, isDetected: true),
            const SizedBox(height: 24),
            const _TitleLabel(
              icon: Icons.warning_amber_rounded,
              title: 'Missing Packages',
              iconColor: Colors.red,
            ),
            AnalysisList(packages: missingPackages, isDetected: false),
            const SizedBox(height: 24),
            const _TitleLabel(
              icon: Icons.rule_sharp,
              title: 'Linter Rules',
              iconColor: Colors.blue,
            ),
            AnalyisRules(rules: rules),
            const SizedBox(height: 24),
            HasAnalysis(hasAnalysisOptions: hasAnalysisOptions),
            const SizedBox(height: 24),
            ButtonAddPackage(
              onPressed: () {
                checker.addPackages(missingPackages);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Action executed!'),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

class _TitleLabel extends StatelessWidget {
  const _TitleLabel({
    required this.icon,
    required this.title,
    required this.iconColor,
  });

  final IconData icon;
  final String title;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: iconColor,
          size: 28,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

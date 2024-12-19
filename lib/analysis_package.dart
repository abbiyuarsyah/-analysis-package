// ignore_for_file: avoid_print

import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';
import 'package:yaml_writer/yaml_writer.dart';

const packages = [
  'flutter_lints',
  'very_good_analysis',
  'custom_lint',
  'analyzer',
];

class AnalysisChceker {
  final String projectPath;

  AnalysisChceker(this.projectPath);

  /// Checks if analysis_options.yaml exists.
  bool hasAnalysisOptions() {
    final file = File(p.join(projectPath, 'analysis_options.yaml'));
    return file.existsSync();
  }

  /// Reads `analysis_options.yaml` and checks for linter rules.
  Map<String, dynamic> checkLinterRules() {
    final file = File(p.join(projectPath, 'analysis_options.yaml'));
    if (!file.existsSync()) {
      return {};
    }

    final content = file.readAsStringSync();
    final yaml = loadYaml(content);

    if (yaml is YamlMap && yaml.containsKey('linter')) {
      final linterSection = yaml['linter'];

      if (linterSection is YamlMap && linterSection.containsKey('rules')) {
        final rules = linterSection['rules'];
        if (rules is YamlMap) {
          return Map<String, dynamic>.from(rules);
        }
      }
    }

    return {};
  }

  /// Reads `pubspec.yaml` and checks for linter or static analysis packages.
  List<String> checkPackages() {
    final file = File(p.join(projectPath, 'pubspec.yaml'));
    if (!file.existsSync()) {
      return [];
    }

    final content = file.readAsStringSync();
    final yaml = loadYaml(content);

    if (yaml is YamlMap) {
      final dependencies = yaml['dependencies'] as YamlMap?;
      final devDependencies = yaml['dev_dependencies'] as YamlMap?;
      final linterPackages = <String>[];

      for (final package in packages) {
        if (dependencies?.containsKey(package) == true ||
            devDependencies?.containsKey(package) == true) {
          linterPackages.add(package);
        }
      }

      return linterPackages;
    }

    return [];
  }

  /// Adds missing linter packages to `pubspec.yaml` under `dev_dependencies`.
  void addPackages(List<String> missingPackages) {
    final file = File(p.join(projectPath, 'pubspec.yaml'));
    if (!file.existsSync()) {
      print('pubspec.yaml not found in the project directory.');
      return;
    }

    final content = file.readAsStringSync();
    final yaml = loadYaml(content);

    final updatedYaml = Map<String, dynamic>.from(yaml);

    if (!updatedYaml.containsKey('dev_dependencies')) {
      updatedYaml['dev_dependencies'] = {};
    }

    final devDependencies =
        Map<String, dynamic>.from(updatedYaml['dev_dependencies']);
    for (final package in missingPackages) {
      if (!devDependencies.containsKey(package)) {
        devDependencies[package] = 'any';
      }
    }
    updatedYaml['dev_dependencies'] = devDependencies;

    final writer = YamlWriter();
    final updatedContent = writer.write(updatedYaml);

    file.writeAsStringSync(updatedContent);

    print('Missing packages added to pubspec.yaml: $missingPackages');
  }

  /// Scan the project and handle linter packages.
  Map<String, dynamic> scan({bool addMissingPackages = false}) {
    final hasLinterFile = hasAnalysisOptions();
    final linterRules = checkLinterRules();
    final analysisPackage = checkPackages();
    final missingPackages =
        packages.where((pkg) => !analysisPackage.contains(pkg)).toList();

    if (addMissingPackages && missingPackages.isNotEmpty) {
      addPackages(missingPackages);

      final result = Process.runSync(
        'flutter',
        ['pub', 'get'],
        workingDirectory: projectPath,
      );
      print(result.stdout);

      if (result.exitCode != 0) {
        print('Failed to run `flutter pub get`: ${result.stderr}');
      }
    }

    return {
      'has_analysis_options': hasLinterFile,
      'linter_rules': linterRules,
      'packages': packages,
      'missing_packages': missingPackages,
    };
  }
}

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
    Map<String, dynamic> result = {};
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
          result = Map<String, dynamic>.from(rules);
          result.addAll(additionalRules);
          return result;
        }
      }
    }

    return result;
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

const Map<String, bool> additionalRules = {
  "always_declare_return_types": true,
  "always_require_non_null_named_parameters": true,
  "always_use_package_imports": true,
  "annotate_overrides": true,
  "avoid_bool_literals_in_conditional_expressions": true,
  "avoid_catching_errors": true,
  "avoid_double_and_int_checks": true,
  "avoid_dynamic_calls": true,
  "avoid_empty_else": true,
  "avoid_equals_and_hash_code_on_mutable_classes": true,
  "avoid_escaping_inner_quotes": true,
  "avoid_field_initializers_in_const_classes": true,
  "avoid_final_parameters": true,
  "avoid_function_literals_in_foreach_calls": true,
  "avoid_init_to_null": true,
  "avoid_js_rounded_ints": true,
  "avoid_multiple_declarations_per_line": true,
  "avoid_null_checks_in_equality_operators": true,
  "avoid_positional_boolean_parameters": true,
  "avoid_print": true,
  "avoid_private_typedef_functions": true,
  "avoid_redundant_argument_values": true,
  "avoid_relative_lib_imports": true,
  "avoid_renaming_method_parameters": true,
  "avoid_return_types_on_setters": true,
  "avoid_returning_null": true,
  "avoid_returning_null_for_future": true,
  "avoid_returning_null_for_void": true,
  "avoid_returning_this": true,
  "avoid_setters_without_getters": true,
  "avoid_shadowing_type_parameters": true,
  "avoid_single_cascade_in_expression_statements": true,
  "avoid_slow_async_io": true,
  "avoid_type_to_string": true,
  "avoid_types_as_parameter_names": true,
  "avoid_unnecessary_containers": true,
  "avoid_unused_constructor_parameters": true,
  "avoid_void_async": true,
  "avoid_web_libraries_in_flutter": true,
  "await_only_futures": true,
  "camel_case_extensions": true,
  "camel_case_types": true,
  "cancel_subscriptions": true,
  "cascade_invocations": true,
  "cast_nullable_to_non_nullable": true,
  "comment_references": true,
  "conditional_uri_does_not_exist": true,
  "constant_identifier_names": true,
  "control_flow_in_finally": true,
  "curly_braces_in_flow_control_structures": true,
  "deprecated_consistency": true,
  "directives_ordering": true,
  "empty_catches": true,
  "empty_constructor_bodies": true,
  "empty_statements": true,
  "eol_at_end_of_file": true,
  "exhaustive_cases": true,
  "file_names": true,
  "flutter_style_todos": true,
  "hash_and_equals": true,
  "implementation_imports": true,
  "iterable_contains_unrelated_type": true,
  "join_return_with_assignment": true,
  "leading_newlines_in_multiline_strings": true,
  "library_names": true,
  "library_prefixes": true,
  "library_private_types_in_public_api": true,
  "lines_longer_than_80_chars": true,
  "list_remove_unrelated_type": true,
  "literal_only_boolean_expressions": true,
  "missing_whitespace_between_adjacent_strings": true,
  "no_adjacent_strings_in_list": true,
  "no_default_cases": true,
  "no_duplicate_case_values": true,
  "no_leading_underscores_for_library_prefixes": true,
  "no_leading_underscores_for_local_identifiers": true,
  "no_logic_in_create_state": true,
  "no_runtimeType_toString": true,
  "non_constant_identifier_names": true,
  "noop_primitive_operations": true,
  "null_check_on_nullable_type_parameter": true,
  "null_closures": true,
  "omit_local_variable_types": true,
  "one_member_abstracts": true,
  "only_throw_errors": true,
  "overridden_fields": true,
  "package_api_docs": true,
  "package_names": true,
  "package_prefixed_library_names": true,
  "parameter_assignments": true,
  "prefer_adjacent_string_concatenation": true,
  "prefer_asserts_in_initializer_lists": true,
  "prefer_asserts_with_message": true,
  "prefer_collection_literals": true,
  "prefer_conditional_assignment": true,
  "prefer_const_constructors": true,
  "prefer_const_constructors_in_immutables": true,
  "prefer_const_declarations": true,
  "prefer_const_literals_to_create_immutables": true,
  "prefer_constructors_over_static_methods": true,
  "prefer_contains": true,
  "prefer_equal_for_default_values": true,
  "prefer_final_fields": true,
  "prefer_final_in_for_each": true,
  "prefer_final_locals": true,
  "prefer_for_elements_to_map_fromIterable": true,
  "prefer_function_declarations_over_variables": true,
  "prefer_generic_function_type_aliases": true,
  "prefer_if_elements_to_conditional_expressions": true,
  "prefer_if_null_operators": true,
  "prefer_initializing_formals": true,
  "prefer_inlined_adds": true,
  "prefer_int_literals": true,
  "prefer_interpolation_to_compose_strings": true,
  "prefer_is_empty": true,
  "prefer_is_not_empty": true,
  "prefer_is_not_operator": true,
  "prefer_iterable_whereType": true,
  "prefer_null_aware_method_calls": true,
  "prefer_null_aware_operators": true,
  "prefer_single_quotes": true,
  "prefer_spread_collections": true,
  "prefer_typing_uninitialized_variables": true,
  "prefer_void_to_null": true,
  "provide_deprecation_message": true,
  "recursive_getters": true,
  "require_trailing_commas": true,
  "secure_pubspec_urls": true,
  "sized_box_for_whitespace": true,
  "sized_box_shrink_expand": true,
  "slash_for_doc_comments": true,
  "sort_child_properties_last": true,
  "sort_constructors_first": true,
  "sort_pub_dependencies": true,
  "sort_unnamed_constructors_first": true,
  "test_types_in_equals": true,
  "throw_in_finally": true,
  "tighten_type_of_initializing_formals": true,
  "type_annotate_public_apis": true,
  "type_init_formals": true,
  "unawaited_futures": true,
  "unnecessary_await_in_return": true,
  "unnecessary_brace_in_string_interps": true,
  "unnecessary_const": true,
  "unnecessary_constructor_name": true,
  "unnecessary_getters_setters": true,
  "unnecessary_lambdas": true,
  "unnecessary_late": true,
  "unnecessary_new": true,
  "unnecessary_null_aware_assignments": true,
  "unnecessary_null_checks": true,
  "unnecessary_null_in_if_null_operators": true,
  "unnecessary_nullable_for_final_variable_declarations": true,
  "unnecessary_overrides": true,
  "unnecessary_parenthesis": true,
  "unnecessary_raw_strings": true,
  "unnecessary_statements": true,
  "unnecessary_string_escapes": true,
  "unnecessary_string_interpolations": true,
  "unnecessary_this": true,
  "unnecessary_to_list_in_spreads": true,
  "unrelated_type_equality_checks": true,
  "use_build_context_synchronously": true,
  "use_colored_box": true,
  "use_decorated_box": true,
  "use_enums": true,
  "use_full_hex_values_for_flutter_colors": true,
  "use_function_type_syntax_for_parameters": true,
  "use_if_null_to_convert_nulls_to_bools": true,
  "use_is_even_rather_than_modulo": true,
  "use_key_in_widget_constructors": true,
  "use_late_for_private_fields_and_variables": true,
  "use_named_constants": true,
  "use_raw_strings": true,
  "use_rethrow_when_possible": true,
  "use_setters_to_change_properties": true,
  "use_string_buffers": true,
  "use_super_parameters": true,
  "use_test_throws_matchers": true,
  "use_to_and_as_if_applicable": true,
  "valid_regexps": true,
  "void_checks": true,
};

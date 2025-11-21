// ignore_for_file: public_member_api_docs

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../../../../../utils/node_utils.dart';
import '../../../lint_utils.dart';
import '../../../models/internal_resolved_unit_result.dart';
import '../../../models/issue.dart';
import '../../../models/severity.dart';
import '../../models/dart_rule.dart';
import '../../rule_utils.dart';

part 'visitor.dart';

/// A rule that detects usage of deprecated API classes and methods.
///
/// This rule helps identify deprecated code patterns that should be migrated
/// to their modern equivalents. It can be configured to detect specific
/// deprecated class names and suggest replacements.
///
/// ## Configuration
///
/// ```yaml
/// dart_code_linter:
///   rules:
///     - deprecated-api-usage:
///         deprecated-classes:
///           - OldApiClass
///           - LegacyHelper
///         deprecated-prefixes:
///           - Old
///           - Legacy
/// ```
class DeprecatedApiUsageRule extends DartRule {
  static const String ruleId = 'deprecated-api-usage';

  static const _defaultDeprecatedClasses = <String>[
    'OldApiClass',
    'LegacyHelper',
    'DeprecatedUtil',
  ];

  static const _defaultDeprecatedPrefixes = <String>[
    'Old',
    'Legacy',
    'Deprecated',
  ];

  final List<String> _deprecatedClasses;
  final List<String> _deprecatedPrefixes;

  DeprecatedApiUsageRule([Map<String, Object> config = const {}])
      : _deprecatedClasses = _readDeprecatedClasses(config),
        _deprecatedPrefixes = _readDeprecatedPrefixes(config),
        super(
          id: ruleId,
          severity: readSeverity(config, Severity.warning),
          excludes: readExcludes(config),
          includes: readIncludes(config),
        );

  @override
  Iterable<Issue> check(InternalResolvedUnitResult source) {
    final visitor = _Visitor(_deprecatedClasses, _deprecatedPrefixes);

    source.unit.visitChildren(visitor);

    return visitor.issues
        .map((issue) => createIssue(
              rule: this,
              location: nodeLocation(node: issue.node, source: source),
              message: issue.message,
              verboseMessage: issue.verboseMessage,
            ))
        .toList(growable: false);
  }

  static List<String> _readDeprecatedClasses(Map<String, Object> config) {
    final classes = config['deprecated-classes'];
    if (classes is Iterable) {
      return classes.whereType<String>().toList();
    }

    return _defaultDeprecatedClasses;
  }

  static List<String> _readDeprecatedPrefixes(Map<String, Object> config) {
    final prefixes = config['deprecated-prefixes'];
    if (prefixes is Iterable) {
      return prefixes.whereType<String>().toList();
    }

    return _defaultDeprecatedPrefixes;
  }
}

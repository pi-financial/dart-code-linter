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

/// A rule that detects usage of deprecated methods and properties.
///
/// This rule helps identify method calls and property accesses that have been
/// deprecated and should be replaced with modern alternatives. It can be
/// configured with a list of deprecated method patterns.
///
/// ## Configuration
///
/// ```yaml
/// dart_code_linter:
///   rules:
///     - deprecated-method-usage:
///         deprecated-methods:
///           - oldMethod
///           - legacyFunction
///           - deprecatedGetter
/// ```
///
/// ## Example
///
/// Bad:
/// ```dart
/// final result = api.oldMethod();
/// final value = config.legacyGetter;
/// ```
///
/// Good:
/// ```dart
/// final result = api.newMethod();
/// final value = config.modernGetter;
/// ```
class DeprecatedMethodUsageRule extends DartRule {
  static const String ruleId = 'deprecated-method-usage';

  static const _defaultDeprecatedMethods = <String>[
    'oldMethod',
    'legacyFunction',
    'deprecatedGetter',
    'obsoleteProperty',
  ];

  final List<String> _deprecatedMethods;

  DeprecatedMethodUsageRule([Map<String, Object> config = const {}])
      : _deprecatedMethods = _readDeprecatedMethods(config),
        super(
          id: ruleId,
          severity: readSeverity(config, Severity.warning),
          excludes: readExcludes(config),
          includes: readIncludes(config),
        );

  @override
  Iterable<Issue> check(InternalResolvedUnitResult source) {
    final visitor = _Visitor(_deprecatedMethods);

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

  static List<String> _readDeprecatedMethods(Map<String, Object> config) {
    final methods = config['deprecated-methods'];
    if (methods is Iterable) {
      return methods.whereType<String>().toList();
    }

    return _defaultDeprecatedMethods;
  }
}

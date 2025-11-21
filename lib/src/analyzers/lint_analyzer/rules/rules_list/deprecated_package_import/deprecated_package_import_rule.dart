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

/// A rule that detects imports from deprecated packages.
///
/// This rule helps identify imports from packages that have been deprecated
/// or replaced by newer alternatives. It can be configured with a list of
/// deprecated package names and their recommended replacements.
///
/// ## Configuration
///
/// ```yaml
/// dart_code_linter:
///   rules:
///     - deprecated-package-import:
///         deprecated-packages:
///           old_package: new_package
///           legacy_utils: modern_utils
/// ```
class DeprecatedPackageImportRule extends DartRule {
  static const String ruleId = 'deprecated-package-import';

  final Map<String, String> _deprecatedPackages;

  DeprecatedPackageImportRule([Map<String, Object> config = const {}])
      : _deprecatedPackages = _readDeprecatedPackages(config),
        super(
          id: ruleId,
          severity: readSeverity(config, Severity.warning),
          excludes: readExcludes(config),
          includes: readIncludes(config),
        );

  @override
  Iterable<Issue> check(InternalResolvedUnitResult source) {
    final visitor = _Visitor(_deprecatedPackages);

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

  static Map<String, String> _readDeprecatedPackages(
    Map<String, Object> config,
  ) {
    final packages = config['deprecated-packages'];
    if (packages is Map) {
      return Map<String, String>.from(
        packages.map((key, value) => MapEntry(key.toString(), value.toString())),
      );
    }

    // Default deprecated packages
    return {
      'old_api': 'new_api',
      'legacy_core': 'modern_core',
    };
  }
}

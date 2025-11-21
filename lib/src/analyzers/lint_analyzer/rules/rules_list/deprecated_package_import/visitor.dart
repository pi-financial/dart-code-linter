// ignore_for_file: public_member_api_docs

part of 'deprecated_package_import_rule.dart';

class _Visitor extends RecursiveAstVisitor<void> {
  final Map<String, String> _deprecatedPackages;
  final List<_IssueData> issues = [];

  _Visitor(this._deprecatedPackages);

  @override
  void visitImportDirective(ImportDirective node) {
    super.visitImportDirective(node);

    final uri = node.uri.stringValue;
    if (uri == null) return;

    for (final entry in _deprecatedPackages.entries) {
      final deprecatedPackage = entry.key;
      final replacement = entry.value;

      if (uri.startsWith('package:$deprecatedPackage/')) {
        final replacementUri = uri.replaceFirst(
          'package:$deprecatedPackage/',
          'package:$replacement/',
        );

        issues.add(_IssueData(
          node: node,
          message:
              "Import from deprecated package '$deprecatedPackage' detected.",
          verboseMessage:
              "The package '$deprecatedPackage' is deprecated. "
              "Please replace with '$replacement'.\n"
              "Replace '$uri' with '$replacementUri'.",
        ));
      }
    }
  }
}

class _IssueData {
  final AstNode node;
  final String message;
  final String verboseMessage;

  _IssueData({
    required this.node,
    required this.message,
    required this.verboseMessage,
  });
}

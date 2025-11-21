// ignore_for_file: public_member_api_docs

part of 'deprecated_api_usage_rule.dart';

class _Visitor extends RecursiveAstVisitor<void> {
  final List<String> _deprecatedClasses;
  final List<String> _deprecatedPrefixes;
  final List<_IssueData> issues = [];

  _Visitor(this._deprecatedClasses, this._deprecatedPrefixes);

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    super.visitPrefixedIdentifier(node);

    final prefix = node.prefix.name;
    if (_isDeprecatedClass(prefix)) {
      issues.add(_IssueData(
        node: node,
        message: "Usage of deprecated class '$prefix' detected.",
        verboseMessage:
            "The class '$prefix' is deprecated. Please migrate to the recommended alternative. "
            "Check the deprecation notice for migration instructions.",
      ));
    }
  }

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    super.visitSimpleIdentifier(node);

    final name = node.name;
    if (_isTypeReference(node) && _isDeprecatedClass(name)) {
      issues.add(_IssueData(
        node: node,
        message: "Usage of deprecated class '$name' detected.",
        verboseMessage:
            "The class '$name' is deprecated. Please migrate to the recommended alternative. "
            "Check the deprecation notice for migration instructions.",
      ));
    }
  }

  @override
  void visitImportDirective(ImportDirective node) {
    super.visitImportDirective(node);

    final uri = node.uri.stringValue;
    if (uri != null && _containsDeprecatedPackage(uri)) {
      issues.add(_IssueData(
        node: node,
        message: 'Import of deprecated package detected.',
        verboseMessage:
            "The package import '$uri' contains deprecated APIs. "
            "Please migrate to the recommended alternative package.",
      ));
    }
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    super.visitMethodInvocation(node);

    final target = node.target;
    if (target is SimpleIdentifier && _isDeprecatedClass(target.name)) {
      issues.add(_IssueData(
        node: node,
        message: "Method call on deprecated class '${target.name}' detected.",
        verboseMessage:
            "The class '${target.name}' is deprecated. Please migrate method calls "
            "to use the recommended alternative class.",
      ));
    }
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    super.visitInstanceCreationExpression(node);

    final typeName = node.constructorName.type.name2;
    if (typeName is SimpleIdentifier && _isDeprecatedClass(typeName.name)) {
      issues.add(_IssueData(
        node: node,
        message:
            "Instantiation of deprecated class '${typeName.name}' detected.",
        verboseMessage:
            "The class '${typeName.name}' is deprecated. Please use the recommended "
            "alternative class for new instances.",
      ));
    }
  }

  bool _isDeprecatedClass(String name) {
    if (_deprecatedClasses.contains(name)) {
      return true;
    }

    for (final prefix in _deprecatedPrefixes) {
      if (name.startsWith(prefix)) {
        return true;
      }
    }

    return false;
  }

  bool _containsDeprecatedPackage(String uri) {
    // Check for deprecated package patterns
    return uri.contains('deprecated_') || uri.contains('/old/');
  }

  bool _isTypeReference(SimpleIdentifier node) {
    final parent = node.parent;
    return parent is NamedType ||
        parent is PrefixedIdentifier ||
        parent is PropertyAccess ||
        parent is MethodInvocation;
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

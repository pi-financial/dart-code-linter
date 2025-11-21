// ignore_for_file: public_member_api_docs

part of 'deprecated_method_usage_rule.dart';

class _Visitor extends RecursiveAstVisitor<void> {
  final List<String> _deprecatedMethods;
  final List<_IssueData> issues = [];

  _Visitor(this._deprecatedMethods);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    super.visitMethodInvocation(node);

    final methodName = node.methodName.name;
    if (_deprecatedMethods.contains(methodName)) {
      issues.add(_IssueData(
        node: node.methodName,
        message: "Usage of deprecated method '$methodName' detected.",
        verboseMessage:
            "The method '$methodName' is deprecated. "
            "Please use the recommended alternative method. "
            "Check the API documentation for migration instructions.",
      ));
    }
  }

  @override
  void visitPropertyAccess(PropertyAccess node) {
    super.visitPropertyAccess(node);

    final propertyName = node.propertyName.name;
    if (_deprecatedMethods.contains(propertyName)) {
      issues.add(_IssueData(
        node: node.propertyName,
        message: "Usage of deprecated property '$propertyName' detected.",
        verboseMessage:
            "The property '$propertyName' is deprecated. "
            "Please use the recommended alternative property. "
            "Check the API documentation for migration instructions.",
      ));
    }
  }

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    super.visitPrefixedIdentifier(node);

    final identifier = node.identifier.name;
    if (_deprecatedMethods.contains(identifier)) {
      issues.add(_IssueData(
        node: node.identifier,
        message: "Usage of deprecated identifier '$identifier' detected.",
        verboseMessage:
            "The identifier '$identifier' is deprecated. "
            "Please use the recommended alternative. "
            "Check the API documentation for migration instructions.",
      ));
    }
  }

  @override
  void visitFunctionExpressionInvocation(FunctionExpressionInvocation node) {
    super.visitFunctionExpressionInvocation(node);

    final function = node.function;
    if (function is SimpleIdentifier &&
        _deprecatedMethods.contains(function.name)) {
      issues.add(_IssueData(
        node: function,
        message: "Usage of deprecated function '${function.name}' detected.",
        verboseMessage:
            "The function '${function.name}' is deprecated. "
            "Please use the recommended alternative function. "
            "Check the API documentation for migration instructions.",
      ));
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

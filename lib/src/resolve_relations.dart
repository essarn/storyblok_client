import 'package:meta/meta.dart';

/// Resolve relationships to other Stories of a multi-option or single-option
/// field-type. The limit of resolved relationships is 100 Stories.
///
/// See an example from the official documentation:
/// https://www.storyblok.com/tp/using-relationship-resolving-to-include-other-content-entries
class ResolveRelations {
  /// The component name to resolve.
  final String componentName;

  /// The field name in [componentName] to resolve.
  final String fieldName;

  /// Resolve the relationships to the [fieldName] in [componentName].
  const ResolveRelations({
    @required this.componentName,
    @required this.fieldName,
  })  : assert(componentName != null),
        assert(fieldName != null);
}

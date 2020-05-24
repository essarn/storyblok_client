import 'package:meta/meta.dart';

/// Sort entries by specific attribute and order.
///
/// Possible values are all attributes of the entry and all fields of your
/// content type inside `content` with the dot as seperator.
///
/// By default all custom fields are sorted as strings. To sort custom fields
/// with numeric values the sort [type] must be provided
class SortBy {
  /// The field to sort by in the auto-generated fields in the Story object.
  final String attributeField;

  /// The field to sort by in the Story content type.
  final String contentField;

  /// The sort order.
  final SortOrder order;

  /// The sort type, by default [SortType.string].
  final SortType type;

  /// Use [SortBy.attribute] and [SortBy.content] going forward.
  @deprecated
  const SortBy({
    this.attributeField,
    this.contentField,
    this.order,
    this.type,
  })  : assert(attributeField != null ? contentField == null : true),
        assert(contentField != null ? attributeField == null : true);

  /// Sort by the auto-generated [attributeField] in the Story object.
  const SortBy.attribute({
    @required this.attributeField,
    this.order,
    this.type,
  })  : contentField = null,
        assert(attributeField != null);

  /// Sort by the [contentField] in the Story conetent type.
  const SortBy.content({
    @required this.contentField,
    this.order,
    this.type,
  })  : attributeField = null,
        assert(contentField != null);

  /// Shorthand contrustuor for using the sorting provided by the user in the
  /// Storyblok admin interface.
  const SortBy.adminInterface()
      : attributeField = 'position',
        contentField = null,
        order = SortOrder.desc,
        type = null;
}

/// The order in which stories are to be sorted.
enum SortOrder {
  /// Ascending order from smallest to largest.
  asc,

  /// Descending order from largest to smallest.
  desc,
}

/// The type of the sorting fields value.
enum SortType {
  /// As a string value.
  string,

  /// As a int value.
  int,

  /// As a float value.
  float,
}

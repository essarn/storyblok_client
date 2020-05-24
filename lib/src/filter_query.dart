import 'package:enum_to_string/enum_to_string.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:recase/recase.dart';

/// The different values for [FilterQuery.ensure].
enum EnsureType {
  /// String must be empty.
  emptyString,

  /// String must not be empty.
  notEmptyString,

  /// Array must be empty.
  emptyArray,

  /// Array must not be empty.
  notEmptyArray,

  /// Boolean must be true.
  trueBoolean,

  /// Boolean must be false.
  falseBoolean,
}

/// Filter by specific attribute(s) of your content type - it will not work for
/// default Story properties.
class FilterQuery {
  static const _ensureOperation = 'is';
  static const _containsOperation = 'in';
  static const _notInOperation = 'not_in';
  static const _likeOperation = 'like';
  static const _notLikeOperation = 'not_like';
  static const _allInArrayOperation = 'all_in_array';
  static const _inArrayOperation = 'in_array';
  static const _greaterThanDateOperation = 'gt_date';
  static const _lessThanDateOperation = 'lt_date';
  static const _greaterThanIntOperation = 'gt_int';
  static const _lessThanIntOperation = 'lt_int';
  static const _greaterThanFloatOperation = 'gt_float';
  static const _lessThanFloatOperation = 'lt_float';

  static String _seperateArray(List<String> value) =>
      value.reduce((previous, current) => ',$current');

  static final _dateFormat = DateFormat('YYYY-mm-dd HH:MM');
  static String _formatDateTime(DateTime value) => _dateFormat.format(value);

  static String _transformEnsureType(EnsureType value) =>
      ReCase(EnumToString.parse(value)).snakeCase;

  /// The field (or attribute) to filter by.
  final String attribute;

  /// The operation to perform on the filter.
  final String operation;

  /// The value to filter for.
  final dynamic value;

  const FilterQuery._(
    this.attribute,
    this.operation,
    this.value,
  )   : assert(attribute != null),
        assert(operation != null),
        assert(value != null);

  /// Checks for empty or not empty values and booleans. For strings the value
  /// can be [EnsureType.emptyArray] or [EnsureType.notEmptyString]. For
  /// arrays use [EnsureType.emptyArray] or [EnsureType.notEmptyArray]. For
  /// booleans use [EnsureType.trueBoolean] or [EnsureType.falseBoolean].
  factory FilterQuery.ensure({
    @required String attribute,
    @required EnsureType value,
  }) {
    return FilterQuery._(
      attribute,
      _ensureOperation,
      _transformEnsureType(value),
    );
  }

  /// Filter your entries by checking if your custom attribute has a value that
  /// is equal to one of the values provided. Performes the operation `in`.
  ///
  /// See an example from the official documentation:
  /// https://www.storyblok.com/docs/api/content-delivery#filter-queries/operation-in
  factory FilterQuery.contains({
    @required String attribute,
    @required String value,
  }) {
    return FilterQuery._(
      attribute,
      _containsOperation,
      value,
    );
  }

  /// Filter your entries by checking if your custom attribute does not have a
  /// value that is equal to one of the values provided.
  ///
  /// See an example from the official documentation:
  /// https://www.storyblok.com/docs/api/content-delivery#filter-queries/operation-not-in
  factory FilterQuery.notIn({
    @required String attribute,
    @required String value,
  }) {
    return FilterQuery._(
      attribute,
      _notInOperation,
      value,
    );
  }

  /// Filter your entries by checking if your custom attribute has a value that
  /// is "like" the value provided.
  ///
  /// See an example from the official documentation:
  /// https://www.storyblok.com/docs/api/content-delivery#filter-queries/operation-like
  factory FilterQuery.like({
    @required attribute,
    @required String value,
  }) {
    return FilterQuery._(
      attribute,
      _likeOperation,
      value,
    );
  }

  /// Filter your entries by checking if your custom attribute has a value that
  /// is "not_like" the value provided.
  ///
  /// See an example from the official documentation:
  /// https://www.storyblok.com/docs/api/content-delivery#filter-queries/operation-not-like
  factory FilterQuery.notLike({
    @required attribute,
    @required String value,
  }) {
    return FilterQuery._(
      attribute,
      _notLikeOperation,
      value,
    );
  }

  /// Filter your entries by checking if your custom array attribute contains
  /// all of the values provided. As soon as all of the provided values are in
  /// the array field, the story object will be in the response.
  ///
  /// See an example from the official documentation:
  /// https://www.storyblok.com/docs/api/content-delivery#filter-queries/operation-all-in-array
  factory FilterQuery.allInArray({
    @required String attribute,
    @required List<String> value,
  }) {
    return FilterQuery._(
      attribute,
      _allInArrayOperation,
      _seperateArray(value),
    );
  }

  /// Filter your entries by checking if your custom array attribute contains
  /// one of the values provided. As soon as one of the provided values are in
  /// the array field, the story object will be in the response.
  ///
  /// See an example from the official documentation:
  /// https://www.storyblok.com/docs/api/content-delivery#filter-queries/operation-in-array
  factory FilterQuery.inArray({
    @required String attribute,
    @required List<String> value,
  }) {
    return FilterQuery._(
      attribute,
      _inArrayOperation,
      _seperateArray(value),
    );
  }

  /// Think of it at **AFTER** a specific date. Allows you to filter fields of
  /// type date/datetime. Returns all entries that are **greater** (eg. later)
  /// than the provided value.
  ///
  /// See an example from the official documentation:
  /// https://www.storyblok.com/docs/api/content-delivery#filter-queries/operation-gt-date
  factory FilterQuery.greaterThanDate({
    @required String attribute,
    @required DateTime value,
  }) {
    return FilterQuery._(
      attribute,
      _greaterThanDateOperation,
      _formatDateTime(value),
    );
  }

  /// Think of it at **BEFORE** a specific date. Allows you to filter fields of
  /// type date/datetime. Returns all entries that are **lower** (eg. before)
  /// than the provided value.
  ///
  /// See an example from the official documentation:
  /// https://www.storyblok.com/docs/api/content-delivery#filter-queries/operation-gt-date
  factory FilterQuery.lessThanDate({
    @required String attribute,
    @required DateTime value,
  }) {
    return FilterQuery._(
      attribute,
      _lessThanDateOperation,
      _formatDateTime(value),
    );
  }

  /// Allows you to filter fields of type `number`, `string` (number value), or
  /// custom field type with numbers in the schema. Returns all entries that
  /// are **GREATER** than the provided value.
  ///
  /// See an example from the official documentation:
  /// https://www.storyblok.com/docs/api/content-delivery#filter-queries/operation-gt-int
  factory FilterQuery.greaterThanInt({
    @required String attribute,
    @required int value,
  }) {
    return FilterQuery._(
      attribute,
      _greaterThanIntOperation,
      value.toString(),
    );
  }

  /// Allows you to filter fields of type `number`, or custom field type with
  /// numbers in the schema. Returns all entries that are **LESS** than the
  /// provided value.
  ///
  /// See an example from the official documentation:
  /// https://www.storyblok.com/docs/api/content-delivery#filter-queries/operation-lt-int
  factory FilterQuery.lessThanInt({
    @required String attribute,
    @required int value,
  }) {
    return FilterQuery._(
      attribute,
      _lessThanIntOperation,
      value.toString(),
    );
  }

  /// Allows you to filter fields of type `float`, `string` (float value), or
  /// custom field type with numbers in the schema. Returns all entries that
  /// are **GREATER** than the provided value.
  ///
  /// See an example from the official documentation:
  /// https://www.storyblok.com/docs/api/content-delivery#filter-queries/operation-gt-float
  factory FilterQuery.greaterThanFloat({
    @required String attribute,
    @required double value,
  }) {
    return FilterQuery._(
      attribute,
      _greaterThanFloatOperation,
      value.toString(),
    );
  }

  /// Allows you to filter fields of type `number`, or custom field type with
  /// numbers in the schema. Returns all entries that are **LOWER** than the
  /// provided value.
  ///
  /// See an example from the official documentation:
  /// https://www.storyblok.com/docs/api/content-delivery#filter-queries/operation-lt-float
  factory FilterQuery.lessThanFloat({
    @required String attribute,
    @required double value,
  }) {
    return FilterQuery._(
      attribute,
      _lessThanFloatOperation,
      value.toString(),
    );
  }
}

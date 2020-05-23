import 'dart:convert';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:recase/recase.dart';

/// The Story version to fetch.
enum StoryVersion {
  /// Published stories.
  published,

  /// Non published stories, ie. drafted stories.
  draft,
}

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

/// Reponse containing the fetched stories and additional data about the http
/// response.
class StoryblokResponse {
  /// The original http response for the request.
  final http.Response response;

  /// The fecthed stories.
  ///
  /// See [response.body] for the original content.
  final List<Story> stories;

  const StoryblokResponse._(
    this.response,
    this.stories,
  );

  /// The http status code of the response.
  int get statusCode => response.statusCode;

  /// The total number of available entries to fetch. Comes from the `Total`
  /// header and only exists if the request has been paginated.
  int get total => int.tryParse(response.headers['total']) ?? 0;

  /// The amount of fetched entries in the last request. Comes from the
  /// `Per-Page` header and only exists if the request has been paginated.
  int get perPage => int.tryParse(response.headers['per-page']) ?? 0;

  /// Shorthand getter for the first story. Usefull if only a single story has
  /// been fetched with [StoryblokClient.fetchOne]
  Story get story => stories.first;
}

/// Parsed class of the Story contents.
class Story {
  /// The name of the Story.
  final String name;

  /// Creation date for the Story.
  final DateTime createdAt;

  /// Latest publishing date of the Story.
  final DateTime publishedAt;

  /// Alternate objects for the Story.
  final List<dynamic> alternates;

  /// The id of the Story.
  final int id;

  /// Generated uuid string.
  final String uuid;

  /// The story content.
  final Map<String, dynamic> content;

  /// The last slug segment of the Story.
  final String slug;

  /// Combined parent folder and current slug.
  final String fullSlug;

  /// The sort by date for the Story.
  final dynamic sortByDate;

  /// Position in the admin interface.
  final int position;

  /// The tags of the tory.
  final List<String> tagList;

  /// If the Story is startpage of its folder.
  final bool isStartpage;

  /// The id of the Storys parent.
  final int parentId;

  /// Meta data of the Story.
  final dynamic metaData;

  /// Alternates group id (uuid string)
  final String groupId;

  /// First publising date for the Story.
  final DateTime firstPublishedAt;

  /// Id of the content stage. Default `"null"`.
  final String realeaseId;

  /// The lang of the Story.
  final String lang;

  /// Unknown.
  final String path;

  /// Array of translated slugs. Only gets included if the translatable slug
  /// app is installed.
  final List<String> translatedSlugs;

  Story._({
    @required this.name,
    @required this.createdAt,
    @required this.publishedAt,
    @required this.alternates,
    @required this.id,
    @required this.uuid,
    @required this.content,
    @required this.slug,
    @required this.fullSlug,
    @required this.sortByDate,
    @required this.position,
    @required this.tagList,
    @required this.isStartpage,
    @required this.parentId,
    @required this.metaData,
    @required this.groupId,
    @required this.firstPublishedAt,
    @required this.realeaseId,
    @required this.lang,
    @required this.path,
    @required this.translatedSlugs,
  });

  factory Story._fromJson(Map<String, dynamic> json) {
    return Story._(
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      publishedAt: DateTime.parse(json['published_at'] as String),
      alternates: List.from(json['alternates']),
      id: json['id'] as int,
      uuid: json['uuid'] as String,
      content: json['content'] as Map<String, dynamic>,
      slug: json['slug'] as String,
      fullSlug: json['full_slug'] as String,
      sortByDate: json['sort_by_date'],
      position: json['position'] as int,
      tagList: List<String>.from(json['tag_list']),
      isStartpage: json['is_startpage'] as bool,
      parentId: json['parent_id'] as int,
      metaData: json['meta_data'],
      groupId: json['group_id'] as String,
      firstPublishedAt: DateTime.parse(json['first_published_at'] as String),
      realeaseId: json['realease_id'] as String,
      lang: json['lang'] as String,
      path: json['path'] as String,
      translatedSlugs: List<String>.from(json['translated_slugs']),
    );
  }
}

/// The main class for fetching Storyblok content.
class StoryblokClient {
  static const _base = 'api.storyblok.com';

  final String _token;
  final bool _autoCacheInvalidation;

  String _cacheVersion;

  /// Construct a new client for accessing Storyblok.
  ///
  /// When [autoCacheInvalidation] is set to `false` will the cache version not
  /// be auto invalidated before each request. To invalidate the cache version
  /// manually at appropriate stages in the project, use the
  /// [StoryblokClient.invalidateCacheVersion] method.
  StoryblokClient({
    @required String token,
    bool autoCacheInvalidation = false,
  })  : assert(token != null),
        _token = token,
        _autoCacheInvalidation = autoCacheInvalidation;

  Future<http.Response> _get(
    String path, {
    Map<String, String> parameters,
    bool ignoreCacheVersion = false,
  }) async {
    if (parameters == null) {
      parameters = {
        'token': _token,
      };
    } else {
      parameters['token'] = _token;
    }

    if (!ignoreCacheVersion) {
      if (_autoCacheInvalidation) {
        await invalidateCacheVersion();
      }

      if (_cacheVersion == null) {
        print(
          // ignore: lines_longer_than_80_chars
          'No cache invalidation version fetched. Consider turning on auto cache invalidation',
        );
      } else {
        parameters['cv'] = _cacheVersion;
      }
    }

    final response = await http.get(Uri.https(_base, '/v1/cdn/$path', parameters));
    if (response.statusCode != 200) {
      print(("Invalid response from Storyblok: ${response.statusCode}"));
    }

    return response;
  }

  /// Fetches the latest cache version from Storyblok. The fetched cache version
  /// will then be used in subsequent calls.
  Future<void> invalidateCacheVersion() async {
    final response = await _get('spaces/me', ignoreCacheVersion: true);
    final body = json.decode(response.body);

    _cacheVersion = body['space']['version'].toString();
  }

  /// Fetches a single Story.
  ///
  /// See https://www.storyblok.com/docs/api/content-delivery#core-resources/stories/retrieve-one-story
  /// for more details.
  Future<StoryblokResponse> fetchOne({
    String fullSlug,
    String id,
    String uuid,
    StoryVersion version,
    bool resolveLinks,
    List<ResolveRelations> resolveRelations,
    String fromRelease,
    String language,
    String fallbackLanguage,
  }) async {
    if (fullSlug != null) {
      assert(id == null && uuid == null);
    } else if (id != null) {
      assert(fullSlug == null && uuid == null);
    } else if (uuid != null) {
      assert(fullSlug == null && id == null);
    }

    final path = StringBuffer('stories/');
    if (fullSlug != null) path.write(fullSlug);
    if (id != null) path.write(id);
    if (uuid != null) path.write(uuid);

    final parameters = <String, String>{};
    if (uuid != null) parameters['find_by'] = 'uuid';
    if (version != null) parameters['version'] = EnumToString.parse(version);
    if (resolveLinks != null) {
      parameters['resolve_links'] = resolveLinks.toString();
    }
    if (resolveRelations != null) {
      parameters['resolve_relations'] = resolveRelations.fold<String>(
        '',
        (
          previous,
          current,
        ) =>
            previous += '${current.componentName}.${current.fieldName},',
      );
    }
    if (fromRelease != null) parameters['from_release'] = fromRelease;
    if (language != null) parameters['language'] = language;
    if (fallbackLanguage != null) {
      parameters['fallback_language'] = fallbackLanguage;
    }

    final response = await _get(path.toString(), parameters: parameters);

    final body = json.decode(response.body);
    final story = Story._fromJson(body['story'] as Map<String, dynamic>);
    final stories = List<Story>.filled(1, story);

    return StoryblokResponse._(response, stories);
  }

  /// Fetches multiple stories.
  ///
  /// See https://www.storyblok.com/docs/api/content-delivery#core-resources/stories/retrieve-multiple-stories
  /// for more details.
  Future<StoryblokResponse> fetchMultiple({
    String startsWith,
    List<String> byUuids,
    String fallbackLang,
    List<String> byUuidsOrdered,
    List<String> excludingIds,
    List<String> excludingFields,
    StoryVersion version,
    bool resolveLinks,
    List<ResolveRelations> resolveRelations,
    String fromRelease,
    SortBy sortBy,
    String searchTerm,
    List<FilterQuery> filterQueries,
    bool isStartPage,
    List<String> withTag,
    int page,
    int perPage,
  }) async {
    final parameters = <String, String>{};
    if (startsWith != null) parameters['starts_with'] = startsWith;
    if (byUuids != null) {
      parameters['by_uuids'] = byUuids.reduce(
        (previous, current) => previous += ',$current',
      );
    }
    if (fallbackLang != null) parameters['fallback_lang'] = fallbackLang;
    if (byUuidsOrdered != null) {
      parameters['by_uuids_ordered'] =
          byUuidsOrdered.reduce((previous, current) => previous += ',$current');
    }
    if (excludingIds != null) {
      parameters['excluding_ids'] =
          excludingIds.reduce((previous, current) => previous += ',$current');
    }
    if (excludingFields != null) {
      parameters['excluding_fields'] = excludingFields.reduce((
        previous,
        current,
      ) =>
          previous += ',$current');
    }
    if (version != null) parameters['version'] = EnumToString.parse(version);
    if (resolveLinks != null) {
      parameters['resolve_links'] = resolveLinks.toString();
    }
    if (resolveRelations != null) {
      parameters['resolve_relations'] = resolveRelations.fold<String>(
        '',
        (
          previous,
          current,
        ) =>
            previous += '${current.componentName}.${current.fieldName},',
      );
    }
    if (fromRelease != null) parameters['from_release'] = fromRelease;
    if (sortBy != null) {
      String sort;
      if (sortBy.attributeField != null) {
        sort = sortBy.attributeField;
      } else {
        sort = 'content.${sortBy.contentField}';
      }
      if (sortBy.order != null) sort += ':${EnumToString.parse(sortBy.order)}';
      if (sortBy.type != null) sort += ':${EnumToString.parse(sortBy.type)}';

      parameters['sort_by'] = sort;
    }
    if (searchTerm != null) parameters['search_term'] = searchTerm;
    if (filterQueries != null) {
      for (final filter in filterQueries) {
        parameters['filter_query[${filter.attribute}][${filter.operation}]'] =
            filter.value.toString();
      }
    }
    if (isStartPage != null) {
      parameters['is_startpage'] = isStartPage ? '1' : '0';
    }
    if (page != null) parameters['page'] = page.toString();
    if (perPage != null) parameters['per_page'] = perPage.toString();

    final response = await _get('stories', parameters: parameters);

    final body = json.decode(response.body);
    final data = List<Map<String, dynamic>>.from(body['stories']);
    final stories = data.map((json) => Story._fromJson(json)).toList();

    return StoryblokResponse._(response, stories);
  }
}

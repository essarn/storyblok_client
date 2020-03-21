import 'dart:convert';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:http/http.dart' as http;

enum StoryVersion {
  published,
  draft,
}

class ResolveRelations {
  final String componentName;
  final String fieldName;

  ResolveRelations({this.componentName, this.fieldName});
}

class SortBy {
  final String attributeField;
  final String contentField;
  final SortOrder order;
  final SortType type;

  SortBy({this.attributeField, this.contentField, this.order, this.type})
      : assert(attributeField != null ? contentField == null : true),
        assert(contentField != null ? attributeField == null : true);
}

enum SortOrder {
  asc,
  desc,
}

enum SortType {
  string,
  int,
  float,
}

class FilterQuery {
  final String attribute;
  final String operation;
  final dynamic value;

  FilterQuery._({this.attribute, this.operation, this.value});

  FilterQuery.contains({this.attribute, String this.value}) : operation = 'in';
  FilterQuery.notIn({this.attribute, String this.value}) : operation = 'not_in';
  FilterQuery.allInArray({this.attribute, List<String> value})
      : operation = 'all_in_array',
        value = value.reduce((previous, current) => ',$current');
  FilterQuery.inArray({this.attribute, List<String> value})
      : operation = 'in_array',
        value = value.reduce((previous, current) => ',$current');
  FilterQuery.greaterThanDate({this.attribute, DateTime this.value}) : operation = 'gt-date';
  FilterQuery.lessThanDate({this.attribute, DateTime this.value}) : operation = 'lt-date';
  FilterQuery.greaterThanInt({this.attribute, int this.value}) : operation = 'gt-int';
  FilterQuery.lessThanInt({this.attribute, int this.value}) : operation = 'lt-int';
  FilterQuery.greaterThanFloat({this.attribute, double this.value}) : operation = 'gt-float';
  FilterQuery.lessThanFloat({this.attribute, double this.value}) : operation = 'lt-float';
}

class StoryblokClient {
  static const _base = 'api.storyblok.com';

  final String _token;
  final bool _autoCacheInvalidation;

  String _cacheVersion;

  StoryblokClient({String token, bool autoCacheInvalidation = false})
      : assert(token != null),
        _token = token,
        _autoCacheInvalidation = autoCacheInvalidation;

  Future<dynamic> _get(
    String path, {
    Map<String, String> parameters,
    bool ignoreCacheVersion = false,
  }) async {
    if (parameters == null) {
        parameters = {'token': _token};
    } else {
        parameters['token'] = _token;
    }

    if (!ignoreCacheVersion) {
      if (_autoCacheInvalidation) await invalidateCacheVersion();

      if (_cacheVersion == null) {
        print('No cache invalidation version fetched. Consider turning on auto cache invalidation');
      } else {
        parameters['cv'] = _cacheVersion;
      }
    }

    final response = await http.get(Uri.https(_base, '/v1/cdn/$path', parameters));
    if (response.statusCode != 200) {
      throw ("Invalid response from Storyblok: ${response.statusCode}");
    }

    return json.decode(response.body);
  }

  Future<void> invalidateCacheVersion() async {
    if (_autoCacheInvalidation) {
      print("Automatic cache invalidation is configured, avoid calling manually.");
    }

    final data = await _get('spaces/me', ignoreCacheVersion: true);
    _cacheVersion = data['space']['version'].toString();
  }

  Future<Map<String, dynamic>> fetchOne({
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
    assert(fullSlug != null && id != null && uuid != null);
    assert(fullSlug != null || (id == null && uuid == null));
    assert(id != null || (fullSlug == null && uuid == null));
    assert(uuid != null || (fullSlug == null && id == null));

    final path = StringBuffer('stories/');
    if (fullSlug != null) path.write(fullSlug);
    if (id != null) path.write(id);
    if (uuid != null) path.write(uuid);

    final parameters = <String, String>{};
    if (uuid != null) parameters['find_by'] = 'uuid';
    if (version != null) parameters['version'] = EnumToString.parse(version);
    if (resolveLinks != null) parameters['resolve_links'] = resolveLinks.toString();
    if (resolveRelations != null) {
      parameters['resolve_relations'] = resolveRelations.fold<String>(
          '', (previous, current) => previous += '${current.componentName}.${current.fieldName},');
    }
    if (fromRelease != null) parameters['from_release'] = fromRelease;
    if (language != null) parameters['language'] = language;
    if (fallbackLanguage != null) parameters['fallback_language'] = fallbackLanguage;

    return await _get(path.toString(), parameters: parameters);
  }

  Future<Map<String, dynamic>> fetchMultiple({
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
    bool isStartpage,
    List<String> withTag,
    int page,
    int perPage,
  }) async {
    final parameters = <String, String>{};
    if (startsWith != null) parameters['starts_with'] = startsWith;
    if (byUuids != null) {
      parameters['by_uuids'] = byUuids.reduce((previous, current) => previous += ',$current');
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
      parameters['excluding_fields'] =
          excludingFields.reduce((previous, current) => previous += ',$current');
    }
    if (version != null) parameters['version'] = EnumToString.parse(version);
    if (resolveLinks != null) parameters['resolve_links'] = resolveLinks.toString();
    if (resolveRelations != null) {
      parameters['resolve_relations'] = resolveRelations.fold<String>(
          '', (previous, current) => previous += '${current.componentName}.${current.fieldName},');
    }
    if (fromRelease != null) parameters['from_release'] = fromRelease;
    if (sortBy != null) {
      var sort =
          sortBy.attributeField != null ? sortBy.attributeField : 'content.${sortBy.contentField}';
      if (sortBy.order != null) sort += ':${EnumToString.parse(sortBy.order)}';
      if (sortBy.type != null) sort += ':${EnumToString.parse(sortBy.type)}';

      parameters['sort_by'] = sort;
    }
    if (searchTerm != null) parameters['search_term'] = searchTerm;
    if (filterQueries != null) {
      filterQueries.forEach((filter) =>
          parameters['filter_query[${filter.attribute}][${filter.operation}]'] =
              filter.value.toString());
    }
    if (isStartpage != null) parameters['is_startpage'] = isStartpage ? '1' : '0';
    if (page != null) parameters['page'] = page.toString();
    if (perPage != null) parameters['per_page'] = perPage.toString();

    return await _get('stories', parameters: parameters);
  }
}

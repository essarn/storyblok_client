import 'dart:convert';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

import 'filter_query.dart';
import 'resolve_relations.dart';
import 'sort_by.dart';
import 'story_model.dart';
import 'storyblok_response.dart';

/// The Story version to fetch.
enum StoryVersion {
  /// Published stories.
  published,

  /// Non published stories, ie. drafted stories.
  draft,
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

    final uri = Uri.https(_base, '/v1/cdn/$path', parameters);
    final response = await http.get(uri);

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

    final story = Story.fromJson(body['story'] as Map<String, dynamic>);
    final stories = <Story>[]..add(story);

    return StoryblokResponse(response, stories);
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
    final stories = data.map((json) => Story.fromJson(json)).toList();

    return StoryblokResponse(response, stories);
  }
}

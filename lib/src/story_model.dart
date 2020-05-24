import 'package:meta/meta.dart';

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

  /// Constructs a new story object.
  Story({
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

  /// Create a new story from the storyblok http response body.
  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
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

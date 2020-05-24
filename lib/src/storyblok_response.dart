import 'package:http/http.dart' as http;
import 'story_model.dart';

/// Reponse containing the fetched stories and additional data about the http
/// response.
class StoryblokResponse {
  /// The original http response for the request.
  final http.Response response;

  /// The fecthed stories.
  ///
  /// See [response.body] for the original content.
  final List<Story> stories;

  /// Creates a new Storyblok response.
  const StoryblokResponse(
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

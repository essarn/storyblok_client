# Storyblok Client

Client for accessing the Storyblok Headless CMS API through Dart.

## Request response

`StoryblokResponse` is returned when fetching stories. The object contains the original http response and the parsed stories. `StoryblokResponse.stories` are the parsed `Story` objects from Storyblok. 

## Story

The `Story` object contains the same properties as the original Storyblok response. Use `Story.content` to access the story content.

See https://www.storyblok.com/docs/api/content-delivery#core-resources/stories/the-story-object for more information.


## Retrieve one story

Fetching an example story in the `posts` folder named `one`.

```dart
import 'package:storyblok_client/storyblok_client.dart';

void main() async {
  const token = '...';
  final storyblok = StoryblokClient(token: token, autoCacheInvalidation: true);

  final data = await storyblok.fetchOne(fullSlug: 'posts/one');
  final content = data.story.content;

  print(content['title']); // This is post one
}
```

## Retrieve multiple stories

Fetching multiple stories in the `posts` folder.

```dart
import 'package:storyblok_client/storyblok_client.dart';

void main() async {
  const token = '...';
  final storyblok = StoryblokClient(token: token, autoCacheInvalidation: true);

  final data = await storyblok.fetchMultiple(startsWith: 'posts');
  final stories = data.stories;

  for(final story in stories) {
    print(story.content['title']); // This is post one, This is post two etc..
  }
}
```

## Filter stories

Stories can be filtered by supplying multiple `FilterQuery.<filter>()` objects to the `filterQueries` array. Note that the operations `is` and `in` are `FilterQuery.ensure` and `FilterQuery.contains` due to reserved keywords.

Fetching stories by a specific user.

```dart
import 'package:storyblok_client/storyblok_client.dart';

void main() async {
  const token = '...';
  final storyblok = StoryblokClient(token: token, autoCacheInvalidation: true);

  final data = await storyblok.fetchMultiple(
    startsWith: 'posts',
    filterQueries: [
      FilterQuery.contains(
        attribute: 'user',
        value: 'John Doe',
      ),
    ],
  );
  final stories = data.stories;

  for (final story in stories) {
    print(story.content['user']); // John Doe
  }
}

```

## Order stories

Stories can be ordered by supplying an `OrderBy` object to the `orderBy` parameter.

## Cache Invalidation

The cache version can either be manually invalidated or automaticity invalided before each request. Control this behavios using the `autoCacheInvalidation` parameter.

When `autoCacheInvalidation` is set to `false` will the cache version not be auto invalidated before each request. To invalidate the cache version manually at appropriate stages in the project, use the `invalidateCacheVersion()` method.



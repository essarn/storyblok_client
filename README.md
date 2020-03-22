# Storyblok Client

Client for accessing the Storyblok Headless CMS API through Dart.

## Cache Invalidation

The cache version can either be manually invalidated or automaticity invalided before each request. Control this behavios using the `autoCacheInvalidation` parameter.

When `autoCacheInvalidation` is set to `false` will the cache version not be auto invalidated before each request. To invalidate the cache version manually at appropriate stages in the project, use the `invalidateCacheVersion()` method.

## Retrieve one story

Fetching an example story in the `posts` folder named `one`.
The returned object is the original Storyblok response body.

```dart
import 'package:storyblok_client/storyblok_client.dart';

void main() async {
  const token = '...';
  final storyblok = StoryblokClient(token: token, autoCacheInvalidation: true);

  final data = await storyblok.fetchOne(fullSlug: 'posts/one');
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
}
```

## Filter

Stories can be filtered by supplying multiple `FilterQuery.<filter>()` objects to the `filterQueries` array.

## Order

Stories can be ordered by supplying an `OrderBy()` object to the `orderBy` parameter.

# storyblok_client

Demonstrates how to use the storyblok_client plugin.

## Getting Started

For help getting started with Flutter, view our online
[documentation](http://flutter.io/).

## Examples
![Example Image](/assets/example_image.jpg)

```dart
  getArticle() async {
    return await StoryblokClient(
      token: token,
      autoCacheInvalidation: true,
    ).fetchOne(
      fullSlug: '/article/article-1',
    );
  }

  getArticles() async {
    return await StoryblokClient(
      token: token,
      autoCacheInvalidation: true,
    ).fetchMultiple(startsWith: 'article/');
  }
```
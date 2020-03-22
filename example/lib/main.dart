import 'package:flutter/material.dart';
import 'package:storyblok_client/storyblok_client.dart';

const token = 'rZ6fmrWh1u7Sb0Qdz5BDPwtt';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'storyblok_client Example App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Example"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: <Widget>[
            FutureBuilder(
              future: getArticle(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var content = snapshot.data["story"]["content"];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            content["title"] ?? "",
                            style: TextStyle(fontSize: 24.0),
                          ),
                          Text(content["long_text"] ?? "")
                        ],
                      ),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Column(
                    children: <Widget>[
                      Icon(Icons.error),
                      Text("Something went Wrong"),
                    ],
                  );
                }

                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FutureBuilder(
                    future: getArticles(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Column(
                          children: <Widget>[
                            Icon(Icons.error),
                            Text("Something went wrong!")
                          ],
                        );
                      }
                      if (snapshot.hasData) {
                        List<dynamic> content = snapshot.data["stories"].where(
                          (element) {
                            return element["content"]["title"] != null;
                          },
                        ).toList();
                        return ListView.separated(
                          itemBuilder: (context, index) {
                            var storyContent = content[index]["content"];
                            return ListTile(
                              trailing: Icon(Icons.textsms),
                              title: Text(storyContent["title"] ?? ""),
                              subtitle: Text(storyContent["long_text"] ?? ""),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) =>
                              Divider(),
                          itemCount: content.length,
                        );
                      }
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

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
}

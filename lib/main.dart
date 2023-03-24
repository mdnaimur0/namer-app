import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];
  void toggleFavorites() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }

  void removeFavorite(WordPair pair) {
    if (favorites.contains(pair)) {
      favorites.remove(pair);
      notifyListeners();
    }
  }
}

class MyHomePage extends StatefulWidget {
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritePage();
        break;
      default:
        throw UnimplementedError('No widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        key: widget._key,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: constraints.maxWidth > 600
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                constraints.maxWidth > 600
                    ? SizedBox()
                    : Padding(
                        padding: const EdgeInsets.all(10),
                        child: IconButton(
                          onPressed: () =>
                              (widget._key.currentState!.openDrawer()),
                          icon: Icon(Icons.menu),
                        ),
                      ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Namer App",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SafeArea(
                      child: constraints.maxWidth > 600
                          ? NavigationRail(
                              extended: true,
                              destinations: [
                                NavigationRailDestination(
                                  icon: Icon(Icons.home),
                                  label: Text('Home'),
                                ),
                                NavigationRailDestination(
                                  icon: Icon(Icons.favorite),
                                  label: Text('Favorites'),
                                ),
                              ],
                              selectedIndex: selectedIndex,
                              onDestinationSelected: (value) {
                                setState(() {
                                  selectedIndex = value;
                                });
                              },
                            )
                          : SizedBox()),
                  Expanded(
                    child: Container(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: page,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        drawer: constraints.maxWidth > 600
            ? null
            : Drawer(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.home),
                      title: Text('Home'),
                      onTap: () => setState(() {
                        selectedIndex = 0;
                        Navigator.of(context).pop();
                      }),
                    ),
                    ListTile(
                      leading: Icon(Icons.favorite),
                      title: Text('Favorites'),
                      onTap: () => setState(() {
                        selectedIndex = 1;
                        Navigator.of(context).pop();
                      }),
                    )
                  ],
                ),
              ),
      );
    });
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BigCard(pair: pair),
            SizedBox(height: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    appState.toggleFavorites();
                  },
                  icon: Icon(icon),
                  label: Text('Like'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    appState.getNext();
                  },
                  child: Text('Next'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    Key? key,
    required this.pair,
  }) : super(key: key);

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.displaySmall!
        .copyWith(color: theme.colorScheme.onPrimary);

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: pair.asPascalCase,
        ),
      ),
    );
  }
}

class FavoritePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text("No favorites found"),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have ${appState.favorites.length} favorites:'),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: IconButton(
              icon: Icon(Icons.delete_outline),
              onPressed: () {
                appState.removeFavorite(pair);
              },
            ),
            title: Text(pair.asLowerCase),
          ),
      ],
    );
  }
}

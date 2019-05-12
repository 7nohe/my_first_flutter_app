import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(MyApp());

final dummySnapshot = [
  {
    'name': '糸島ラーメン',
    'category': '0',
    'breakfast': false,
    'lunch': true,
    'dinner': true,
    'visited': true
  },
  {
    'name': '侑久上海',
    'category': '1',
    'breakfast': false,
    'lunch': true,
    'dinner': true,
    'visited': true
  },
  {
    'name': 'UNO',
    'category': '2',
    'breakfast': false,
    'lunch': true,
    'dinner': true,
    'visited': true
  },
  {
    'name': 'USHIO',
    'category': '3',
    'breakfast': false,
    'lunch': false,
    'dinner': true,
    'visited': true
  },
];

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EaTock',
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final Set<WordPair> _saved = Set<WordPair>();
  final TextStyle _biggerFont = const TextStyle(fontSize: 18.0);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EaTock'),
        actions: <Widget>[
          // Add 3 lines from here...
          IconButton(icon: Icon(Icons.list), onPressed: _pushSaved),
        ],
      ),
      body: _buildBody(context),
    );
  }

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          final Iterable<ListTile> tiles = _saved.map(
            (WordPair pair) {
              return ListTile(
                title: Text(
                  pair.asPascalCase,
                  style: _biggerFont,
                ),
              );
            },
          );
          final List<Widget> divided = ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList();

          return Scaffold(
            appBar: AppBar(
              title: Text('Saved Suggestions'),
            ),
            body: ListView(children: divided),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    // return _buildList(context, dummySnapshot);
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('stockItems').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();
        if (snapshot.hasError) {
          return new Text('Error: ${snapshot.error}');
        } else {
          return _buildList(context, snapshot.data.documents);
        }
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: snapshot.map((data) => _buildRow(context, data)).toList(),
    );
  }

  Widget _buildRow(BuildContext context, DocumentSnapshot data) {
    final _stockItem = StockItem.fromSnapshot(data);

    return ListTile(
      title: Text(
        _stockItem.name,
        style: _biggerFont,
      ),
      trailing: Icon(
          // Add the lines from here...
          // alreadySaved ? Icons.favorite : Icons.favorite_border,
          Icons.favorite_border,
          // color: alreadySaved ? Colors.red : null,
          color: Colors.red),
      onTap: () {
        // setState(() {
        //   if (alreadySaved) {
        //     _saved.remove(pair);
        //   } else {
        //     _saved.add(pair);
        //   }
        // });
      },
    );
  }
}

class StockItem {
  final String name;
  final bool visited;
  final DocumentReference reference;

  StockItem.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['name'] != null),
        assert(map['visited'] != null),
        name = map['name'],
        visited = map['visited'];

  StockItem.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => 'StockItem<$name:$visited>';
}

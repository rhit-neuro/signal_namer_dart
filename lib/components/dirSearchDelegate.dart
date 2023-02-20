import 'package:flutter/material.dart';
import 'package:signal_namer_dart/pages/fileList.dart';
import 'package:signal_namer_dart/signalNamer.dart';

import '../models/Signal.dart';
import '../pages/signalPage.dart';

// Modified from the following source: https://www.geeksforgeeks.org/flutter-search-bar/
class DirectorySearchDelegate extends SearchDelegate {
  List<String> searchTerms = [];

  DirectorySearchDelegate.fromList({required this.searchTerms});

// first overwrite to
// clear the search text
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.clear),
      ),
    ];
  }

// second overwrite to pop out of search menu
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: Icon(Icons.arrow_back),
    );
  }

// third overwrite to show query result
  @override
  Widget buildResults(BuildContext context) {
    List<String> matchQuery = [];
    for (var dir in searchTerms) {
      if (dir.contains(query.toLowerCase())) {
        matchQuery.add(dir);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text(result),
        );
      },
    );
  }

// last overwrite to show the
// querying process at the runtime
  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> matchQuery = [];
    for (var dir in searchTerms) {
      if (dir.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(dir);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          tileColor: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.black, width: 1),
            borderRadius: BorderRadius.circular(5),
          ),
          title: Text(
            result,
            style: const TextStyle(fontSize: 18, color: Colors.black),
          ),
          subtitle: Text(result),
          trailing: IconButton(
            // color: Colors.red,
            icon: Icon(
              Icons.chevron_right,
            ),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return FileListPage(
                      signalArray: SignalNamer.instance.signalMap[result],
                      wasPushed: true,
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}

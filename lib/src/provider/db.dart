import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {

  Future<Database> getDatabase() async {
    final database = openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'dev_releases.db'),
      // When the database is first created, create a table to store dogs.
      onCreate: (db, version) {
        return db.execute(
            "CREATE TABLE techs"
                "("
                  "id INTEGER PRIMARY KEY, "
                  "githubReleaseId INTEGER, "
                  "githubLink TEXT, "
                  "releasePublishedAt TEXT, "
                  "body LONGTEXT, "
                  "title TEXT, "
                  "heroImage TEXT, "
                  "latestTag TEXT, "
                  "githubOwner TEXT, "
                  "githubRepo TEXT, "
                  "createdAt TEXT, "
                  "updatedAt TEXT"
                ")"
        );
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 1,
    );
    return database;
  }
}
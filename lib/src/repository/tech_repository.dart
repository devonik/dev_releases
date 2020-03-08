import 'package:dev_releases/src/models/tech_model.dart';
import 'package:dev_releases/src/provider/db.dart';
import 'package:sqflite/sqflite.dart';

class TechRepository {

  DBProvider dbProvider = new DBProvider();
  Future<void> insertTech(Tech tech) async {
    // Get a reference to the database.
    final Database db = await dbProvider.getDatabase();

    // Insert the Dog into the correct table. Also specify the
    // `conflictAlgorithm`. In this case, if the same dog is inserted
    // multiple times, it replaces the previous data.
    await db.insert(
      'techs',
      tech.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // A method that retrieves all the dogs from the dogs table.
  Future<List<Tech>> getAll() async {
    // Get a reference to the database.
    final Database db = await dbProvider.getDatabase();

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('techs');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return Tech(
        id: maps[i]['id'],
        githubReleaseId: maps[i]['githubReleaseId'],
        githubLink: maps[i]['githubLink'],
        releasePublishedAt: maps[i]['releasePublishedAt'],
        body: maps[i]['body'],
        title: maps[i]['title'],
        heroImage: maps[i]['heroImage'],
        latestTag: maps[i]['latestTag'],
        githubOwner: maps[i]['githubOwner'],
        githubRepo: maps[i]['githubRepo'],
        createdAt: maps[i]['createdAt'],
        updatedAt: maps[i]['updatedAt'],
      );
    });
  }

  // A method that retrieves all the dogs from the dogs table.
  Future<Tech> getById(int id) async {
    // Get a reference to the database.
    final Database db = await dbProvider.getDatabase();

    List<Map> results = await db.query("techs",
        where: 'id = ?',
        whereArgs: [id]
    );

    if (results.length > 0) {
      return Tech.fromMap(results.first);
    }

    return null;
  }

  // A method that retrieves all the dogs from the dogs table.
  Future<List<Tech>> getByIds(String ids) async {
    // Get a reference to the database.
    final Database db = await dbProvider.getDatabase();

    final List<Map<String, dynamic>> results = await db.query("techs",
        where: 'id IN ('+ids+')',
        orderBy: 'releasePublishedAt desc'
    );

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(results.length, (i) {
      return Tech(
        id: results[i]['id'],
        githubReleaseId: results[i]['githubReleaseId'],
        githubLink: results[i]['githubLink'],
        releasePublishedAt: results[i]['releasePublishedAt'],
        body: results[i]['body'],
        title: results[i]['title'],
        heroImage: results[i]['heroImage'],
        latestTag: results[i]['latestTag'],
        githubOwner: results[i]['githubOwner'],
        githubRepo: results[i]['githubRepo'],
        createdAt: results[i]['createdAt'],
        updatedAt: results[i]['updatedAt'],
      );
    });

  }

  Future<void> deleteTechById(int id) async {
    // Get a reference to the database.
    final Database db = await dbProvider.getDatabase();

    // Remove the Dog from the Database.
    await db.delete(
      'techs',
      // Use a `where` clause to delete a specific dog.
      where: "id = ?",
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }

}
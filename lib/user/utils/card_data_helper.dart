import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:super_market2/user/models/CardData.dart';

class CardDataDatabaseHelper {
  static CardDataDatabaseHelper _cardDatabaseHelper; // Singleton DatabaseHelper
  static Database _database; // Singleton Database

  String tableName = "Card_Data";
  String colId = 'Id';
  String colDate = 'Date';
  String colSuperId = 'Super_Id';
  String colProductCategorie = 'Product_Categorie';
  String colProductName = "Product_Name";
  String colQuantity = 'Quantity';

  CardDataDatabaseHelper._createInstance(); // Named constructor to create instance of CardDatabaseHelper

  factory CardDataDatabaseHelper() {
    if (_cardDatabaseHelper == null) {
      _cardDatabaseHelper = CardDataDatabaseHelper
          ._createInstance(); // This is executed only once, singleton object
    }
    return _cardDatabaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    // Get the directory path for both Android and iOS to store database.
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + '/CardData.db';

    print(path);

    // Open/create the database at a given path
    var notesDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return notesDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        '''CREATE TABLE $tableName($colId INTEGER PRIMARY KEY AUTOINCREMENT, 
        $colDate DATE, $colSuperId TEXT, $colProductCategorie TEXT, 
        $colProductName TEXT, $colQuantity INTEGER)''');
    print("table Created");
  }

  // Fetch Operation: Get all note objects from database
  Future<List<Map<String, dynamic>>> getCardDataMapList() async {
    Database db = await this.database;

    // var result = await db.rawQuery('SELECT * FROM $noteTable order by $colPriority ASC');
    var result = await db.query(
      tableName,
      columns: ["Id", colDate, colProductName, colQuantity],
      orderBy: '$colDate ASC',
    );
    return result;
  }

  // Fetch Operation: Get all note objects from database
  Future<List<Map<String, dynamic>>> getCardDataMapListForCardDate() async {
    Database db = await this.database;

    // var result = await db.rawQuery('SELECT * FROM $noteTable order by $colPriority ASC');
    var result = await db.query(tableName,
        columns: ["Id", colDate], orderBy: '$colDate DESC', groupBy: colDate);
    return result;
  }

  // Fetch Operation: Get all note objects from database
  Future<Map<String, dynamic>> getCardDataMapListForDailyCardDate(
      List<String> dt) async {
    Database db = await this.database;

    Map<String, dynamic> map = {};

    // var result = await db.rawQuery('SELECT * FROM $noteTable order by $colPriority ASC');
    for (String v in dt) {
      var result = await db.query(tableName,
          orderBy: '$colProductCategorie and $colSuperId ASC',
          where: "$colDate = ?",
          whereArgs: [v]);
      map.addAll({v: result});
    }
    return map;
  }

  // Fetch Operation: Get all note objects from database
  Future<List<Map<String, dynamic>>> getCardDataMapListForCheckItems(
      String sId, String dt, String pC, String pN) async {
    Database db = await this.database;

    // var result = await db.rawQuery('SELECT * FROM $noteTable order by $colPriority ASC');
    var result = await db.query(tableName,
        columns: ["Id", colProductName, colQuantity,colDate,colSuperId],
        where:
            '$colSuperId = ? and $colDate = ? and $colProductCategorie = ? and $colProductName = ?',
        whereArgs: [sId, dt, pC, pN]);
    return result;
  }

  // Fetch Operation: Get all note objects from database
  Future<Map<String, dynamic>> getCardDataMapListForOrder(String dt) async {
    Database db = await this.database;

    Map<String, List> map = {};

    // var result = await db.rawQuery('SELECT * FROM $noteTable order by $colPriority ASC');
    var result1 = await db.query(tableName,
        orderBy: '$colDate ASC',
        columns: ["Id", colSuperId],
        groupBy: colSuperId,
        where: '$colDate = ?',
        whereArgs: [dt]);

    for (var i in result1) {
      var result = await db.query(tableName,
          orderBy: '$colDate ASC',
          columns: ["Id", colProductCategorie, colProductName, colQuantity],
          where: '$colSuperId = ? and $colDate = ?',
          whereArgs: [
            i["Super_Id"],
            dt,
          ]);
      List tempList = [];
      for (var j in result) {
        tempList.add(
            "${j[colProductCategorie]}:${j[colProductName]}:${j[colQuantity]}");
      }
      map.addAll({i[colSuperId]: tempList});
    }
    return map;
  }

  // Insert Operation: Insert a Note object to database
  Future<int> insertCardData(CardData card) async {
    Database db = await this.database;

    // print("G\n\n\n\n\nH");
    // getCardDataMapList().then((value) => debugPrint(value.toString()));
    // print("G\n\nS");

    var result = await db.insert(tableName, card.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return result;
  }

  // Update Operation: Update a Note object and save it to database
  Future<int> updateCardData(CardData card) async {
    var db = await this.database;
    var result = await db.update(tableName, card.toMap(),
        where:
            '$colDate = ? and $colSuperId = ? and $colProductCategorie = ? and $colProductName = ? and $colId = ?',
        whereArgs: [
          card.date,
          card.superId,
          card.productCategorie,
          card.productName,
          card.id
        ]);
    return result;
  }

  // Delete Operation: Delete a Note object from database
  Future<int> deleteCardData(int id) async {
    var db = await this.database;
    int result =
        await db.rawDelete('DELETE FROM $tableName WHERE $colId = $id');
    return result;
  }

  // Delete Operation: Delete a Note object from database
  Future<int> deleteCardDataWithDate(String dt) async {
    var db = await this.database;
    int result =
        await db.delete(tableName, where: "$colDate = ?", whereArgs: [dt]);
    // await db.rawDelete('DELETE FROM $tableName WHERE $colDate = $dt');
    return result;
  }

  // Get number of Note objects in database
  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $tableName');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  // Get the 'Map List' [ List<Map> ] and convert it to 'Note List' [ List<Note> ]
  Future<List<CardData>> getCardDataList() async {
    var noteMapList =
        await getCardDataMapList(); // Get 'Map List' from database
    int count =
        noteMapList.length; // Count the number of map entries in db table

    List<CardData> noteList = List<CardData>();
    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      noteList.add(CardData.fromMapObject(noteMapList[i]));
    }

    return noteList;
  }
}

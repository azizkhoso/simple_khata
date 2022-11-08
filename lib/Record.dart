import 'package:cloud_firestore/cloud_firestore.dart';

class Record {
  final Timestamp date;
  final String description;
  final List<String> users;
  final List<int> amounts;

  const Record(
      {required this.date,
      required this.description,
      required this.users,
      required this.amounts});

  bool isLendingUser(String email) {
    final indexOfEmail = users.indexOf(email);
    final amount = amounts[indexOfEmail];
    return amount >= 0;
  }

  int getAmountOfUser(String email) {
    int i = users.indexOf(email);
    if (i < 0) return 0;
    return amounts[i];
  }

  Map<String, dynamic> toMap() {
    return {
      "date": date,
      "description": description,
      "users": users,
      "amounts": amounts,
    };
  }

  static Record fromMap(Map<String, dynamic> record) {
    return Record(
      amounts: List<int>.from(record['amounts']),
      description: record['description'],
      users: List<String>.from(record['users']),
      date: record['date'],
    );
  }

  static int getTotalAmountOfUser(String email, List<Record> records) {
    int total = 0;
    for (Record rec in records) {
      total += rec.getAmountOfUser(email);
    }
    return total;
  }

  static List<Record> getRecordsOfUser(String email, List<Record> records) {
    return records.where((element) => element.users.contains(email)).toList();
  }

  static int getTotalLendedSumByUser(String email, List<Record> records) {
    int total = 0;
    for (var rec in records) {
      total += rec.isLendingUser(email) ? rec.getAmountOfUser(email) : 0;
    }
    return total;
  }

  static int getTotalBorrowedSumByUser(String email, List<Record> records) {
    int total = 0;
    for (var rec in records) {
      total += !rec.isLendingUser(email) ? rec.getAmountOfUser(email) : 0;
    }
    return total;
  }
}

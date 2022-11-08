import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:simple_khata/firebase_options.dart';

import 'package:simple_khata/login_page.dart';
import 'package:simple_khata/register_page.dart';
import 'package:simple_khata/user_khata_page.dart';
import 'package:simple_khata/home_page.dart';

import 'package:simple_khata/Record.dart';

class GlobalState extends ChangeNotifier {
  String? _uid;
  Map<String, dynamic>? _user;
  Map<String, dynamic>? _currentKhataUser;
  List<Record> _recs = [];

  get user => _user;

  get uid => _uid;

  get currentKhataUser => _currentKhataUser;

  get records => _recs;

  void login(Map<String, dynamic> usr, String uid) {
    _user = usr;
    _uid = uid;
    fetchRecords();
    notifyListeners();
  }

  void logout() {
    _user = null;
    _uid = null;
    _recs = [];
    notifyListeners();
  }

  void setCurrentKhataUser(Map<String, dynamic> usr) {
    _currentKhataUser = usr;
    notifyListeners();
  }

  Future<void> fetchRecords() async {
    Completer<void> result = Completer();
    final firestore = FirebaseFirestore.instance;
    List<Record> records = [];
    firestore
        .collection('records')
        .where('users', arrayContains: user['email'])
        .orderBy('date')
        .withConverter(fromFirestore: (snapshot, options) => Record.fromMap(snapshot.data()!), toFirestore: (Record record, _) => record.toMap())
        .get()
        .then((qs) {
      for (var element in qs.docs) {
        // emails of all users that are added by logged in user
        final emails = user['users'].map((u) => u['email'].toString());
        // the current record element has one of users in user.users
        // add it to records list
        final rec = element.data();
        if (emails.contains(rec.users[0]) || emails.contains(rec.users[1])) {
          records.add(rec);
        }
      }
      _recs = records;
      notifyListeners();
      result.complete();
    });
  }

  Future<void> lendSumToUser({required String email, required int amount, required String description}) async {
    // following line is used to indicate beginning of some async action
    Completer<void> result = Completer<void>();
    final firestore = FirebaseFirestore.instance;
    firestore.collection('records').add({
      "users": [user?['email'], email],
      "amounts": [amount, -1 * amount],
      "description": description,
      "date": Timestamp.now(),
    }).then((value) {
      fetchRecords();
      // following line tells that record is added, async action is completed
      result.complete();
    });
  }

  Future<void> borrowFromUser({required String email, required int amount, required String description}) async {
    // following line is used to indicate beginning of some async action
    Completer<void> result = Completer<void>();
    final firestore = FirebaseFirestore.instance;
    firestore.collection('records').add({
      "users": [user?['email'], email],
      "amounts": [-1 * amount, amount],
      "description": description,
      "date": Timestamp.now(),
    }).then((value) {
      fetchRecords();
      // following line tells that record is added, async action is completed
      result.complete();
    });
  }

  List<Map<String, dynamic>> getRecordsOfUser(String email) {
    List recs = Record.getRecordsOfUser(email, _recs);
    final List<Map<String, dynamic>> records = [];
    int prevAmount = 0;
    for (Record rec in recs) {
      Map<String, dynamic> temp = rec.toMap();
      prevAmount += rec.getAmountOfUser(email);
      temp['prevAmount'] = prevAmount;
      temp['dateFormatted'] = '11:39, Today';
      records.add(temp);
    }
    return records.reversed.toList();
  }

  int getTotalAmmountOfUser(String email) {
    try {
      return Record.getTotalAmountOfUser(email, _recs);
    } catch (e) {
      debugPrint('error in amount of user $e');
      return 0;
    }
  }

  int getTotalLendedSum() {
    if (user == null) return 0;
    int totalSum = 0;
    // emails of all users that are added by logged in user
    final emails = user['users'].map((u) => u['email'].toString());
    for (String e in emails) {
      int amount = Record.getTotalAmountOfUser(e, _recs);
      if (amount < 0) totalSum += amount;
    }
    return totalSum;
  }

  int getTotalBorrowedSum() {
    if (user == null) return 0;
    // return Record.getTotalBorrowedSumByUser(user['email'], _recs);
    int totalSum = 0;
    // emails of all users that are added by logged in user
    final emails = user['users'].map((u) => u['email'].toString());
    for (String e in emails) {
      int amount = Record.getTotalAmountOfUser(e, _recs);
      if (amount > 0) totalSum += amount;
    }
    return totalSum;
  }
}

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ChangeNotifierProvider(
    create: (context) => GlobalState(),
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final state = Provider.of<GlobalState>(context);
    return MaterialApp(
      title: 'Simple Khata',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePage(title: 'Simple Khata'),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/user-khata': (context) => UserKhata(user: state.currentKhataUser ?? {"fullName": "No name", "email": "noemail@abc.xyz"}),
      },
    );
  }
}

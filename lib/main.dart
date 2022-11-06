import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:simple_khata/firebase_options.dart';

import 'package:simple_khata/login_page.dart';
import 'package:simple_khata/register_page.dart';
import 'package:simple_khata/user_khata_page.dart';
import 'package:simple_khata/home_page.dart';

class GlobalState extends ChangeNotifier {
  String? _uid;
  Map<String, dynamic>? _user;
  Map<String, dynamic>? _currentKhataUser;
  List<Map<String, dynamic>> _records = [];

  get user => _user;

  get uid => _uid;

  get currentKhataUser => _currentKhataUser;

  get records => _records;

  void login(Map<String, dynamic> usr, String uid) {
    _user = usr;
    _uid = uid;
    fetchRecords();
    notifyListeners();
  }

  void logout() {
    _user = null;
    _uid = null;
    _records = [];
    notifyListeners();
  }

  void setCurrentKhataUser(Map<String, dynamic> usr) {
    _currentKhataUser = usr;
    notifyListeners();
  }

  fetchRecords() {
    final firestore = FirebaseFirestore.instance;
    List<Map<String, dynamic>> records = [];
    firestore
        .collection('records')
        .where('users', arrayContains: user['email'])
        .orderBy('date')
        .get()
        .then((qs) {
      for (var element in qs.docs) {
        records.add(element.data());
      }
      _records = records;
      notifyListeners();
    });
  }

  lendSumToUser(
      {required String email,
      required int amount,
      required String description}) {
    final firestore = FirebaseFirestore.instance;
    firestore.collection('records').add({
      "users": [user?['email'], email],
      "amounts": [amount, -1 * amount],
      "description": description,
      "date": Timestamp.now(),
    }).then((value) => {fetchRecords()});
  }

  borrowFromUser(
      {required String email,
      required int amount,
      required String description}) {
    final firestore = FirebaseFirestore.instance;
    firestore.collection('records').add({
      "users": [user?['email'], email],
      "amounts": [-1 * amount, amount],
      "description": description,
      "date": Timestamp.now(),
    }).then((value) => {fetchRecords()});
  }

  List<Map<String, dynamic>> getRecordsOfUser(String email) {
    final List<Map<String, dynamic>> records = [];
    try {
      int prevAmount = 0;
      int index = 0;
      for (var rec in _records) {
        List users = rec['users'];
        Timestamp date = rec['date'];
        if (users.contains(email)) {
          debugPrint('$users contain $email');
          int indexOfEmail = users.indexOf(email);
          int amount = rec['amounts'][indexOfEmail];
          if (index != 0) {
            prevAmount += amount;
          }
          rec['prevAmount'] = prevAmount;
          final d = date.toDate();
          rec['dateFormatted'] =
              '${d.hour}:${d.minute}, ${d.day}-${d.month}-${d.year}';
          records.add(rec);
          index++;
        }
      }
    } catch (e) {
      debugPrint('error in getRecords of user $e');
    }
    return records.reversed.toList();
  }

  int getTotalAmmountOfUser(String email) {
    try {
      int totalAmount = 0;
      List<Map<String, dynamic>> records = getRecordsOfUser(email);
      if (records.isEmpty) return 0;
      var rec = records.last;
      List users = rec['users'];
      int indexOfEmail = users.indexOf(email);
      totalAmount += int.parse(rec['prevAmount'].toString()) +
          int.parse(rec['amounts'][indexOfEmail].toString());
      return totalAmount;
    } catch (e) {
      debugPrint('error in amount of user $e');
      return 0;
    }
  }

  int getTotalLendedSum() {
    int totalSum = 0;
    if (user == null) return 0;
    for (var elem in user?['users']) {
      var sum = getTotalAmmountOfUser(elem['email']);
      totalSum += sum < 0 ? sum : 0;
    }
    return totalSum;
  }

  int getTotalBorrowedSum() {
    int totalSum = 0;
    if (user == null) return 0;
    for (var elem in user?['users']) {
      var sum = getTotalAmmountOfUser(elem['email']);
      totalSum += sum > 0 ? sum : 0;
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
        '/user-khata': (context) => UserKhata(
            user: state.currentKhataUser ??
                {"fullName": "No name", "email": "noemail@abc.xyz"}),
      },
    );
  }
}

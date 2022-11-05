import 'package:flutter/material.dart';
import 'package:simple_khata/add_user_dialog.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class SumContainer extends StatelessWidget {
  final String type;
  final int totalSum;
  const SumContainer({Key? key, required this.type, required this.totalSum})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        color: type == 'lended' ? Colors.green[100] : Colors.red[100],
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == 'lended'
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              color: type == 'lended' ? Colors.green[800] : Colors.red[800],
            ),
            Column(mainAxisAlignment: MainAxisAlignment.center, children: <
                Widget>[
              Text(
                'Rs $totalSum',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: type == 'lended' ? Colors.green[800] : Colors.red[800],
                ),
              ),
              Text(
                type == 'lended' ? 'Lended' : 'Borrowed',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: type == 'lended' ? Colors.green[800] : Colors.red[800],
                ),
              )
            ]),
          ],
        ),
      ),
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/login');
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          constraints: const BoxConstraints.expand(width: 400),
          child: Center(
            child: Column(
              children: <Widget>[
                Row(
                  children: const [
                    Expanded(
                        flex: 1,
                        child: SumContainer(
                          type: 'lended',
                          totalSum: 1220,
                        )),
                    SizedBox(width: 8),
                    Expanded(
                        flex: 1,
                        child: SumContainer(type: 'borrowed', totalSum: 1220))
                  ],
                ),
                const SizedBox(height: 16),
                const TextField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                    label: Text('Search users'),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/user-khata');
                    },
                    child: const Text(
                      'Person',
                      textAlign: TextAlign.start,
                      textWidthBasis: TextWidthBasis.parent,
                    ),
                  ),
                  trailing: const Text('Rs 300'),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context, builder: (context) => const AddUserDialog());
        },
        tooltip: 'Increment',
        child: const Icon(Icons.person_add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

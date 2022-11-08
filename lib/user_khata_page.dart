import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:simple_khata/main.dart';

class UserKhata extends StatefulWidget {
  final Map<String, dynamic> user;
  const UserKhata({Key? key, required this.user}) : super(key: key);

  @override
  State<UserKhata> createState() => _UserKhataState();
}

class _UserKhataState extends State<UserKhata> {
  isLending(sum) => sum <= 0;

  final amountController = TextEditingController();
  final descriptionController = TextEditingController();

  bool isLoading = false;

  openDialog(BuildContext context, String type, Function action) async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => SimpleDialog(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(children: [
                    Text(
                      type,
                      style: Theme.of(context).textTheme.headline5,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(label: Text('Amount'), prefixIcon: Icon(Icons.money_rounded), border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)))),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descriptionController,
                      minLines: 3,
                      maxLines: 5,
                      decoration: const InputDecoration(label: Text('Description'), border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8)))),
                    ),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(
                          child: TextButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                amountController.clear();
                                descriptionController.clear();
                                Navigator.of(context).pop();
                              },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      )),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  action(widget.user['email'], int.parse(amountController.text), descriptionController.text);
                                  amountController.clear();
                                  descriptionController.clear();
                                  Navigator.of(context).pop();
                                },
                          child: const Text('Done'),
                        ),
                      )
                    ])
                  ]),
                )
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<GlobalState>(context);
    final currentUserRecs = state.getRecordsOfUser(widget.user['email']);
    final totalSum = state.getTotalAmmountOfUser(widget.user['email']);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user['fullName']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints.expand(width: 400),
            child: Column(
              children: [
                Container(
                  height: 100,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: isLending(totalSum) ? Colors.green[100] : Colors.red[100], borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Rs ${totalSum.abs()}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isLending(totalSum) ? Colors.green[800] : Colors.red[800],
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              isLending(totalSum) ? 'Lended' : 'Borrowed',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isLending(totalSum) ? Colors.green[800] : Colors.red[800],
                                fontSize: 18,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(width: 0.5))),
                  child: Row(
                    children: const [
                      Expanded(
                        flex: 2,
                        child: Text('Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text('Lended', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text('Borrowed', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: currentUserRecs.length,
                    itemBuilder: (context, index) {
                      final currentRec = currentUserRecs[index];
                      final currentUserEmailIndex = currentRec['users'].indexOf(widget.user['email']);
                      final currentUserAmount = currentRec['amounts'][currentUserEmailIndex];
                      return Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(6.0),
                          decoration: const BoxDecoration(border: Border(bottom: BorderSide(width: 0.5))),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(currentUserRecs[index]['dateFormatted'].toString()),
                                    Text(currentRec['description']),
                                    Text(
                                      currentUserRecs[index]['prevAmount'].abs().toString(),
                                      style: TextStyle(backgroundColor: isLending(currentUserRecs[index]['prevAmount']) ? Colors.green[200] : Colors.red[200]),
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(isLending(currentUserAmount) ? currentUserAmount.abs().toString() : ''),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(!isLending(currentUserAmount) ? currentUserAmount.abs().toString() : ''),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => openDialog(context, 'Lending', (email, amount, description) {
                          state.lendSumToUser(email: email, amount: amount, description: description).then((value) {
                            setState(() {
                              isLoading = false;
                            });
                          });
                        }),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.green[100]),
                          overlayColor: MaterialStateProperty.all(Colors.green[200]),
                          foregroundColor: MaterialStateProperty.all(Colors.green[800]),
                          elevation: MaterialStateProperty.all(0),
                          padding: MaterialStateProperty.all(const EdgeInsets.all(16)),
                        ),
                        child: Text(
                          'Lend',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[800],
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => openDialog(context, 'Borrowing', (email, amount, description) {
                          state.borrowFromUser(email: email, amount: amount, description: description).then((value) {
                            setState(() {
                              isLoading = false;
                            });
                          });
                        }),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.red[100]),
                          overlayColor: MaterialStateProperty.all(Colors.red[200]),
                          foregroundColor: MaterialStateProperty.all(Colors.red[800]),
                          elevation: MaterialStateProperty.all(0),
                          padding: MaterialStateProperty.all(const EdgeInsets.all(16)),
                        ),
                        child: Text(
                          'Borrow',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red[800],
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

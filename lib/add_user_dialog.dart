import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_khata/main.dart';
import 'package:simple_khata/utils.dart';

class AddUserDialog extends StatefulWidget {
  const AddUserDialog({Key? key}) : super(key: key);
  @override
  AddUserDialogState createState() => AddUserDialogState();
}

class AddUserDialogState extends State<AddUserDialog> {
  final _firestore = FirebaseFirestore.instance;

  bool isLoading = false;

  final emailController = TextEditingController();
  final nameController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final state = Provider.of<GlobalState>(context);
    return SimpleDialog(children: [
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 75,
                height: 75,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(99999),
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 45,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Add User',
                style: Theme.of(context).textTheme.headline6,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  prefixIcon: Icon(Icons.person),
                  label: Text('Full Name'),
                ),
                validator: (value) {
                  if (value!.isEmpty) return 'Full name can not be empty';
                  if (value.length < 3) {
                    return 'Full name should contain at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  prefixIcon: Icon(Icons.email),
                  label: Text('Email'),
                ),
                validator: (value) {
                  if (value!.isEmpty) return 'Email can not be empty';
                  if (value.length < 3) {
                    return 'Email should contain at least 3 characters';
                  }
                  if (!value.contains('@')) return 'Invalid email';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          if ((_formKey.currentState?.validate() ?? false)) {
                            setState(() {
                              isLoading = true;
                            });
                            final List newUsers = state.user['users'];
                            newUsers.add({
                              "fullName": nameController.text,
                              "email": emailController.text
                            });
                            _firestore
                                .collection('users')
                                .doc(state.uid)
                                .update({"users": newUsers}).then((value) {
                              Navigator.of(context).pop();
                              addToast(
                                  context: context,
                                  message: 'User added successfully');
                              setState(() {
                                isLoading = false;
                                nameController.clear();
                                emailController.clear();
                              });
                            }).catchError((err) {
                              addToast(
                                  context: context,
                                  message: err?.message?.toString() ?? 'Error',
                                  type: 'error');
                              setState(() {
                                isLoading = false;
                              });
                            });
                          }
                        },
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Add User',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ))
            ],
          ),
        ),
      ),
    ]);
  }
}

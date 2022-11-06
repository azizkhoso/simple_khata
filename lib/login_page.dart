import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_khata/main.dart';
import 'package:simple_khata/utils.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  bool isLoading = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<GlobalState>(context);
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints.expand(width: 400),
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(99999),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 90,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Welcome back to',
                  style: Theme.of(context).textTheme.headline6,
                ),
                const SizedBox(height: 16),
                Text(
                  'Simple Khata',
                  style: Theme.of(context).textTheme.headline3,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
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
                TextFormField(
                  obscureText: true,
                  controller: passwordController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.key),
                    label: Text('Password'),
                  ),
                  validator: (value) {
                    if (value!.length < 8) {
                      return 'Password should contain at least 8 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              setState(() {
                                isLoading = true;
                              });
                              _auth
                                  .signInWithEmailAndPassword(
                                      email: emailController.text,
                                      password: passwordController.text)
                                  .then((value) {
                                final foundUser = _firestore
                                    .collection('users')
                                    .doc(value.user?.uid);
                                foundUser.get().then((usr) {
                                  if (!usr.exists) {
                                    setState(() {
                                      isLoading = false;
                                    });
                                    addToast(
                                        context: context,
                                        message: 'User not found',
                                        type: 'error');
                                  }
                                  state.login(usr.data()!, usr.id);
                                  Navigator.of(context)
                                      .pushReplacementNamed('/');
                                });
                              }).catchError((err) {
                                addToast(
                                    context: context,
                                    message:
                                        err?.message?.toString() ?? 'Error',
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
                        'Login',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    )),
                const SizedBox(height: 16),
                TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/register');
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Don't have an account? Register",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

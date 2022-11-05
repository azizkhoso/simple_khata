import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);
  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPassowrdController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
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
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                    prefixIcon: Icon(Icons.key),
                    label: Text('Password'),
                  ),
                  validator: (value) {
                    if (value!.length <= 8) {
                      return 'Password should contain at least 8 characters';
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: confirmPassowrdController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                    prefixIcon: Icon(Icons.key),
                    label: Text('Confirm Password'),
                  ),
                  validator: (value) {
                    if (value!.length <= 8) {
                      return 'Confirm Password should contain at least 8 characters';
                    }
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.pushNamed(context, '/login');
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Register',
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
                      Navigator.pushNamed(context, '/login');
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Already have an account? Login",
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

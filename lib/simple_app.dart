import 'dart:async';

import 'package:flutter/material.dart';

class SimpleApp extends StatefulWidget {
  const SimpleApp({Key? key}) : super(key: key);

  @override
  State<SimpleApp> createState() => _SimpleAppState();
}

class _SimpleAppState extends State<SimpleApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/login': (context) => const SimpleLoginPage(),
        '/home': (context) => const SimpleHomePage(),
      },
      initialRoute: '/login',
    );
  }
}

// ignore: prefer-single-widget-per-file
class SimpleLoginPage extends StatefulWidget {
  const SimpleLoginPage({Key? key}) : super(key: key);

  @override
  State<SimpleLoginPage> createState() => _SimpleLoginPageState();
}

class _SimpleLoginPageState extends State<SimpleLoginPage> {
  final errorNotifier = ValueNotifier<String?>(null);
  final emailNotifier = ValueNotifier<String?>(null);
  final passwordNotifier = ValueNotifier<String?>(null);
  final loginButtonNotifier = ValueNotifier<bool>(false);
  final showLoadingNotifier = ValueNotifier<bool>(false);

  bool isValidEmail(String email) {
    if (!RegExp(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$').hasMatch(email.trim())) {
      return false;
    }

    return true;
  }

  bool isValidPassword(String password) {
    return password.isNotEmpty;
  }

  void loginButtonEnableListener() {
    loginButtonNotifier.value = emailNotifier.value != null &&
        passwordNotifier.value != null &&
        passwordNotifier.value!.isNotEmpty &&
        emailNotifier.value!.isNotEmpty;
  }

  Future<void> pushToHome() async {
    if (errorNotifier.value == null) {
      showLoadingNotifier.value = true;
      await Future.delayed(const Duration(seconds: 3), () {
        Navigator.of(context).pushReplacementNamed('/home');
      });
      showLoadingNotifier.value = false;
    }
  }

  @override
  void initState() {
    super.initState();

    emailNotifier.addListener(loginButtonEnableListener);
    passwordNotifier.addListener(loginButtonEnableListener);
  }

  @override
  void dispose() {
    errorNotifier.dispose();
    emailNotifier.dispose();
    passwordNotifier.dispose();
    loginButtonNotifier.dispose();
    showLoadingNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Page')),
      body: SafeArea(
        child: Stack(children: [
          Column(children: [
            TextFormField(
              key: const Key('email-box'),
              onChanged: (email) => emailNotifier.value = email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                label: Text('Email'),
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              key: const Key('password-box'),
              onChanged: (password) => passwordNotifier.value = password,
              keyboardType: TextInputType.text,
              obscureText: false,
              decoration: const InputDecoration(
                label: Text('Password'),
              ),
            ),
            const SizedBox(height: 15),
            ValueListenableBuilder<String?>(
              valueListenable: errorNotifier,
              builder: (_, error, child) {
                return Text(
                  error ?? '',
                  key: const Key('error-label'),
                  style: const TextStyle(color: Colors.red),
                );
              },
            ),
            ValueListenableBuilder<bool>(
              valueListenable: loginButtonNotifier,
              builder: (_, enable, child) {
                return ElevatedButton(
                  onPressed: enable
                      ? () {
                          errorNotifier.value = isValidEmail(emailNotifier.value!) &&
                                  isValidPassword(passwordNotifier.value!)
                              ? null
                              : 'Invalid user input';

                          pushToHome();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50)),
                  child: const Text(
                    'Login',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                );
              },
            ),
          ]),
          Positioned.fill(
            child: ValueListenableBuilder<bool>(
              valueListenable: showLoadingNotifier,
              builder: (_, showLoading, child) {
                return Visibility(
                  visible: showLoading,
                  child: const Center(
                    child: SizedBox(
                      width: 25,
                      height: 25,
                      child: CircularProgressIndicator.adaptive(),
                    ),
                  ),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}

// ignore: prefer-single-widget-per-file
class SimpleHomePage extends StatefulWidget {
  const SimpleHomePage({Key? key}) : super(key: key);

  @override
  State<SimpleHomePage> createState() => _SimpleHomePageState();
}

class _SimpleHomePageState extends State<SimpleHomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Page')),
      body: SafeArea(
        child: Center(
          key: const Key('center-label'),
          child: FutureBuilder<String>(
            future: Future.delayed(const Duration(seconds: 3), () => 'Hi there!'),
            initialData: 'Waiting',
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Text(
                  snapshot.data ?? '',
                  style: const TextStyle(fontSize: 30),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}

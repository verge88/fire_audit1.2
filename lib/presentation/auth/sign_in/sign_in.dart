import 'package:bloc_quiz/bloc/auth/auth_bloc.dart';
import 'package:bloc_quiz/presentation/Dashboard/dashboard.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../sign_up/sign_up.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => Dashboard(FirebaseAuth.instance.currentUser!)));
          }
          if (state is AuthError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is Loading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (state is UnAuthenticated) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: SingleChildScrollView(
                    reverse: true,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Войти в аккаунт",
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextField(
                                keyboardType: TextInputType.emailAddress,
                                controller: _emailController,
                                decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  labelText: "E-mail",
                                  errorText: _emailError,
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _emailError = !EmailValidator.validate(value)
                                        ? 'Введите корректный e-mail'
                                        : null;
                                  });
                                },
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                keyboardType: TextInputType.text,
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  labelText: "Пароль",
                                  errorText: _passwordError,
                                ),
                                obscureText: true,
                                onChanged: (value) {
                                  setState(() {
                                    _passwordError = value.length < 6
                                        ? "Введите минимум 6 символов"
                                        : null;
                                  });
                                },
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  _authenticateWithEmailAndPassword(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: const Text('Войти', style: TextStyle(fontSize: 16)),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                "или",
                                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              OutlinedButton.icon(
                                onPressed: () {
                                  _authenticateWithGoogle(context);
                                },
                                icon: Image.asset('assets/google_logo.png', height: 24),
                                label: const Text('Войти через Google'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => const SignUp()),
                                  );
                                },
                                child: const Text('Создать аккаунт'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return Container();
          },
        ),
      ),
    );
  }

  void _authenticateWithEmailAndPassword(context) {
    if (_emailError == null && _passwordError == null &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      BlocProvider.of<AuthBloc>(context).add(
        SignInRequested(_emailController.text, _passwordController.text),
      );
    }
  }

  void _authenticateWithGoogle(context) {
    BlocProvider.of<AuthBloc>(context).add(
      GoogleSignInRequested(),
    );
  }
}
import 'package:bloc_quiz/bloc/auth/auth_bloc.dart';
import 'package:bloc_quiz/presentation/dashboard/dashboard.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../sign_in/sign_in.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _nameError;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => Dashboard(state.currentUser),
              ),
            );
          }
          if (state is AuthError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        builder: (context, state) {
          if (state is Loading) {
            return const Center(child: CircularProgressIndicator());
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
                        "Регистрация",
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
                              controller: _nameController,
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                labelText: "Имя",
                                errorText: _nameError,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _nameError = value.isEmpty ? "Введите имя" : null;
                                });
                              },
                            ),
                            const SizedBox(height: 10),
                            TextField(
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
                                _createAccountWithEmailAndPassword(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text('Зарегистрироваться', style: TextStyle(fontSize: 16)),
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
                                  MaterialPageRoute(builder: (context) => const SignIn()),
                                );
                              },
                              child: const Text('Уже есть аккаунт?'),
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
    );
  }

  void _createAccountWithEmailAndPassword(BuildContext context) {
    if (_nameError == null && _emailError == null && _passwordError == null &&
        _nameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      BlocProvider.of<AuthBloc>(context).add(
        SignUpRequested(
          _nameController.text,
          _emailController.text,
          _passwordController.text,
        ),
      );
    }
  }

  void _authenticateWithGoogle(context) {
    BlocProvider.of<AuthBloc>(context).add(
      GoogleSignInRequested(),
    );
  }
}
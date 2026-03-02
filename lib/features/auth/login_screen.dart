import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/loading_indicator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
  if (!_formKey.currentState!.validate()) return;
  setState(() => _isLoading = true);
  final auth = Provider.of<AuthService>(context, listen: false);
  final error = await auth.signIn(_emailController.text, _passwordController.text);
  setState(() => _isLoading = false);
  if (error != null) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $error')),
      );
    }
  } else {
    if (mounted) {
      context.go('/home');
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Вход')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => v == null || !v.contains('@') ? 'Введите корректный email' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Пароль'),
                obscureText: true,
                validator: (v) => v == null || v.length < 6 ? 'Пароль должен быть не менее 6 символов' : null,
              ),
              const SizedBox(height: 24),
              if (_isLoading) const LoadingIndicator(),
              if (!_isLoading) ...[
                ElevatedButton(onPressed: _login, child: const Text('Войти')),
                TextButton(
                  onPressed: () => context.push('/register'),
                  child: const Text('Нет аккаунта? Регистрация'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
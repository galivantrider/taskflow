import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth.controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() { _emailController.dispose(); _passwordController.dispose(); super.dispose(); }


  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authControllerProvider.notifier).login(email: _emailController.text.trim(), password: _passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
     ref.listen<AuthState>(authControllerProvider, (_, next) {
      if (next.status == AuthStatus.error) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.errorMessage ?? 'Login failed')));
    });

    final state = ref.watch(authControllerProvider);
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
       body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Container(
                  width: 64, height: 64, alignment: Alignment.center,
                  decoration: BoxDecoration(color: scheme.primary, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: scheme.primary.withValues(alpha: .24), blurRadius: 20, offset: const Offset(0, 10))]),
                  child: const Icon(Icons.checklist_rounded, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 28),
                Text('Welcome to\nTaskFlow', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -1.2)),
                const SizedBox(height: 10),
                Text('Focus on what matters. Keep your team moving.', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: const Color(0xFF6D6A7D))),
                const SizedBox(height: 32),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                        Text('Sign in', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 20),
                        TextFormField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email address', prefixIcon: Icon(Icons.mail_outline)), validator: (value) => value == null || value.trim().isEmpty ? 'Email is required' : !value.contains('@') ? 'Enter a valid email' : null),
                        const SizedBox(height: 14),
                        TextFormField(controller: _passwordController, obscureText: _obscurePassword, decoration: InputDecoration(labelText: 'Password', prefixIcon: const Icon(Icons.lock_outline), suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined), onPressed: () => setState(() => _obscurePassword = !_obscurePassword))), validator: (value) => value == null || value.isEmpty ? 'Password is required' : null),
                        const SizedBox(height: 22),
                        FilledButton(onPressed: state.status == AuthStatus.loading ? null : _login, child: state.status == AuthStatus.loading ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Continue')),
                        const SizedBox(height: 6),
                        TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())), child: const Text('Create a local account')),
                      ]),
                    ),
                    
                  ),
         ),
                const SizedBox(height: 20),
                Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(14)), child: const Row(children: [Icon(Icons.info_outline, size: 20), SizedBox(width: 10), Expanded(child: Text('Demo account\nava.admin@nimbusdigital.test  •  password123', style: TextStyle(fontSize: 12.5, height: 1.45)))])),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget { const RegisterScreen({super.key}); @override State<RegisterScreen> createState() => _RegisterScreenState(); }
class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>(); final _name = TextEditingController(); final _email = TextEditingController(); final _password = TextEditingController();
  @override void dispose() { _name.dispose(); _email.dispose(); _password.dispose(); super.dispose(); }
   @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Create account')),
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _form,
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
                  Text('Start organizing', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)), const SizedBox(height: 20),
                  TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Full name', prefixIcon: Icon(Icons.person_outline)), validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null), const SizedBox(height: 14),
                  TextFormField(controller: _email, decoration: const InputDecoration(labelText: 'Email address', prefixIcon: Icon(Icons.mail_outline)), keyboardType: TextInputType.emailAddress, validator: (v) => v == null || !v.contains('@') ? 'Enter a valid email' : null), const SizedBox(height: 14),
                  TextFormField(controller: _password, decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline)), obscureText: true, validator: (v) => v == null || v.length < 6 ? 'Use at least 6 characters' : null), const SizedBox(height: 24),
                  FilledButton(onPressed: () { if (_form.currentState!.validate()) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account created locally. Please sign in with a demo account.'))); Navigator.pop(context); } }, child: const Text('Create account')),
                ]),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth.controller.dart';

const _pink = Color(0xFFFF3B8D);
const _background = Color(0xFF0C090A);
const _surface = Color(0xFF151314);
const _border = Color(0xFF2A2527);
const _muted = Color(0xFFA8A3A6);

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _hidePassword = true;

  @override
  void initState() {
    super.initState();

    ref.listenManual<AuthState>(
      authControllerProvider,
      (_, next) {
        if (!mounted) return;

        if (next.status == AuthStatus.error) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  next.errorMessage ?? 'Unable to sign in',
                ),
              ),
            );
        }
      },
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await ref
        .read(authControllerProvider.notifier)
        .login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  void _openRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const RegisterScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    final isLoading = state.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding =
                constraints.maxWidth >= 600 ? 42.0 : 24.0;

            return Stack(
              children: [
                const _AuthBackdrop(),
                Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 28,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 390,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.stretch,
                          children: [
                            const _BrandMark(),
                            const SizedBox(height: 38),

                            const Text(
                              'Welcome back',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 31,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.8,
                              ),
                            ),

                            const SizedBox(height: 9),

                            const Text(
                              'Sign in to keep your work moving.',
                              style: TextStyle(
                                color: _muted,
                                fontSize: 14,
                              ),
                            ),

                            const SizedBox(height: 30),

                            const _DemoHint(),

                            const SizedBox(height: 24),

                            TextFormField(
                              controller: _emailController,
                              keyboardType:
                                  TextInputType.emailAddress,
                              textInputAction:
                                  TextInputAction.next,
                              autofillHints: const [
                                AutofillHints.username,
                                AutofillHints.email,
                              ],
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                              decoration: _inputDecoration(
                                label: 'Email',
                                hint: 'you@company.com',
                                icon: Icons.mail_outline,
                              ),
                              validator: (value) {
                                final email =
                                    value?.trim() ?? '';

                                if (email.isEmpty) {
                                  return 'Email is required';
                                }

                                if (!email.contains('@') ||
                                    !email.contains('.')) {
                                  return 'Enter a valid email';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _passwordController,
                              obscureText: _hidePassword,
                              textInputAction:
                                  TextInputAction.done,
                              autofillHints: const [
                                AutofillHints.password,
                              ],
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                              onFieldSubmitted: (_) {
                                if (!isLoading) {
                                  _login();
                                }
                              },
                              decoration: _inputDecoration(
                                label: 'Password',
                                hint: 'Enter your password',
                                icon: Icons.lock_outline,
                                suffix: IconButton(
                                  tooltip: _hidePassword
                                      ? 'Show password'
                                      : 'Hide password',
                                  icon: Icon(
                                    _hidePassword
                                        ? Icons
                                            .visibility_outlined
                                        : Icons
                                            .visibility_off_outlined,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _hidePassword =
                                          !_hidePassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty) {
                                  return 'Password is required';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(height: 24),

                            SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                onPressed:
                                    isLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _pink,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor:
                                      _pink.withValues(alpha: 0.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(10),
                                  ),
                                  elevation: 0,
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child:
                                            CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Login to TaskFlow',
                                        style: TextStyle(
                                          fontWeight:
                                              FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment:
                                  WrapCrossAlignment.center,
                              children: [
                                const Text(
                                  'New to TaskFlow? ',
                                  style: TextStyle(
                                    color: _muted,
                                  ),
                                ),
                                TextButton(
                                  onPressed: _openRegister,
                                  child: const Text(
                                    'Create account',
                                    style: TextStyle(
                                      color: _pink,
                                      fontWeight:
                                          FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      filled: true,
      fillColor: _surface,
      labelStyle: const TextStyle(
        color: _muted,
      ),
      hintStyle: const TextStyle(
        color: Color(0xFF6F696D),
      ),
      prefixIconColor: _muted,
      suffixIconColor: _muted,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: _border,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: _border,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: _pink,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Colors.redAccent,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Colors.redAccent,
        ),
      ),
    );
  }
}

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _register() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Account created locally. Please sign in with a demo account.',
        ),
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('Create account'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 390,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    const _BrandMark(),

                    const SizedBox(height: 32),

                    const Text(
                      'Start with TaskFlow',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 29,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Create a local demo account.',
                      style: TextStyle(
                        color: _muted,
                      ),
                    ),

                    const SizedBox(height: 30),

                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: _registerDecoration(
                        label: 'Full name',
                        icon: Icons.person_outline,
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Name is required';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _emailController,
                      keyboardType:
                          TextInputType.emailAddress,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: _registerDecoration(
                        label: 'Email',
                        icon: Icons.mail_outline,
                      ),
                      validator: (value) {
                        if (value == null ||
                            !value.contains('@')) {
                          return 'Enter a valid email';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: _registerDecoration(
                        label: 'Password',
                        icon: Icons.lock_outline,
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.length < 6) {
                          return 'Use at least 6 characters';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _pink,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Create account',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _registerDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: _surface,
      labelStyle: const TextStyle(
        color: _muted,
      ),
      prefixIconColor: _muted,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: _border,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: _border,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: _pink,
        ),
      ),
    );
  }
}

class _AuthBackdrop extends StatelessWidget {
  const _AuthBackdrop();

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.85, -0.95),
            radius: 1.25,
            colors: [
              Color(0xFF302127),
              _background,
              _background,
            ],
          ),
        ),
        child: SizedBox.expand(),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: _pink,
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(
            Icons.check_rounded,
            color: Colors.white,
            size: 27,
          ),
        ),
        const SizedBox(width: 11),
        const Text(
          'TaskFlow',
          style: TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _DemoHint extends StatelessWidget {
  const _DemoHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFF171315),
        border: Border.all(
          color: _border,
        ),
        borderRadius: BorderRadius.circular(9),
      ),
      child: const Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: Color(0xFFFFA0C5),
            size: 18,
          ),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              'Demo login\n'
              'ava.admin@nimbusdigital.test\n'
              'Password123!',
              style: TextStyle(
                color: Color(0xFFB9B2B6),
                fontSize: 11.5,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
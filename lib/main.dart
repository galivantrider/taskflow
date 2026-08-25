import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'presentation/auth/auth.controller.dart';
import 'presentation/auth/login_screen.dart';
import 'presentation/home/home_screen.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(
      child: TaskFlowApp(),
    ),
  );
}

class TaskFlowApp extends StatelessWidget {
  const TaskFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const _SessionGate(),
    );
  }
}

class _SessionGate extends ConsumerStatefulWidget { const _SessionGate(); @override ConsumerState<_SessionGate> createState() => _SessionGateState(); }
class _SessionGateState extends ConsumerState<_SessionGate> { @override void initState(){super.initState();Future.microtask(()=>ref.read(authControllerProvider.notifier).restore());} @override Widget build(BuildContext context){final state=ref.watch(authControllerProvider);if(state.status==AuthStatus.initial||state.status==AuthStatus.loading)return const Scaffold(body:Center(child:CircularProgressIndicator()));return state.status==AuthStatus.authenticated?const HomeScreen():const LoginScreen();} }

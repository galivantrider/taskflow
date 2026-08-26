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
          theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF635BFF),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F7FC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF1D1B2A),
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF7F7FC),
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF635BFF), width: 1.5)),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ),
      home: const _SessionGate(),
    );
  }
}

class _SessionGate extends ConsumerStatefulWidget { const _SessionGate(); @override ConsumerState<_SessionGate> createState() => _SessionGateState(); }
class _SessionGateState extends ConsumerState<_SessionGate> { @override void initState(){super.initState();Future.microtask(()=>ref.read(authControllerProvider.notifier).restore());} @override Widget build(BuildContext context){final state=ref.watch(authControllerProvider);if(state.status==AuthStatus.initial||state.status==AuthStatus.loading)return const Scaffold(body:Center(child:CircularProgressIndicator()));return state.status==AuthStatus.authenticated?const HomeScreen():const LoginScreen();} }

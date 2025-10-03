import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Importe o core do Firebase
import 'firebase_options.dart'; // Importe o arquivo de opções gerado pelo CLI
import 'package:firebase_auth/firebase_auth.dart'; // Necessário para o botão de Logout e informações do user
import 'auth_gate.dart'; // Importa o novo portão de autenticação

// --- Definição do Widget Principal (para o App NutriPlan) ---

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NutriPlan'),
        backgroundColor: Colors.green, // Cor tema do app
        actions: [
          // Botão de Logout
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              // Faz o logout do usuário e o AuthGate redireciona para a tela de Login
              await FirebaseAuth.instance.signOut();
            },
            tooltip: 'Sair',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Bem-vindo ao NutriPlan!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 10),
            // Exibe o e-mail do usuário logado
            Text(
              'Logado como: ${FirebaseAuth.instance.currentUser?.email ?? 'Usuário Desconhecido'}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            const Text(
              'O Firebase Core e a Autenticação estão funcionando perfeitamente.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Definição da Inicialização do Aplicativo ---

void main() async {
  // 1. Garante que os Widgets estão inicializados antes de iniciar o Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicializa o Firebase com as opções específicas para a plataforma atual
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriPlan',
      theme: ThemeData(primarySwatch: Colors.green),
      // A primeira tela do app é o AuthGate para verificar o estado de login
      home: const AuthGate(),
    );
  }
}

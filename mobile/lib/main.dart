// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import 'package:talk_hub_vs2/firebase_options.dart';
// import 'package:talk_hub_vs2/pages/chat/paradinha_do_chat.dart';
// import 'package:talk_hub_vs2/pages/entrar/sair/autentifica%C3%A7%C3%A3o/autenticando_servico.dart';
// import 'package:talk_hub_vs2/pages/entrar/sair/autentifica%C3%A7%C3%A3o/portal_autentificacao.dart';

// import 'componentes/temas.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(
//           create: (context) => AuthService(),
//         ),
//         ChangeNotifierProvider(
//           create: (context) => AmigosEGrupoService(),
//         ),
//         ChangeNotifierProvider(
//           create: (context) {
//             final themeProvider = TemaDoApp();
//             themeProvider.loadThemeState();
//             return themeProvider;
//           },
//         ),
//       ],
//       child: const MyApp(),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: Autentica(),
//     );
//   }
// }
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ShakeAnimationExample(),
    );
  }
}

class ShakeAnimationExample extends StatefulWidget {
  @override
  _ShakeAnimationExampleState createState() => _ShakeAnimationExampleState();
}

class _ShakeAnimationExampleState extends State<ShakeAnimationExample>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    // Definindo a animação de tremor
    _animation = Tween<double>(begin: 0, end: 24).chain(
      CurveTween(curve: Curves.elasticIn),
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onLongPress() {
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Animação de Tremor")),
      body: Center(
        child: GestureDetector(
          onLongPress: _onLongPress,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              // Criando um tremor horizontal
              return Transform.translate(
                offset: Offset(_animation.value * (2.0 - 4.0 * (_animation.value / 24)), 0),
                child: child,
              );
            },
            child: Container(
              width: 200,
              height: 200,
              color: Colors.blue,
              alignment: Alignment.center,
              child: Text(
                'Pressione Longo',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

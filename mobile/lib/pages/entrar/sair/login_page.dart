// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, non_constant_identifier_names

import "package:flutter/material.dart";
import 'package:provider/provider.dart';
import 'package:talk_hub_vs2/componentes/botazin.dart';
import 'package:talk_hub_vs2/componentes/meus_preencha.dart';
import 'package:talk_hub_vs2/componentes/temas.dart';
import 'package:talk_hub_vs2/pages/entrar/sair/autentifica%C3%A7%C3%A3o/autenticando_servico.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.onTap});
  final void Function()? onTap;
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  bool obscureSenha = true;
  late TemaDoApp tema;

  @override
  void initState() {
    tema = Provider.of<TemaDoApp>(context, listen: false);
    super.initState();
  }

  Future<void> Logar() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      await authService.logandoSenhaEmail(
          emailController.text, senhaController.text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "usuário ou senha inválidos",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tema.backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(
                  Icons.message,
                  size: 90,
                  color: Colors.blueAccent,
                ),
                const SizedBox(
                  height: 35,
                ),
                 Text(
                  "Bem vindo, faça Login por Favor! :D",
                  style: TextStyle(color:tema.pretoEBrancoColor , fontSize: 18),
                ),
                const SizedBox(
                  height: 15,
                ),
                PreenchaEmail(
                  controller: emailController,
                  hintText: "Email",
                  obscureText: false,
                ),
                const SizedBox(
                  height: 10,
                ),
                PreenchaSenha(
                  controller: senhaController,
                  hintText: "Senha",
                  obscureText: obscureSenha,
                ),
                const SizedBox(
                  height: 10,
                ),
                Botao(onTap: Logar, texto: "Logar"),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Não é membro?",
                      style: TextStyle(color: tema.setentaCorFraca),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text(
                        "Registre-se",
                        style: TextStyle(color: tema.pretoEBrancoColor),
                      ),
                    ),
                  ],
                ),
                // Este SizedBox abaixo ajusta a altura quando o teclado está ativo
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

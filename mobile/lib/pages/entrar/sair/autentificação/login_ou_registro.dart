

import 'package:flutter/material.dart';
import 'package:talk_hub_vs2/pages/entrar/sair/login_page.dart';
import 'package:talk_hub_vs2/pages/entrar/sair/registro_page.dart';

class LoginOuRegistro extends StatefulWidget {
  const LoginOuRegistro({super.key});

 

  @override

  // ignore: library_private_types_in_public_api
  _LoginOuRegistroState createState() => _LoginOuRegistroState();
}

class _LoginOuRegistroState extends State<LoginOuRegistro> {
  bool showLoginPage = true;
  void escolhaPagina(){
    setState(() {
      showLoginPage= !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(showLoginPage){
      return LoginPage(onTap: escolhaPagina);
    }else{
      return RegistroPage(onTap: escolhaPagina);}
  }
}

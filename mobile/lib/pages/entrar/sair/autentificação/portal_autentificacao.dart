// ignore_for_file: library_private_types_in_public_api

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:talk_hub_vs2/pages/Pagina%20Inicio/inicial_page.dart';
import 'package:talk_hub_vs2/pages/entrar/sair/autentifica%C3%A7%C3%A3o/login_ou_registro.dart';


class Autentica extends StatefulWidget {
  const Autentica({super.key});
  
  
  @override
   _AutenticaState createState() => _AutenticaState();
  
 
}
class _AutenticaState extends State<Autentica> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(), builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if(snapshot.hasData){
            return const InicialPage();
          }
          else{return const LoginOuRegistro();}
        }
      ),
    );
  }
}


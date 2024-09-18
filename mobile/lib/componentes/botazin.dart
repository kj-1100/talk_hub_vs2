import 'package:flutter/material.dart';
import 'package:talk_hub_vs2/componentes/temas.dart';

class Botao extends StatefulWidget {
  final void Function()? onTap;
  final String texto;
  const Botao({super.key, required this.onTap, required this.texto});

  @override

  // ignore: library_private_types_in_public_api
  _BotaoState createState() => _BotaoState();
}

class _BotaoState extends State<Botao> {
  TemaDoApp tema = TemaDoApp();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.blueAccent.shade400,
          borderRadius: BorderRadius.circular(20),
        ),
        width: 150,
        child: Center(
          child: Text(
            widget.texto,
            style:  TextStyle(
                color: tema.pretoEBrancoColor, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

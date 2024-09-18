// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talk_hub_vs2/componentes/temas.dart';

class Preencha extends StatefulWidget {
  const Preencha({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
  });
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;

  @override
  _PreenchaState createState() => _PreenchaState();
}

class _PreenchaState extends State<Preencha> {
  @override
  Widget build(BuildContext context) {
    final tema = Provider.of<TemaDoApp>(context);

    return TextField(
      autofocus: true,
      controller: widget.controller,
      obscureText: widget.obscureText,
      cursorColor: Colors.blueAccent.shade700,
      style: TextStyle(color: tema.pretoEBrancoColor),
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: tema.setentaCorFraca),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blueAccent.shade700),
        ),
        fillColor: Colors.transparent,
        filled: true,
        hintText: widget.hintText,
        hintStyle: TextStyle(color: tema.setentaCorFraca),
      ),
    );
  }
}

class PreenchaNota extends StatefulWidget {
  const PreenchaNota({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
  });
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;

  @override
  _PreenchaNotaState createState() => _PreenchaNotaState();
}

class _PreenchaNotaState extends State<PreenchaNota> {
  @override
  Widget build(BuildContext context) {
    final tema = Provider.of<TemaDoApp>(context);

    return TextField(
      autofocus: true,
      controller: widget.controller,
      obscureText: widget.obscureText,
      cursorColor: Colors.blueAccent.shade700,
      style: TextStyle(color: tema.pretoEBrancoColor),
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: tema.setentaCorFraca),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blueAccent.shade700),
        ),
        fillColor: Colors.transparent,
        filled: true,
        hintText: widget.hintText,
        hintStyle: TextStyle(color: tema.setentaCorFraca),
      ),
      keyboardType: TextInputType.multiline,
      minLines: 1,
      maxLines: null,
    );
  }
}

class PreenchaEmail extends StatefulWidget {
  const PreenchaEmail({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
  });
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;

  @override
  _PreenchaEmailState createState() => _PreenchaEmailState();
}

class _PreenchaEmailState extends State<PreenchaEmail> {
  @override
  Widget build(BuildContext context) {
    final tema = Provider.of<TemaDoApp>(context);

    return TextField(
      autofocus: true,
      controller: widget.controller,
      obscureText: widget.obscureText,
      cursorColor: Colors.blueAccent.shade700,
      style: TextStyle(color: tema.pretoEBrancoColor),
      onChanged: (value) {
        if (value.isNotEmpty && value.endsWith(" ")) {
          widget.controller.text = value.substring(0, value.length - 1);
          widget.controller.selection = TextSelection.fromPosition(
              TextPosition(offset: widget.controller.text.length));
        }
      },
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: tema.setentaCorFraca),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blueAccent.shade700),
        ),
        fillColor: Colors.transparent,
        filled: true,
        hintText: widget.hintText,
        hintStyle: TextStyle(color: tema.setentaCorFraca),
      ),
    );
  }
}

class PreenchaSenha extends StatefulWidget {
  const PreenchaSenha({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
  }) : super(key: key);

  final TextEditingController controller;
  final String hintText;
  final bool obscureText;

  @override
  _PreenchaSenhaState createState() => _PreenchaSenhaState();
}

class _PreenchaSenhaState extends State<PreenchaSenha> {
  late bool escondeSenha;

  @override
  void initState() {
    super.initState();
    escondeSenha = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final tema = Provider.of<TemaDoApp>(context);

    return TextField(
      autofocus: true,
      controller: widget.controller,
      obscureText: escondeSenha,
      cursorColor: Colors.blueAccent.shade700,
      style: TextStyle(color: tema.pretoEBrancoColor),
      onChanged: (value) {
        if (value.isNotEmpty && value.endsWith(" ")) {
          widget.controller.text = value.substring(0, value.length - 1);
          widget.controller.selection = TextSelection.fromPosition(
              TextPosition(offset: widget.controller.text.length));
        }
      },
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: tema.setentaCorFraca),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blueAccent.shade700),
        ),
        fillColor: Colors.transparent,
        filled: true,
        hintText: widget.hintText,
        hintStyle: TextStyle(color: tema.setentaCorFraca),
        suffixIcon: IconButton(
          icon: Icon(
            escondeSenha ? Icons.visibility : Icons.visibility_off,
            color: tema.setentaCorFraca,
          ),
          onPressed: () {
            setState(() {
              escondeSenha = !escondeSenha;
            });
          },
        ),
      ),
    );
  }
}

// ignore_for_file: file_names, use_build_context_synchronously, unused_element

// Arquivo: nova_nota.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talk_hub_vs2/componentes/botazin.dart';
import 'package:talk_hub_vs2/componentes/meus_preencha.dart';
import 'package:talk_hub_vs2/componentes/temas.dart';
import 'package:talk_hub_vs2/pages/Pagina%20Inicio/inicial_page.dart';

import 'package:talk_hub_vs2/pages/notas/notas_manager.dart';

class NovaNota extends StatefulWidget {
  const NovaNota({Key? key, this.minhasNotas}) : super(key: key);
  final bool? minhasNotas;
  @override
  State<StatefulWidget> createState() => NovaNotaState();
}

class NovaNotaState extends State<NovaNota> {
  late double statusBarHeight;
  final TextEditingController tituloController = TextEditingController();
  final TextEditingController conteudoController = TextEditingController();
  late TemaDoApp tema;
  late bool minhasNotas;

  @override
  void initState() {
    super.initState();

    tema = Provider.of<TemaDoApp>(context, listen: false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    statusBarHeight = MediaQuery.of(context).padding.top;
    minhasNotas=widget.minhasNotas?? false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "Nova Nota",
            style: TextStyle(color: tema.pretoEBrancoColor),
          ),
          backgroundColor: tema.cabecarioColor,
          iconTheme: const IconThemeData(color: Colors.blueAccent),
          leading: IconButton(
            icon: const Icon(
              Icons.keyboard_arrow_left_outlined,
              color: Colors.blueAccent,
            ),
            onPressed: () {
              if (minhasNotas == true) {
                Navigator.pop(
                  context,
                  MaterialPageRoute(builder: (context) => const InicialPage()),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const InicialPage()),
                );
              }
            },
          ),
        ),
        backgroundColor: tema.backgroundColor,
        body: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Preencha(
                            controller: tituloController,
                            hintText: "titulo",
                            obscureText: false,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          PreenchaNota(
                            controller: conteudoController,
                            hintText: "sua Nota",
                            obscureText: false,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Botao(
                            onTap: () async {
                              // Criar uma nova nota com os dados inseridos
                              Nota novaNota = Nota(
                                titulo: tituloController.text,
                                conteudo: conteudoController.text,
                                data: DateTime.now()
                                    .toString(), // Adiciona a data atual
                              );
                              // Adicionar a nova nota ao gerenciador
                              NotasManager.notas.add(novaNota);
                              // Salvar as notas
                              await NotasManager.saveNotas();
                              // Navegar para a página de exibição de notas
                              Navigator.pop(context);
                            },
                            texto: "Salvar",
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

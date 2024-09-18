import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:talk_hub_vs2/componentes/temas.dart';
import 'package:talk_hub_vs2/pages/Pagina%20Inicio/inicial_page.dart';
import 'package:talk_hub_vs2/pages/notas/notas_manager.dart';
import 'package:talk_hub_vs2/pages/notas/nova_Nota.dart';
import 'delete_nota.dart';

class ExibirNota extends StatefulWidget {
  const ExibirNota({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ExibirNotaState();
}

class ExibirNotaState extends State<ExibirNota> {
  late double statusBarHeight;
  List<Nota> notas = [];
  late TemaDoApp tema;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    statusBarHeight = MediaQuery.of(context).padding.top;
  }

  @override
  void initState() {
    super.initState();
    _carregarNotas();
    tema = Provider.of<TemaDoApp>(context, listen: false);
  }

  Future<void> _carregarNotas() async {
    NotasManager.onNotasCarregadas = (notasCarregadas) {
      setState(() {
        notas = notasCarregadas;
      });
    };
    await NotasManager.carregarNotas();
  }

  void ordenarNotas(String criterio) {
    NotasManager.ordenarNotas(criterio: criterio);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Notas",
          style: TextStyle(color: tema.pretoEBrancoColor),
        ),
        backgroundColor: tema.cabecarioColor,
        leading: IconButton(
          icon: const Icon(
            Icons.keyboard_arrow_left_outlined,
            color: Colors.blueAccent,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const InicialPage()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: tema.pretoEBrancoColor),
            onPressed: () => _showOrdenar(context),
          ),
        ],
      ),
      backgroundColor: tema.backgroundColor,
      body: ListView.builder(
        itemCount: notas.length,
        itemBuilder: (context, index) {
          final nota = notas[index];
          return ExpansionTile(
            tilePadding:
                const EdgeInsets.symmetric(horizontal: 15.5, vertical: 7),
            iconColor: tema.pretoEBrancoColor,
            collapsedBackgroundColor: const Color.fromARGB(0, 5, 88, 143),
            backgroundColor: const Color.fromARGB(0, 171, 180, 185),
            title: Text(
              nota.titulo,
              style: const TextStyle(color: Colors.blueAccent),
            ),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      NotasManager.salvarNotaComoPDF(nota);
                    },
                    icon: Icon(Icons.download, color: tema.pretoEBrancoColor),
                  ),
                  IconButton(
                    onPressed: () {
                      NotasManager.partilarNotaComoPDF(nota);
                    },
                    icon: Icon(Icons.share, color: tema.pretoEBrancoColor),
                  )
                ],
              ),
              GestureDetector(
                // Use GestureDetector para detectar gestos, como pressão longa
                onLongPress: () {
                  _copyToClipboard(nota.conteudo);
                },
                child: Container(
                  decoration: BoxDecoration(color: tema.botoesTelaInicialColor),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                      ),
                      child: Text(
                        nota.conteudo,
                        style: TextStyle(color: tema.pretoEBrancoColor),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 50,
              )
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: tema.cabecarioColor,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.note_add_outlined, color: tema.pretoEBrancoColor),
            label: "Nova Nota",
          ),
          BottomNavigationBarItem(
            icon: SizedBox(
              height: 25,
              child: Image.asset("assets/icons/outline_note_delete.png",
                  color: tema.pretoEBrancoColor),
            ),
            label: "Deletar Notas",
          ),
        ],
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.blueAccent,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const NovaNota(minhasNotas: true)));
          } else if (index == 1) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const DeleteNota(minhasNotas: true)));
          }
        },
      ),
    );
  }

  void _copyToClipboard(String texto) {
    Clipboard.setData(ClipboardData(text: texto));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Texto copiado para a área de transferência'),
      ),
    );
  }

  void _showOrdenar(BuildContext context) async {
    final selected = await showMenu<int>(
      color: tema.popUplColor,
      context: context,
      position: RelativeRect.fromLTRB(
        MediaQuery.of(context).size.width - 24.0,
        kToolbarHeight + MediaQuery.of(context).padding.top,
        MediaQuery.of(context).size.width - 16.0,
        kToolbarHeight + 48.0 + MediaQuery.of(context).padding.top,
      ),
      items: [
        PopupMenuItem<int>(
          value: 1,
          child: Text(
            'Ordenar por título',
            style: TextStyle(
              color: tema.pretoEBrancoColor,
            ),
          ),
        ),
        PopupMenuItem<int>(
          value: 2,
          child: Text(
            'Ordenar por data',
            style: TextStyle(
              color: tema.pretoEBrancoColor,
            ),
          ),
        ),
      ],
    );

    if (selected != null) {
      switch (selected) {
        case 1:
          ordenarNotas('titulo');
          break;
        case 2:
          ordenarNotas('data');
          break;
      }
    }
  }
}

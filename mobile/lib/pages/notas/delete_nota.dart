import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talk_hub_vs2/componentes/temas.dart';
import 'package:talk_hub_vs2/pages/Pagina%20Inicio/inicial_page.dart';
import 'package:talk_hub_vs2/pages/notas/notas_manager.dart';

class DeleteNota extends StatefulWidget {
  const DeleteNota({Key? key, this.minhasNotas}) : super(key: key);
final bool? minhasNotas;
  @override
  State<StatefulWidget> createState() => DeleteNotaState();
}

class DeleteNotaState extends State<DeleteNota> {
  late double statusBarHeight;
  List<Nota> notas = [];
  late TemaDoApp tema;
  late bool minhasNotas;

  @override
  void initState() {
    super.initState();
    tema = Provider.of<TemaDoApp>(context, listen: false);
    NotasManager.carregarNotas().then((loadedNotas) {
      setState(() {
        notas = loadedNotas;
      });
    });
     minhasNotas=widget.minhasNotas?? false;
  }

  void _excluirNota(int index) {
    NotasManager.notas.removeAt(index);
    NotasManager.saveNotas();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    statusBarHeight = MediaQuery.of(context).padding.top;

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
           leading: IconButton(
            icon: const Icon(
              Icons.keyboard_arrow_left_outlined,
              color: Colors.blueAccent,
            ),
            onPressed: () {
              if (minhasNotas==true) {
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
          title: Text(
            "Deletar Nota",
            style: TextStyle(color: tema.pretoEBrancoColor),
          ),
          backgroundColor: tema.cabecarioColor,
          iconTheme: const IconThemeData(color: Colors.blueAccent),
        ),
        backgroundColor: tema.backgroundColor,
        body: Column(
          children: [
            Visibility(
              visible: notas.isNotEmpty,
              child: buildbotaoTodos(
                 _todosSelecionados(),
                 (value) => _selecionarTodos(value),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Nota>>(
                future: Future.value(notas),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Erro ao carregar notas: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: tema.cabecarioColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.warning_amber_outlined,
                              color: Color.fromARGB(255, 255, 98, 59),
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Não há notas para excluir.',
                              style: TextStyle(color: tema.pretoEBrancoColor),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    List<Nota> notas = snapshot.data!;
                    return ListView.builder(
                      itemCount: notas.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                            notas[index].titulo,
                            style: const TextStyle(color: Colors.blueAccent),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                value: notas[index].selecionada,
                                onChanged: (value) {
                                  setState(() {
                                    notas[index].selecionada = value ?? false;
                                  });
                                },
                                activeColor: Colors.blueAccent,
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _excluirNota(index),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _excluirNotasSelecionadas(notas),
          tooltip: 'Excluir Notas Selecionadas',
          backgroundColor: tema.cabecarioColor,
          child: Icon(
            Icons.delete_outline_sharp,
            color: tema.corFraca,
            size: 35,
          ),
        ),
      ),
    );
  }

  Widget buildbotaoTodos(bool value, ValueChanged<bool> onChanged) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: tema.cabecarioColor,
        ),
        child: ListTile(
          title: Text(
            'Selecionar Todos',
            style: TextStyle(color: tema.pretoEBrancoColor),
          ),
          trailing: Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.blueAccent,
          ),
        ),
      ),
    );
}


  bool _todosSelecionados() {
    return notas.isNotEmpty && notas.every((nota) => nota.selecionada);
  }

  void _selecionarTodos(bool? value) {
    for (Nota nota in notas) {
      nota.selecionada = value ?? false;
    }
    setState(() {});
  }

  void _excluirNotasSelecionadas(List<Nota> notas) {
    List<Nota> notasSelecionadas =
        notas.where((nota) => nota.selecionada).toList();
    for (Nota nota in notasSelecionadas) {
      NotasManager.notas.remove(nota);
    }
    NotasManager.saveNotas();
    setState(() {});
  }
}

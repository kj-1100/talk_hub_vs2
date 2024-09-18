import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talk_hub_vs2/componentes/temas.dart';
import 'package:talk_hub_vs2/pages/Pagina%20Inicio/inicial_page.dart';

class IconesNaTela extends StatefulWidget {
  final List<bool>? iconesVisiveis;

  const IconesNaTela({
    Key? key,
    this.iconesVisiveis,
  }) : super(key: key);

  @override
  State<IconesNaTela> createState() => _IconesNaTelaState();
}

class _IconesNaTelaState extends State<IconesNaTela> {
  late List<bool> manterStatus;
  late List<bool> tempManterStatus;
  late TemaDoApp tema;

  @override
  void initState() {
    super.initState();
    manterStatus = widget.iconesVisiveis ?? List.filled(11, false);
    tempManterStatus = List.from(manterStatus);
    tema = Provider.of<TemaDoApp>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const iconSize = 128.0;
    final columns = (screenWidth / iconSize).floor();

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 35),
            child: Text(
              "Seleção",
              style: TextStyle(color: tema.pretoEBrancoColor),
            ),
          ),
        ),
        backgroundColor: tema.cabecarioColor,
           leading: IconButton(
          icon: const Icon(
            Icons.keyboard_arrow_left_outlined,
            color: Colors.blueAccent,
          ),
          onPressed: () {
            Navigator.pop(
              context,
              MaterialPageRoute(builder: (context) => const InicialPage()),
            );
          },
        ),
      ),
      backgroundColor: tema.backgroundColor,
      body: GridView.builder(
        itemCount: tempManterStatus.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemBuilder: (context, index) {
          return _buildIconButton(index);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            manterStatus = List.from(tempManterStatus);
          });

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InicialPage(
                manterStatus: manterStatus,
                anuncioAddIconTelaInicial: false,
              ),
            ),
          );
        },
        backgroundColor: tema.cabecarioColor,
        child: Icon(
          Icons.save,
          color: tema.setentaCorFraca,
          size: 35,
        ),
      ),
    );
  }

  Widget _buildIconButton(int index) {
    return Card(
      color: tempManterStatus[index] ? Colors.blueAccent : Colors.black,
      child: SizedBox(
        width: 128,
        height: 129.5,
        child: Padding(
          padding: tempManterStatus[index]
              ? const EdgeInsets.all(1.5)
              : const EdgeInsets.all(8.0),
          child: Material(
            color: tempManterStatus[index]
                ? tema.botoesTelaInicialColor
                : const Color.fromARGB(255, 10, 10, 10),
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: () {
                setState(() {
                  tempManterStatus[index] = !tempManterStatus[index];
                });
              },
              borderRadius: BorderRadius.circular(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _getIconData(index),
                  const SizedBox(height: 8),
                  Text(
                    _getButtonText(index),
                    style: TextStyle(
                      color: tema.pretoEBrancoColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getIconData(int index) {
    switch (index) {
      case 0:
        return Icon(Icons.person_add, color: tema.pretoEBrancoColor);
      case 1:
        return Icon(Icons.notifications_outlined,
            color: tema.pretoEBrancoColor);
      case 2:
        return Icon(Icons.person, color: tema.pretoEBrancoColor);
      case 3:
        return Icon(Icons.group, color: tema.pretoEBrancoColor);
      case 4:
        return Icon(Icons.account_circle, color: tema.pretoEBrancoColor);
      case 5:
        return Icon(Icons.edit, color: tema.pretoEBrancoColor);
      case 6:
        return SizedBox(
          height: 30,
          child: Image.asset("assets/icons/chatBot.png",
              color: tema.pretoEBrancoColor),
        );
      case 7:
        return Icon(Icons.note_add_outlined, color: tema.pretoEBrancoColor);
      case 8:
        return Icon(Icons.note_outlined, color: tema.pretoEBrancoColor);
      case 9:
        return SizedBox(
          height: 25,
          child: Image.asset("assets/icons/outline_note_delete.png",
              color: tema.pretoEBrancoColor),
        );
      case 10:
        return Icon(Icons.logout_outlined, color: tema.pretoEBrancoColor);
      default:
        // Deletar nota
        return Icon(Icons.error, color: tema.pretoEBrancoColor);
    }
  }

  String _getButtonText(int index) {
    switch (index) {
      case 0:
        return "Usuários";
      case 1:
        return "Solicitações e Convites";
      case 2:
        return "Amigos";
      case 3:
        return "Grupos";
      case 4:
        return "Foto Perfil";
      case 5:
        return "Editar Nome";
      case 6:
        return "Ajuda";
      case 7:
        return "Nova Nota";
      case 8:
        return "Notas";
      case 9:
        return "Apagar Notas";
      case 10:
        return "Sair";
      default:
        return "Erro";
    }
  }
}


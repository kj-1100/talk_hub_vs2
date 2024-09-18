import 'package:flutter/material.dart';
import 'package:talk_hub_vs2/pages/Pagina%20Inicio/inicial_page.dart';

class IconesNaTela extends StatefulWidget {
  const IconesNaTela({Key? key}) : super(key: key);

  @override
  State<IconesNaTela> createState() => _IconesNaTelaState();
}

class _IconesNaTelaState extends State<IconesNaTela> {
  List<bool> manterStatus = List.filled(8, false);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const iconSize = 128.0;
    final columns = (screenWidth / iconSize).floor();


    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Padding(
            padding: EdgeInsets.only(right: 35),
            child: Text(
              "::.próxima.::",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        backgroundColor: const Color.fromARGB(175, 1, 28, 40),
        iconTheme: const IconThemeData(color: Colors.blueAccent),
      ),
      backgroundColor: const Color.fromARGB(255, 23, 33, 46),
      body: GridView.builder(
        itemCount: manterStatus.length,
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InicialPage(manterStatus: manterStatus,anuncioAddIconesTelaInicialDoSelecionar:false),
            ),
          );
        },
        backgroundColor: const Color.fromARGB(255, 1, 28, 40),
        child: const Icon(
          Icons.save,
          color: Colors.white70,
          size: 35,
        ),
      ),
    );
  }

  Widget _buildIconButton(int index) {
    return Card(
      color: manterStatus[index] ? Colors.grey : Colors.black,
      child: SizedBox(
        width: 128,
        height: 129.5,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Material(
            color: manterStatus[index] ? Colors.grey : Colors.black,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: () {
                setState(() {
                  manterStatus[index] = !manterStatus[index];
                });
              },
              borderRadius: BorderRadius.circular(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getIconData(index),
                    color: manterStatus[index] ? Colors.blue : Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getButtonText(index),
                    style: TextStyle(
                      color: manterStatus[index] ? Colors.blue : Colors.white,
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

  IconData _getIconData(int index) {
    switch (index) {
      case 0:
        return Icons.person_add;
      case 1:
        return Icons.notifications_outlined;
      case 2:
        return Icons.person;
      case 3:
        return Icons.group;
      case 4:
        return Icons.account_circle;
      case 5:
        return Icons.edit;
      case 6:
        return Icons.help;
      case 7:
        return Icons.logout_outlined;
      default:
        return Icons.error;
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
        return "Sair";
      default:
        return "Erro";
    }
  }
}

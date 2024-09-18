// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, avoid_print

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talk_hub_vs2/componentes/temas.dart';

class ExibirImagemPage extends StatefulWidget {
  final String imageUrl;
  final String isVideo;

  const ExibirImagemPage({
    Key? key,
    required this.imageUrl,
    required this.isVideo,
  }) : super(key: key);

  @override
  _ExibirImagemPageState createState() => _ExibirImagemPageState();
}

class _ExibirImagemPageState extends State<ExibirImagemPage> {
  final ScrollController _scrollController = ScrollController();
  bool aviso = false;
  late TemaDoApp tema;

  @override
  void initState() {
    super.initState();
    _loadAvisoStatus();
    tema = Provider.of<TemaDoApp>(context, listen: false);
  }

  Future<void> _loadAvisoStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      aviso = prefs.getBool('aviso') ?? false;
    });
  }

  Future<void> _saveAvisoStatus(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('aviso', value);
  }

  Future<void> _baixarArquivo(BuildContext context) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Download iniciado'),
        backgroundColor: Colors.blueAccent,
      ));
      final response = await http.get(Uri.parse(widget.imageUrl));
      if (response.statusCode == 200) {
        final status = await Permission.storage.request();
        if (status.isGranted) {
          String fileName = '';
          String downloadsPath = '';

          switch (widget.isVideo) {
            case "foto":
              fileName = 'IMG_${DateTime.now().millisecondsSinceEpoch}.jpg';
              downloadsPath = '/storage/emulated/0/Pictures/TalkHUB (Fotos)';
              break;
            case "video":
              fileName = 'VID_${DateTime.now().millisecondsSinceEpoch}.mp4';
              downloadsPath = '/storage/emulated/0/Pictures/TalkHUB (Video)';
              break;
            case "pdf":
              fileName = 'Pdf_${DateTime.now().millisecondsSinceEpoch}.pdf';
              downloadsPath = '/storage/emulated/0/Download';
              break;
            default:
              // Defina valores padrão ou tratamento para o caso padrão, se necessário
              break;
          }

          final Directory directory = Directory(downloadsPath);
          if (!await directory.exists()) {
            await directory.create(recursive: true);
          }

          final File file = File('$downloadsPath/$fileName');
          await file.writeAsBytes(response.bodyBytes);
          print("Arquivo baixado para: ${file.path}");

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Download concluído'),
              backgroundColor: Colors.green,
            ),
          );
          if (!aviso) {
            _showAvisoDialog(context);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Permissão negada para acessar o armazenamento externo'),
              backgroundColor: Colors.red,
            ),
          );
          print("Permissão negada para acessar o armazenamento externo");
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao baixar o arquivo'),
            backgroundColor: Colors.red,
          ),
        );
        print("Erro ao baixar o arquivo");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao baixar o arquivo'),
          backgroundColor: Colors.red,
        ),
      );
      print("Erro: $e");
    }
  }

  void _showAvisoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: tema.popUplColor,
          title: const Text(
            'Baixar Arquivo',
            style: TextStyle(
              color: Colors.blueAccent,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Caso a imagem/vídeo não apareça na galeria, reinicie o aparelho.',
                style: TextStyle(color: tema.pretoEBrancoColor, fontSize: 17),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Text(
                      "Ao clicar em ",
                      style: TextStyle(
                        color: tema.corFraca,
                      ),
                    ),
                    Text(
                      "OK ",
                      style: TextStyle(
                        color: tema.setentaCorFraca,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "esse aviso não será mais ",
                      style: TextStyle(
                        color: tema.corFraca,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "exibido",
                style: TextStyle(
                  color: tema.corFraca,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  aviso = true;
                });
                _saveAvisoStatus(true);
              },
              child: const Text(
                "OK",
                style: TextStyle(color: Colors.blueAccent),
              ),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tema.backgroundColor,
      appBar: AppBar(
        backgroundColor: tema.cabecarioColor,
        leading: IconButton(
          icon: const Icon(
            Icons.keyboard_arrow_left_outlined,
            color: Colors.blueAccent,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Baixar Imagem",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            controller: _scrollController,
            children: [
              Container(
                  decoration: BoxDecoration(
                    color: tema.isDarkMode
                        ? const Color.fromARGB(255, 231, 233, 235)
                        : const Color.fromARGB(255, 33, 43, 54),
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: tema.isDarkMode
                          ? const Color.fromARGB(255, 231, 233, 235)
                          : const Color.fromARGB(255, 33, 43, 54),
                      width: 5.0,
                    ),
                  ),
                  child: _buildTipoDeMidia()),
              const SizedBox(height: 20.0),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(tema.cabecarioColor),
                ),
                onPressed: () {
                  _baixarArquivo(context);
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.download_outlined, color: Colors.blueAccent),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipoDeMidia() {
    switch (widget.isVideo) {
      case "video":
        return Container(
          height: 550,
          width: 400,
          color: const Color.fromARGB(230, 1, 28, 40),
          child: Icon(
            Icons.play_arrow,
            color: tema.pretoEBrancoColor,
            size: 80,
          ),
        );
      case "foto":
        return Image.network(
          widget.imageUrl,
          fit: BoxFit.cover,
        );
      case "pdf":
        return Container(
          alignment: Alignment.center,
          height: 300,
          width: 400,
          color: Colors.red,
          child: const Text(
            "PDF",
            style: TextStyle(
              color: Colors.white,
              fontSize: 80,
            ),
          ),
        );
      default:
        // Deletar nota
        return Icon(
          Icons.error,
          color: tema.pretoEBrancoColor,
          size: 30,
        );
    }
  }
}

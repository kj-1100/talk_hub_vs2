// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:pdf/pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
//import 'package:path_provider/path_provider.dart';

typedef NotasCarregadasCallback = void Function(List<Nota> notas);

class NotasManager {
  static NotasCarregadasCallback? onNotasCarregadas;
  static List<Nota> notas = [];

  static Future<List<Nota>> carregarNotas() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? notasString = prefs.getString('notas');

      if (notasString != null && notasString.isNotEmpty) {
        List<dynamic> notasList = jsonDecode(notasString);

        notas = notasList
            .map((notaMap) => Nota.fromMap(Map<String, dynamic>.from(notaMap)))
            .toList();
      } else {
        notas = [];
      }
    } catch (e) {
      // Trate o erro de carregamento, se necessário
      notas = [];
    }

    if (onNotasCarregadas != null) {
      onNotasCarregadas!(notas);
    }
    return notas;
  }

  static Future<void> saveNotas() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String notasString =
          jsonEncode(notas.map((nota) => nota.toMap()).toList());
      await prefs.setString('notas', notasString);
    } catch (e) {
      // Trate o erro de salvamento, se necessário
      print('Erro ao salvar notas: $e');
    }
  }

  // Método para ordenar as notas
  static void ordenarNotas({String criterio = 'titulo'}) {
    if (criterio == 'titulo') {
      notas.sort((a, b) => a.titulo.compareTo(b.titulo));
    } else if (criterio == 'data') {
      notas.sort((a, b) => a.data.compareTo(b.data));
    }
    // Chame o callback após ordenar
    if (onNotasCarregadas != null) {
      onNotasCarregadas!(notas);
    }
  }

  // Método para salvar uma nota como PDF
  static Future<void> salvarNotaComoPDF(Nota nota) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(20),
            color: PdfColor.fromHex("#424242"), // Cor de fundo cinza
            alignment: pw.Alignment.center,
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  nota.titulo,
                  style: pw.TextStyle(
                    fontSize: 24,
                    color: PdfColor.fromHex("#FFFFFF"), // Cor do texto branco
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  nota.conteudo,
                  style: pw.TextStyle(
                    color: PdfColor.fromHex("#FFFFFF"), // Cor do texto branco
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    // Obter o diretório de downloads do dispositivo
    const String caminhoDoDiretorioDeDownloads = '/storage/emulated/0/Download';
    final String caminhoCompleto =
        '$caminhoDoDiretorioDeDownloads/${nota.titulo}.pdf';

    // Salvar o documento PDF no diretório de downloads
    final File arquivo = File(caminhoCompleto);
    await arquivo.writeAsBytes(await pdf.save());

    // Mostre uma mensagem ou faça qualquer outra coisa que seja necessária após salvar o PDF
    print('PDF salvo em: $caminhoCompleto');
  }

  // Método para salvar uma nota como PDF
  static Future<void> partilarNotaComoPDF(Nota nota) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        margin: pw.EdgeInsets.zero,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(20),
            color: PdfColor.fromHex("#424242"), // Cor de fundo cinza
            alignment: pw.Alignment.center,
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  nota.titulo,
                  style: pw.TextStyle(
                    fontSize: 24,
                    color: PdfColor.fromHex("#FFFFFF"), // Cor do texto branco
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  nota.conteudo,
                  style: pw.TextStyle(
                    color: PdfColor.fromHex("#FFFFFF"), // Cor do texto branco
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    // Obter o diretório de downloads do dispositivo
    const String caminhoDoDiretorioDeDownloads = '/storage/emulated/0/Download';
    final String caminhoCompleto =
        '$caminhoDoDiretorioDeDownloads/${nota.titulo}.pdf';
    final File arquivo = File(caminhoCompleto);
    arquivo.writeAsBytes(await pdf.save()).then((_) {
      print('PDF salvo em: $caminhoCompleto');
    }).catchError((error) {
      print('Erro ao salvar o PDF: $error');
    });
  }

  ////////multi paginas imcompleto ////
// static Future<void> salvarNotaComoPDF(Nota nota) async {
//     final pdf = pw.Document();
//     pdf.addPage(
//       pw.MultiPage(
//         margin: pw.EdgeInsets.zero,
//         build: (pw.Context context) => [
//           pw.Container(
//             padding: const pw.EdgeInsets.all(20),
//             color: PdfColor.fromHex("#424242"), // Cor de fundo cinza
//             alignment: pw.Alignment.center,
//             child: pw.Column(
//               mainAxisAlignment: pw.MainAxisAlignment.center,
//               children: [
//                 pw.Text(
//                   nota.titulo,
//                   style: pw.TextStyle(
//                     fontSize: 24,
//                     color: PdfColor.fromHex("#FFFFFF"), // Cor do texto branco
//                   ),
//                 ),
//                 pw.SizedBox(height: 10),
//                 pw.Text(
//                   nota.conteudo,
//                   style: pw.TextStyle(
//                     color: PdfColor.fromHex("#FFFFFF"), // Cor do texto branco
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//     const String caminhoDoDiretorioDeDownloads = '/storage/emulated/0/Download';
//     final String caminhoCompleto =
//         '$caminhoDoDiretorioDeDownloads/${nota.titulo}.pdf';
//     final File arquivo = File(caminhoCompleto);
//     await arquivo.writeAsBytes(await pdf.save());
//     print('PDF salvo em: $caminhoCompleto');
//   }
}

class Nota {
  final String titulo;
  final String conteudo;
  final String data; // Propriedade data adicionada
  bool selecionada;

  Nota({
    required this.titulo,
    required this.conteudo,
    required this.data, // Faça a data um parâmetro obrigatório
    this.selecionada = false,
  });

  Map<String, dynamic> toMap() {
    return {'titulo': titulo, 'conteudo': conteudo, 'data': data};
  }

  factory Nota.fromMap(Map<String, dynamic> map) {
    return Nota(
      titulo: map['titulo'] ?? '',
      conteudo: map['conteudo'] ?? '',
      data: map['data'] ?? DateTime.now().toString(),
    );
  }

  Nota copyWith({bool? selecionada}) {
    return Nota(
      titulo: titulo,
      conteudo: conteudo,
      data: data,
      selecionada: selecionada ?? this.selecionada,
    );
  }
}

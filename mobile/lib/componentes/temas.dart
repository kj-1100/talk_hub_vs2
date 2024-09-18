

// ignore_for_file: unused_import, avoid_print

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TemaDoApp extends ChangeNotifier {
  Color get botoesTelaInicialColor => _botoesTelaInicialColor;
  Color _botoesTelaInicialColor = const Color.fromARGB(175, 1, 28, 40);
  Color get backgroundColor => _backgroundColor;
  Color _backgroundColor = const Color.fromARGB(255, 23, 33, 46);
  Color get corFraca => _corFraca;
  Color _corFraca = Colors.white38;
  Color get pretoEBrancoColor => _pretoEBrancoColor;
  Color _pretoEBrancoColor = Colors.white;
  Color get cabecarioColor => _cabecarioColor;
  Color _cabecarioColor = const Color.fromARGB(175, 1, 28, 40);
  Color get mensagemUserColor => _mensagemUserColor;
  Color _mensagemUserColor = const Color.fromARGB(255, 33, 43, 54);
  Color get popUplColor => _popUplColor;
  Color _popUplColor = const Color.fromARGB(175, 1, 28, 40);
  Color get setentaCorFraca => _setentaCorFraca;
  Color _setentaCorFraca = Colors.white70;
  bool get isDarkMode => _isDarkMode;
  bool _isDarkMode = true;

  void changeBackgroundColor() {
    _backgroundColor = _backgroundColor == const Color.fromARGB(255, 23, 33, 46)
        ? const Color.fromARGB(255, 255, 255, 255)
        : const Color.fromARGB(255, 23, 33, 46);

    notifyListeners();
  }

  void changeBrancoPraPreto() {
    _pretoEBrancoColor =
        _pretoEBrancoColor == Colors.white ? Colors.black : Colors.white;

    notifyListeners(); // Certifique-se de chamar notifyListeners() após as alterações.
  }

  void changeCabecarioColor() {
    _cabecarioColor = _cabecarioColor == const Color.fromARGB(175, 1, 28, 40)
        ? const Color.fromARGB(255, 96, 125, 139)
        : const Color.fromARGB(175, 1, 28, 40);

    notifyListeners();
  }

  void changeBotoesTelaInicialColor() {
    _botoesTelaInicialColor =
        _botoesTelaInicialColor == const Color.fromARGB(175, 1, 28, 40)
            ? const Color.fromARGB(220, 255, 244, 227)
            : const Color.fromARGB(175, 1, 28, 40);

    notifyListeners();
  }

  void changePopUpColor() {
    _popUplColor = _popUplColor == const Color.fromARGB(175, 1, 28, 40)
        ? const Color.fromARGB(255, 231, 233, 235)
        : const Color.fromARGB(175, 1, 28, 40);

    notifyListeners();
  }

  void changeMensagemUserColor() {
    _mensagemUserColor =
        _mensagemUserColor == const Color.fromARGB(255, 33, 43, 54)
            ? const Color.fromARGB(255, 231, 233, 235)
            : const Color.fromARGB(255, 33, 43, 54);

    notifyListeners();
  }

  void changeCorFraca() {
    _corFraca = _corFraca == Colors.white54 ? Colors.black54 : Colors.white54;

    notifyListeners();
  }

  void change70CorFraca() {
    _setentaCorFraca = _setentaCorFraca == Colors.white70
        ? const Color.fromARGB(179, 0, 0, 0)
        : Colors.white70;
    notifyListeners();
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    changePopUpColor();
    changeBackgroundColor();
    changeBrancoPraPreto();
    changeCabecarioColor();
    changeMensagemUserColor();
    changeCorFraca();
    change70CorFraca();
    changeBotoesTelaInicialColor();
    notifyListeners();
    saveThemeState();
  }

  Future<void> saveThemeState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', _isDarkMode);
    prefs.setInt('_backgroundColor', _backgroundColor.value);
    prefs.setInt('_brancoPraPreto', _pretoEBrancoColor.value);
    prefs.setInt('_cabecarioColor', _cabecarioColor.value);
    prefs.setInt('_nomeUserColor', _mensagemUserColor.value);
    prefs.setInt('_corFraca', _corFraca.value);
    prefs.setInt('_b70CorFraca', _setentaCorFraca.value);
    prefs.setInt('_botoesTelaInicialColor', _botoesTelaInicialColor.value);
    prefs.setInt('_popUplColor', _popUplColor.value);
  }

  List<String> _favoritos = [];

  List<String> get favoritos => _favoritos;

// Método para carregar o estado do tema das preferências
  Future<void> loadThemeState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? true;
    _backgroundColor = Color(prefs.getInt('_backgroundColor') ??
        const Color.fromARGB(255, 23, 33, 46).value);
    _pretoEBrancoColor =
        Color(prefs.getInt('_brancoPraPreto') ?? Colors.white.value);
    _cabecarioColor = Color(prefs.getInt('_cabecarioColor') ??
        const Color.fromARGB(175, 1, 28, 40).value);
    _mensagemUserColor = Color(prefs.getInt('_mensagemUserColor') ??
        const Color.fromARGB(255, 33, 43, 54).value);
    _corFraca = Color(prefs.getInt('_corFraca') ?? Colors.white38.value);
    _setentaCorFraca =
        Color(prefs.getInt('_70CorFraca') ?? Colors.white70.value);
    _botoesTelaInicialColor = Color(prefs.getInt('_botoesTelaInicialColor') ??
        const Color.fromARGB(175, 1, 28, 40).value);
    _popUplColor = Color(prefs.getInt('_popUplColor') ??
        const Color.fromARGB(175, 1, 28, 40).value);
    notifyListeners();
  }

  Future<List<String>> recuperarFavoritosLocalmente() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? favoritosTemp = prefs.getStringList('favoritos');

    _favoritos = favoritosTemp ?? []; // Atualiza o estado dos favoritos
    print(_favoritos);
    return _favoritos;
  }

  Future<void> salvarFavoritosLocalmente(List<String> favoritos) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favoritos', favoritos);
  }
}

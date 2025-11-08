import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://areal.smgengenharia.com.br/api';

  static Future<double> getPrecoM3() async {
    final response = await http.get(Uri.parse('$baseUrl/configuracoes.php'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['preco_m3'] as num).toDouble();
    }
    throw Exception('Erro ao buscar preço');
  }

  static Future<bool> syncApontador(Map<String, dynamic> dados) async {
    final response = await http.post(
      Uri.parse('$baseUrl/apontador-sync.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(dados),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['sucesso'] == true;
    }
    return false;
  }

  static Future<bool> syncOperador(Map<String, dynamic> dados) async {
    final response = await http.post(
      Uri.parse('$baseUrl/operador-sync.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(dados),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['sucesso'] == true;
    }
    return false;
  }
}
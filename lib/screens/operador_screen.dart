import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/sync_service.dart';
import 'dart:convert';

class OperadorScreen extends StatefulWidget {
  const OperadorScreen({super.key});

  @override
  State<OperadorScreen> createState() => _OperadorScreenState();
}

class _OperadorScreenState extends State<OperadorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _placaController = TextEditingController();
  final _quantidadeController = TextEditingController();
  
  double? _precoM3;
  double _valorTotal = 0.0;
  File? _foto;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _carregarPreco();
  }

  Future<void> _carregarPreco() async {
    setState(() => _loading = true);
    try {
      final preco = await ApiService.getPrecoM3();
      setState(() {
        _precoM3 = preco;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar preço: $e')),
        );
      }
    }
  }

  void _calcularValorTotal() {
    if (_precoM3 == null) return;
    final quantidade = double.tryParse(_quantidadeController.text) ?? 0.0;
    setState(() {
      _valorTotal = quantidade * _precoM3!;
    });
  }

  Future<void> _tirarFoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _foto = File(image.path);
      });
    }
  }

  Future<void> _salvarRegistro() async {
    if (!_formKey.currentState!.validate()) return;
    if (_precoM3 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aguarde o carregamento do preço')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final gps = await SyncService.getGPS();
      String? fotoBase64;
      if (_foto != null) {
        final bytes = await _foto!.readAsBytes();
        fotoBase64 = base64Encode(bytes);
      }

      await StorageService.instance.salvarOperador(
        placa: _placaController.text,
        metrosCubicos: double.parse(_quantidadeController.text),
        valorCalculado: _valorTotal,
        latitude: gps['latitude'],
        longitude: gps['longitude'],
        foto: fotoBase64,
      );

      await SyncService.syncOperador();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registro salvo com sucesso!')),
        );
        _placaController.clear();
        _quantidadeController.clear();
        setState(() {
          _valorTotal = 0.0;
          _foto = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Operador - Entrada'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      color: Colors.green.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Preço m³: R\$ ${_precoM3?.toStringAsFixed(2) ?? '...'}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _placaController,
                      decoration: const InputDecoration(
                        labelText: 'Placa do Veículo',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.local_shipping),
                      ),
                      textCapitalization: TextCapitalization.characters,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Digite a placa';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _quantidadeController,
                      decoration: const InputDecoration(
                        labelText: 'Quantidade (m³)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.straighten),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _calcularValorTotal(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Digite a quantidade';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Digite um número válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Card(
                      color: Colors.orange.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Valor Total: R\$ ${_valorTotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      onPressed: _tirarFoto,
                      icon: const Icon(Icons.camera_alt),
                      label: Text(_foto == null ? 'Tirar Foto (Opcional)' : 'Foto Capturada ✓'),
                    ),
                    if (_foto != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Image.file(_foto!, height: 200),
                      ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _salvarRegistro,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                      ),
                      child: const Text(
                        'CONFIRMAR ENTRADA',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _placaController.dispose();
    _quantidadeController.dispose();
    super.dispose();
  }
}
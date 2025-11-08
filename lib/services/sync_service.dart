import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'storage_service.dart';
import 'api_service.dart';

class SyncService {
  static Future<Map<String, double?>> getGPS() async {
    try {
      var status = await Permission.location.status;
      if (!status.isGranted) {
        status = await Permission.location.request();
        if (!status.isGranted) {
          return {'latitude': null, 'longitude': null};
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
      };
    } catch (e) {
      print('Erro ao obter GPS: $e');
      return {'latitude': null, 'longitude': null};
    }
  }

  static Future<void> syncApontador() async {
    try {
      final registros = await StorageService.instance
          .getRegistrosNaoSincronizadosApontador();

      for (var registro in registros) {
        final sucesso = await ApiService.syncApontador({
          'placa': registro['placa'],
          'metros_cubicos': registro['metros_cubicos'],
          'valor_calculado': registro['valor_calculado'],
          'latitude': registro['latitude'],
          'longitude': registro['longitude'],
          'foto': registro['foto'],
        });

        if (sucesso) {
          await StorageService.instance
              .marcarComoSincronizadoApontador(registro['id']);
        }
      }
    } catch (e) {
      print('Erro na sincronização apontador: $e');
    }
  }

  static Future<void> syncOperador() async {
    try {
      final registros = await StorageService.instance
          .getRegistrosNaoSincronizadosOperador();

      for (var registro in registros) {
        final sucesso = await ApiService.syncOperador({
          'placa': registro['placa'],
          'metros_cubicos': registro['metros_cubicos'],
          'valor_calculado': registro['valor_calculado'],
          'latitude': registro['latitude'],
          'longitude': registro['longitude'],
          'foto': registro['foto'],
        });

        if (sucesso) {
          await StorageService.instance
              .marcarComoSincronizadoOperador(registro['id']);
        }
      }
    } catch (e) {
      print('Erro na sincronização operador: $e');
    }
  }
}
import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:video_player/video_player.dart';

class MyVideoProvider with ChangeNotifier {
  VideoPlayerController? _vCont;
  VideoPlayerController? get getVidCont => _vCont;
  bool isSaved = false;

  void initializeVideoPlayer(String filePath) async {
    // inicializar el video player
    _vCont = await VideoPlayerController.file(File(filePath))
      ..addListener(() => notifyListeners())
      ..setLooping(false)
      ..initialize().then((value) async {
        //: cargar el progreso guardado del video
        await loadConfigs();
        notifyListeners();
      });
  }

  void isPlayOrPause(bool isPlay) {
    if (isPlay) {
      _vCont!.pause();
    } else {
      _vCont!.play();
    }
    notifyListeners();
  }

  //Abrir la base de datos y crear tabla
  Future<Database> abrirBD() async {
    final database = openDatabase(
      join(await getDatabasesPath(), 'video.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE registros(id INTEGER PRIMARY KEY, minutos TEXT)',
        );
      },
      version: 1,
    );
    return database;
  }

  // 6: cargar datos
  Future<void> loadConfigs() async {
    final db = await abrirBD();
    final List<Map<String, dynamic>> maps = await db.query('registros');
    if (maps.isNotEmpty) {
      int milis = int.parse(maps.last['minutos']);
      Duration position = Duration(milliseconds: milis);
      await _vCont!.seekTo(position);
      await _vCont!.setVolume(1);

      print(position);
    }
    notifyListeners();
  }

  // 10: guardar datos
  Future<void> saveConfigs() async {
    try {
      final db = await abrirBD();
      final id = DateTime.now().millisecondsSinceEpoch;
      Duration position = _vCont!.value.position;
      final progresoMap = {
        'id': id,
        'minutos': position.inMilliseconds,
      };
      await db.insert(
        'registros',
        progresoMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      isSaved = true;
      print(progresoMap);

      notifyListeners();
    } catch (e) {
      print("Error al guardar: ${e.toString()}");
      isSaved = false;
      notifyListeners();
    }
  }
}

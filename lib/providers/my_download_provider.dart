import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class MyDownloadProvider with ChangeNotifier {
  bool isPermissionGranted = false;
  bool? isSavedSuccess;
  bool? isDeletedSuccess;
  bool isLoading = false;
  String videoName = "butterfly";
  String? videoPath;
  String videoUrl =
      "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4";

  Future<void> descargarVideo() async {
    // 1: hacer el metodo para descargar video
    try {
      isLoading = true;
      notifyListeners();

      var response = await get(Uri.parse(videoUrl));

      if (response.statusCode == 200) {
        // Convertimos los datos en una lista de bytes (Uint8List)
        await _saveFile(response.bodyBytes);
      }
      // Actualizamos el estado
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isSavedSuccess = false;
      isLoading = false;
      print("Error al descargar archivo: ${e.toString()}");
      notifyListeners();
    }
  }

  Future<void> eliminarVideo() async {
    if (videoPath != null) {
      File file = File(videoPath!);
      if (file.existsSync()) {
        await file.delete(); //Eliminamos el archivo si este existe

        print("Archivo eliminado de $videoPath");
        videoPath = null;
        isSavedSuccess = null;
        isDeletedSuccess = true;
        notifyListeners();
      } else {
        print("El archivo no existe ne la ruta $videoPath");
      }
    } else {
      print("La ruta no está definida, no es posible eliminar");
    }
  }

  Future<bool> _requestStoragePermission() async {
    // 2: hacer el metodo para solicitar acceso al almacenamiento
    var status = await Permission.storage.request();
    if (status == PermissionStatus.denied) {
      //Si el permiso no se dio
      await Permission.storage.request();
    }
    return status == PermissionStatus.granted;
  }

  Future<void> _saveFile(Uint8List _content) async {
    // 3. Revisar si tenemos permisos
    if (!await _requestStoragePermission()) {
      isLoading = false;
      isPermissionGranted = false;
      notifyListeners();
      return;
    }
    //4. Acceso al storage, revisar plataformas y almacenamientos
    Directory? dir;
    if (Platform.isAndroid) {
      dir = await getExternalStorageDirectory();
    } else if (Platform.isIOS) {
      dir = await getApplicationDocumentsDirectory();
    } else {
      dir = await getApplicationSupportDirectory();
    }
    //5. Escribir archivo en almacenamiento
    videoPath = "${dir!.path}/$videoName.mp4";
    File file = File(videoPath!);
    file.writeAsBytes(_content); //Content es un arreglo de bytes.
    isSavedSuccess = true;
    isLoading = false;
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'package:video_downlad/home_page.dart';
import 'package:provider/provider.dart';
import 'package:video_downlad/providers/my_download_provider.dart';
import 'package:video_downlad/providers/my_video_provider.dart';

void main() async {
  // inicializar BD
  WidgetsFlutterBinding.ensureInitialized();
  final myVideoProvider = MyVideoProvider();
  await myVideoProvider.abrirBD();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
      ),
      home: ChangeNotifierProvider(
        create: (context) => MyDownloadProvider(),
        child: HomePage(),
      ),
    );
  }
}

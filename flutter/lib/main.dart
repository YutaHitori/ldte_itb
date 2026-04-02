import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ldte_itb/core/custom-widget.dart';
import 'package:ldte_itb/form/pinjam.dart';
import 'package:ldte_itb/homepage.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting('id_ID');

  runApp(
    GetMaterialApp(
      theme: appTheme,
      title: 'LDTE ITB',
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => Homepage()),
        GetPage(name: '/form/pinjam', page: () => Pinjam()),
      ],
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}

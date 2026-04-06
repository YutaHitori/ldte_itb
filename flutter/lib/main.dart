import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:form_itb/core/custom-widget.dart';
import 'package:form_itb/form/pinjam.dart';
import 'package:form_itb/homepage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:url_strategy/url_strategy.dart';

void main() {
  if (kIsWeb) setPathUrlStrategy();
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

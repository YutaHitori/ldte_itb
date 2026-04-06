import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Homepage')),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            spacing: 16,
            children: [
              SizedBox(),
              Text('Website Formulir LDTE STEI ITB', textScaleFactor: 1.6,),
              ElevatedButton(onPressed: () => Get.toNamed('/form/pinjam'), child: Text('Pinjam Peralatan'))
            ],
          ),
        ),
      ),
    );
  }
}
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:web/web.dart' as web;
import 'package:flutter/services.dart' show rootBundle;
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

bool get canPop => Get.key.currentState?.canPop() ?? false;

extension StringExtensions on String? {
  bool isBlank() {
    return this == null || this!.trim().isEmpty;
  }
}

class FormController extends GetxController {
  final namaC = TextEditingController();
  final nimC = TextEditingController();
  final dosenC = TextEditingController();
  final nipC = TextEditingController();
  final ketuaC = TextEditingController();
  final mulaiC = TextEditingController();
  final akhirC = TextEditingController();
  final ttdC = TextEditingController();
  final barangC = <TextEditingController>[TextEditingController()].obs;
  final banyakC = <TextEditingController>[TextEditingController()].obs;
  final items = ['custom', 'Oscilloscope', 'Multimeter', 'Signal Generator'];

  final namaE = Rxn<String>(null); 
  final nimE = Rxn<String>(null); 
  final dosenE = Rxn<String>(null); 
  final nipE = Rxn<String>(null);  
  final ketuaE = Rxn<String>(null);  
  final mulaiE = Rxn<String>(null); 
  final akhirE = Rxn<String>(null); 
  final barangE = Rxn<String>(null); 
  final ttdE = Rxn<String>(null); 

  var now = DateTime.parse(DateTime.now().toString().split(' ').first);
  late var limit = now.add(Duration(days: 28)).subtract(Duration(milliseconds: 1));

  void pickDate(context, TextEditingController date) async {
    var initial = DateTime.tryParse(date.text.replaceAll('/', '-')) ?? now;

    if (initial.isBefore(now)) initial = now;
    if (initial.isAfter(limit)) initial = limit;

    var selected = await showOmniDateTimePicker(
      context: context,
      constraints: BoxConstraints(maxWidth: 350),
      firstDate: now,
      initialDate: initial,
      lastDate: limit,
      type: OmniDateTimePickerType.date,
      actionsBuilder: (a,b,c,d) => [
        MaterialButton(onPressed: a, child: Text(b)),
        MaterialButton(onPressed: () => reset(date), child: Text("Reset")),
        MaterialButton(onPressed: c, child: Text(d)),
      ]
    );
    if (selected != null) {
      date.text = selected.toString().substring(0,10).replaceAll('-', '/');
    }
  }

  void reset(TextEditingController date) {
    date.text = '';
    Get.back(closeOverlays: true);
  }

  void pinjam() async {
    final pdf = pw.Document();
    final ttf = await rootBundle.load("fonts/calibri.ttf");
    final ttfBold = await rootBundle.load("fonts/calibri-bold.ttf");
    final ttfItalic = await rootBundle.load("fonts/calibri-italic.ttf");
    final calibri = pw.Font.ttf(ttf);
    final calibriBold = pw.Font.ttf(ttfBold);
    final calibriItalic = pw.Font.ttf(ttfItalic);

    final nama = namaC.text.isBlank() ? null : namaC.text.trim();
    final nim = nimC.text.isBlank() ? null : nimC.text.trim();
    final dosen = dosenC.text.isBlank() ? null : dosenC.text.trim();
    final nip = nipC.text.isBlank() ? null : nipC.text.trim();
    final ketua = ketuaC.text.isBlank() ? null : ketuaC.text.trim();
    final mulai = mulaiC.text.isBlank() ? null
      : DateFormat('d MMMM yyyy', 'id_ID').format((DateTime.parse(mulaiC.text.replaceAll('/', '-'))));
    final akhir = akhirC.text.isBlank() ? null
      : DateFormat('d MMMM yyyy', 'id_ID').format((DateTime.parse(akhirC.text.replaceAll('/', '-'))));
    final ttd = ttdC.text.isBlank() ? null : ttdC.text.trim();
    final barang = barangC.value.map((e) => e.text.isBlank() ? "_____________________________________________________________________" : e.text.trim()).toList();
    final banyak = banyakC.value.map((e) => e.text.isBlank() ? "" : ' x' + e.text.trim()).toList();

    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.letter,
        build: (pw.Context context) {
          return pw.DefaultTextStyle(
            style: pw.TextStyle(
              font: calibri,
              fontNormal: calibri,
              fontBold: calibriBold,
              fontItalic: calibriItalic,
              fontWeight: pw.FontWeight.normal,
              fontSize: 12,
              lineSpacing: 5
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text("FORM PEMINJAMAN PERALATAN", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 5),
                      pw.Text("LABORATORIUM DASAR TEKNIK ELEKTRO", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 5),
                      pw.Text("SEKOLAH TEKNIK ELEKTRO DAN INFORMATIKA", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    ]
                  )
                ),
                pw.SizedBox(height: 22),
                pw.Text("Saya yang bertanda tangan dibawah ini:"),

                pw.SizedBox(height: 22),
                pw.Text("Nama/NIM : ${nama ?? "______________________________"} / ${nim ?? "_________________"}"),
                pw.SizedBox(height: 22),
                pw.Text("adalah mahasiswa program studi Teknik Elektro / __________  STEI ITB, dengan pembimbing:"),
                pw.SizedBox(height: 22),
                pw.Text("Dosen Pembimbing: ${dosen ?? "______________________________"}"),
                pw.SizedBox(height: 22),
                pw.Text("Hendak meminjam sejumlah peralatan dari Laboratorium Dasar Teknik Elektro STEI:"),

                pw.Padding(
                  padding: pw.EdgeInsets.only(left: 18),
                  child: pw.Table(
                    columnWidths: {
                      0: const pw.FixedColumnWidth(18),
                      1: const pw.FlexColumnWidth(),
                    },
                    children: [
                      for (int i = 0; i < barang.length; i++) ...[
                        pw.TableRow(children: [
                          pw.SizedBox(height: 5),
                        ]),
                        pw.TableRow(children: [
                          pw.Text('${i + 1}.'),
                          pw.Text('${barang[i]}${banyak[i]}'),
                        ]),
                      ]
                    ],
                  )
                ),
                
                pw.SizedBox(height: 22),

                pw.Text("Peminjaman saya lakukan mulai tanggal ${mulai ?? "_______________________"}"),
                pw.SizedBox(height: 5),
                pw.Text("dan akan dikembalikan tanggal ${akhir ?? "_____________________"}"),
                pw.SizedBox(height: 22),
                pw.Text("Saya berjanji untuk bertanggung jawab sepenuhnya terhadap barang yang saya pinjam dengan:"),
                pw.SizedBox(height: 22),
                pw.Padding(
                  padding: pw.EdgeInsets.only(left: 18),
                  child: pw.Table(
                    columnWidths: {
                      0: const pw.FixedColumnWidth(18),
                      1: const pw.FlexColumnWidth(),
                    },
                    children: [
                      pw.TableRow(children: [
                        pw.Text("1."),
                        pw.Text("Tidak menyalahgunakan peralatan tersebut, termasuk untuk kegiatan diluar akademis", textAlign: pw.TextAlign.justify),
                      ]),
                      pw.TableRow(children: [
                        pw.SizedBox(height: 5),
                      ]),
                      pw.TableRow(children: [
                        pw.Text("2."),
                        pw.Text("Mengembalikan dalam kondisi baik sebagaimana saat diterima, dan bersedia bertanggung jawab sepenuhnya terhadap segala macam kerusakan dan kehilangan.", textAlign: pw.TextAlign.justify),
                      ]),
                    ]
                  ),
                ),
                
                pw.SizedBox(height: 22),
                pw.Center(
                  child: pw.Text("Bandung, _____________________"),
                ),
                pw.SizedBox(height: 5),
                pw.Padding(
                  padding: pw.EdgeInsets.symmetric(horizontal: 57),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Peminjam,'),
                          pw.SizedBox(height: 40,),
                          pw.Text('Nama: ${nama ?? ''}'),
                          pw.SizedBox(height: 5),
                          pw.Text('NIM: ${nim ?? ''}'),
                        ]
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Dosen Pembimbing,'),
                          pw.SizedBox(height: 40,),
                          pw.Text('Nama: ${dosen ?? ''}'),
                          pw.SizedBox(height: 5),
                          pw.Text('NIP: ${nip ?? ''}'),
                        ]
                      ),
                    ]
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text("Mengetahui,"),
                      pw.SizedBox(height: 5),
                      pw.Text("Ketua Prodi ___________"),  
                      pw.SizedBox(height: 40,),
                      pw.Text("${ketua ?? "____________________"}"),
                    ],
                  ),
                ),
              ]
            ),
          );
      }));
      print(pdf);
  }

  void download(pw.Document pdf) async {
    var savedFile = await pdf.save();
    List<int> fileInts = List.from(savedFile);
    web.HTMLAnchorElement()
    ..href = "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(fileInts)}"
    ..setAttribute("download", "Form_Peminjaman_${DateTime.now().millisecondsSinceEpoch}.pdf")
    ..click();
  }

  void print(pw.Document pdf) async {
    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }
}
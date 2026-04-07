import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ldte_stei_itb/core/custom-widget.dart';
import 'package:ldte_stei_itb/core/download/save_pdf.dart';
import 'package:dropdown_flutter/custom_dropdown.dart';
import 'package:ldte_stei_itb/misc/function.dart';
import 'package:ldte_stei_itb/misc/global.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
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
  var pdf = pw.Document();

  final namaC = TextEditingController();
  final nimC = TextEditingController();
  final fakultasC = SingleSelectController<String>(null);
  final prodiC = SingleSelectController<String>(null);
  final dosenC = TextEditingController();
  final ketuaC = TextEditingController();
  final mulaiC = TextEditingController();
  final akhirC = TextEditingController();
  final ttdC = TextEditingController();
  final barangC = <TextEditingController>[TextEditingController()].obs;
  final barangDC = <SingleSelectController<String>>[SingleSelectController<String>('custom')].obs;
  final banyakC = <TextEditingController>[TextEditingController()].obs;

  final namaE = Rxn<String>(null); 
  final nimE = Rxn<String>(null); 
  final dosenE = Rxn<String>(null); 
  final ketuaE = Rxn<String>(null);  
  final mulaiE = Rxn<String>(null); 
  final akhirE = Rxn<String>(null); 
  final barangE = Rxn<String>(null); 
  final ttdE = Rxn<String>(null); 

  var prodiList = <String>[].obs;

  @override
  void onInit() async {
    super.onInit();
  }
  
  void setProdi() {
    prodiC.value = null;
    prodiList.value = getAvailableProdi(fakultasC.value);
  }

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

  Future<Uint8List> pinjam() async {
    final ttf = await rootBundle.load("fonts/calibri.ttf");
    final ttfBold = await rootBundle.load("fonts/calibri-bold.ttf");
    final ttfItalic = await rootBundle.load("fonts/calibri-italic.ttf");

    pdf = pw.Document();

    final nama = namaC.text.isBlank() ? null : namaC.text.trim();
    final nim = nimC.text.isBlank() ? null : nimC.text.trim();
    final fakultas = regexp.firstMatch(fakultasC.value ?? '')?.group(1);
    final prodi = prodiC.value?.replaceAll(RegExp(r'\((.*?)\)'), '').trim();
    final dosen = dosenC.text.isBlank() ? null : dosenC.text.trim();
    final ketua = ketuaC.text.isBlank() ? null : ketuaC.text.trim();
    final mulai = mulaiC.text.isBlank() ? null
      : DateFormat('d MMMM yyyy', 'id_ID').format((DateTime.parse(mulaiC.text.replaceAll('/', '-'))));
    final akhir = akhirC.text.isBlank() ? null
      : DateFormat('d MMMM yyyy', 'id_ID').format((DateTime.parse(akhirC.text.replaceAll('/', '-'))));
    final barang = barangC.value.map(
      (e) {
        var contain = items.where((v) => v.toLowerCase() == e.text.toLowerCase());
        return e.text.isBlank() 
          ? "_____________________________________________________________________" 
          : contain.isEmpty ? e.text.trim() : contain.first;
      }).toList();
    final banyak = banyakC.value.map((e) => e.text.isBlank() ? "" : ' x' + e.text.trim()).toList();

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.letter,
      margin: pw.EdgeInsets.fromLTRB(72, 36, 72, 36),
      footer: (context) {
        if (context.pageNumber == 1) {
          return pw.DefaultTextStyle(
            style: defaultTextStyle(ttf, ttfBold, ttfItalic, fontSize: 11),
            child: pw.Transform.translate(
              offset: PdfPoint(0, 0), 
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("Catatan:", textAlign: pw.TextAlign.justify),
                  pw.SizedBox(height: 2.0),
                  pw.Text("1. Surat pernyataan ini sekaligus sebagai tanda terima barang.", textAlign: pw.TextAlign.justify),
                  pw.SizedBox(height: 2.0),
                  pw.Text("2. Peminjam selain Prodi Teknik Elektro wajib menyertakan tanda tangan kaprodi.", textAlign: pw.TextAlign.justify),
                ]
              )
            )
          );
        } 
        return pw.Container();
      }, 
      build: (pw.Context context) => [
        pw.DefaultTextStyle(
          style: defaultTextStyle(ttf, ttfBold, ttfItalic),
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
              pw.Text("adalah mahasiswa program studi ${prodi ?? "__________"} ${fakultas ?? "__________"} ITB, dengan pembimbing:"),
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
                      pw.TableRow(children: [pw.SizedBox(height: 5)]),
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
                    pw.TableRow(children: [pw.SizedBox(height: 5)]),
                    pw.TableRow(children: [
                      pw.Text("2."),
                      pw.Text("Mengembalikan dalam kondisi baik sebagaimana saat diterima, dan bersedia bertanggung jawab sepenuhnya terhadap segala macam kerusakan dan kehilangan.", textAlign: pw.TextAlign.justify),
                    ]),
                  ]
                ),
              ),
              pw.SizedBox(height: 22),
              pw.Center(
                child: pw.Text("Bandung, ${mulai ?? "_____________________"}"),
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
                        pw.SizedBox(height: 40),
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
                        pw.Text('NIP:'),
                      ]
                    ),
                  ]
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Center(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text("Mengetahui,"),
                    pw.SizedBox(height: 5),
                    pw.Text("Ketua Prodi ${prodi ?? "__________"}"),  
                    pw.SizedBox(height: 40,),
                    pw.Container(
                      constraints: pw.BoxConstraints(minWidth: 160),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text("Nama: ${ketua ?? ""}"),
                          pw.SizedBox(height: 5),
                          pw.Text('NIP:'),
                        ]
                      ),
                    )
                  ],
                ),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.only(left :18),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.SizedBox(height: 36),
                    pw.Text("ATURAN PEMINJAMAN PERALATAN LABORATORIUM DASAR TEKNIK ELEKTRO", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 17),
                    pw.Table(
                      columnWidths: {
                        0: const pw.FixedColumnWidth(18),
                        1: const pw.FlexColumnWidth(),
                      },
                      children: [
                        pw.TableRow(children: [pw.SizedBox(height: 5)]),
                        pw.TableRow(children: [
                          pw.Text('1.'),
                          pw.Text('Peminjam adalah mahasiswa program S1 Teknik Elektro ITB, dengan rekomendasi dosen pembimbing, atau sivitas akademik lain di lingkungan STEI.'),
                        ]),
                        pw.TableRow(children: [pw.SizedBox(height: 5)]),
                        pw.TableRow(children: [
                          pw.Text('2.'),
                          pw.Text('Peminjam selain mahasiswa S1/S2 Teknik Elektro, selain menyertakan rekomendasi dosen pembimbing, juga wajib mendapatkan rekomendasi dari KaProdi bersangkutan.'),
                        ]),
                        pw.TableRow(children: [pw.SizedBox(height: 5)]),
                        pw.TableRow(children: [
                          pw.Text('3.'),
                          pw.Text('Peralatan seperti signal generator, multimeter, osciloscope, logic analyzer, spektrum analyzer, dan sejenisnya hanya boleh dipinjam dan dipergunakan di lab dasar.'),
                        ]),
                        pw.TableRow(children: [pw.SizedBox(height: 5)]),
                        pw.TableRow(children: [
                          pw.Text('4.'),
                          pw.Text('Peminjam bertanggungjawab sepenuhnya terhadap barang/peralatan yang dipinjam.'),
                        ]),
                        pw.TableRow(children: [pw.SizedBox(height: 5)]),
                        pw.TableRow(children: [
                          pw.Text('5.'),
                          pw.Text('Cara melakukan peminjaman (development kit):'),
                        ]),
                        pw.TableRow(children: [pw.SizedBox(height: 5)]),
                        pw.TableRow(children: [
                          pw.Text(''),
                          pw.Table(
                            columnWidths: {
                              0: const pw.FixedColumnWidth(18),
                              1: const pw.FlexColumnWidth(),
                            },
                            children: [
                              pw.TableRow(children: [pw.SizedBox(height: 5)]),
                              pw.TableRow(children: [
                                pw.Text('a.'),
                                pw.Text('mahasiswa menghubungi teknisi Lab Dasar untuk menanyakan ketersediaan alat.'),
                              ]),
                              pw.TableRow(children: [pw.SizedBox(height: 5)]),
                              pw.TableRow(children: [
                                pw.Text('b.'),
                                pw.Text('mahasiswa mengisi form peminjaman online dan offline serta meminta tanda tangan / rekomendasi pembimbing dan kaprodi (jika diperlukan).'),
                              ]),
                              pw.TableRow(children: [pw.SizedBox(height: 5)]),
                              pw.TableRow(children: [
                                pw.Text('c.'),
                                pw.Text('mahasiswa menyerahkan form peminjaman yang telah diisi dan ditandatangani secara lengkap kepada teknisi, dan teknisi mencocokkan identitas peminjam.'),
                              ]),
                              pw.TableRow(children: [pw.SizedBox(height: 5)]),
                              pw.TableRow(children: [
                                pw.Text('d.'),
                                pw.Text('Mahasiswa menerima peralatan yang dipinjam. Jika ingin mencoba di Lab, harus dilakukan oleh teknisi didepan peminjam.'),
                              ]),
                              pw.TableRow(children: [pw.SizedBox(height: 5)]),
                              pw.TableRow(children: [
                                pw.Text('e.'),
                                pw.Text('Pada tanggal yang ditentukan, mahasiswa mengembalikan peralatan yang dipinjam ke teknisi. Teknisi mencoba / melakukan pengetesan dan memeriksa bahwa peralatan masih dalam kondisi baik dan lengkap.'),
                              ]),
                              pw.TableRow(children: [pw.SizedBox(height: 5)]),
                              pw.TableRow(children: [
                                pw.Text('f.'),
                                pw.Text('Proses pengambilan dan pengembalian harus dilakukan oleh mahasiswa yang namanya tertera di form peminjaman.'),
                              ]),
                            ]
                          )
                        ]),
                        pw.TableRow(children: [pw.SizedBox(height: 5)]),
                        pw.TableRow(children: [
                          pw.Text('6.'),
                          pw.Text('Segala hal yang belum tercantum dalam aturan ini akan ditetapkan kemudian.'),
                        ]),
                        pw.TableRow(children: [pw.SizedBox(height: 5)]),
                        pw.TableRow(children: [
                          pw.Text('7.'),
                          pw.Text('Peserta melampirkan foto KTM dan KTP pada form ini.'),
                        ]),
                      ],
                    )
                  ]
                )
              ),
              pw.SizedBox(height: 22),
              pw.Text('Bandung, Maret 2021'),
              pw.SizedBox(height: 5),
              pw.Text('Lab Dasar Teknik Elektro'),
              pw.SizedBox(height: 5),
              pw.Text('STEI - ITB'),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(height: 36),
                  pw.Text("Lamipran", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 22),
                  pw.Text('Foto / Scan KTM :'),
                  pw.SizedBox(height: 284),
                  pw.Text('Foto / Scan KTP :'),
                ]
              )
            ]
          ),
        )
      ]
    ));
    return pdf.save();
  }

  void preview() async {
    Get.bottomSheet(
      enableDrag: false,
      isScrollControlled: true,
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
          color: appTheme.colorScheme.background,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(padding: EdgeInsets.all(8), child: Text('"Form_Peminjaman_Peralatan.pdf"')),
            Container(
              constraints: BoxConstraints(
                maxHeight: Get.height / 1.20
              ),
              height: Get.width * 1.294,
              child: PdfPreview(
                enableScrollToPage: true,
                maxPageWidth: double.infinity,
                canChangeOrientation: false,
                canChangePageFormat: false,
                canDebug: false,
                pdfFileName: "Form_Peminjaman_Peralatan-${DateTime.now().millisecondsSinceEpoch}.pdf",
                build: (PdfPageFormat format) => pinjam(),
                useActions: false,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                spacing: 8,
                children: [
                  Expanded(child: ElevatedButton(onPressed: print, child: Text('Print'), style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF8B2E3C)))),
                  Expanded(child: ElevatedButton(onPressed: download, child: Text('Download'), style: ElevatedButton.styleFrom(backgroundColor: appTheme.colorScheme.tertiary))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void download() async {
    final savedFile = await pinjam();
    final fileName = "Form_Peminjaman-${DateTime.now().millisecondsSinceEpoch}.pdf";
    await savePdf(savedFile, fileName);
  }

  void print() async {
    await Printing.layoutPdf(
      onLayout: (format) => pinjam(),
    );
  }
}
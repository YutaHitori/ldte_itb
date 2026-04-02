import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ldte_itb/core/controller.dart';
import 'package:ldte_itb/core/custom-widget.dart';
import 'package:dropdown_flutter/custom_dropdown.dart';

class Pinjam extends StatelessWidget {
  const Pinjam({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(FormController());
    return Scaffold(
      appBar: AppBar(
        leading: canPop
          ? null : IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () => Get.offNamed('/homepage'),
          ),
        title: Text('Form')
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: [
              Text('Form Peminjaman Peralatan Laboratorium Dasar Teknik Elektro Sekolah Teknik Elektro dan Informatika', textScaleFactor: 1.4),
              AutoHideTextField(
                labelText: 'Nama',
                controller: c.namaC,
                errorText: c.namaE.value,
              ),
              AutoHideTextField(
                labelText: 'Nim',
                controller: c.nimC,
                errorText: c.nimE.value,
                keyboardType: TextInputType.number,
                inputFormatters: [ FilteringTextInputFormatter.digitsOnly ],
              ),
              AutoHideTextField(
                labelText: 'Dosen',
                controller: c.dosenC,
                errorText: c.dosenE.value,
              ),
              AutoHideTextField(
                labelText: 'Nip',
                controller: c.nipC,
                errorText: c.nipE.value,
                keyboardType: TextInputType.number,
                inputFormatters: [ FilteringTextInputFormatter.digitsOnly ],
              ),
              // AutoHideTextField(
              //   labelText: 'Ketua Prodi',
              //   controller: c.ketuaC,
              //   errorText: c.ketuaE.value,
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Barang yang Dipinjam ', textScaleFactor: 1.02),
                  if (c.barangE.value != null) Text('*required', style: TextStyle(color: ColorScheme.dark().error)),
                ],
              ),
              ListView.separated(
                shrinkWrap: true,
                itemCount: c.barangC.value.length,
                separatorBuilder: (context, index) => SizedBox(height: 4),
                itemBuilder: (context, i) {
                  return Row(
                    spacing: 8,
                    children: [
                      Expanded(
                        child: DropdownFlutter<String>.search(
                          expandedHeaderPadding: EdgeInsets.only(right: 12),
                          closedHeaderPadding: EdgeInsets.only(right: 8),
                          hideSelectedFieldWhenExpanded: true,
                          listItemBuilder: (context, item, isSelected, onItemSelect) => Text(item, style: TextStyle(color: isSelected ? Colors.black : null),),
                          decoration: CustomDropdownDecoration(
                            searchFieldDecoration: SearchFieldDecoration(fillColor: appTheme.inputDecorationTheme.fillColor),
                            closedFillColor: appTheme.inputDecorationTheme.fillColor,
                            expandedFillColor: appTheme.inputDecorationTheme.fillColor,
                            closedBorder: c.barangE.value != null ? Border.all(color: appTheme.colorScheme.error) : null
                          ),
                          headerBuilder: (context, selectedItem, enabled) {
                            return TextField(
                              controller: c.barangC.value[i],
                              decoration: InputDecoration(hintText: 'Nama Barang'),
                            );
                          },
                          excludeSelected: false,
                          items: c.items,
                          initialItem: 'custom',
                          hintText: 'select',
                          onChanged: (v) {
                            var text = v == 'custom' ? '' : v;
                            c.barangC.value[i] = TextEditingController(text: text);
                          },
                        ),
                      ),
                      Text('x'),
                      SizedBox(
                        width: 48,
                        child: TextField(
                          controller: c.banyakC.value[i],
                          keyboardType: TextInputType.number,
                          inputFormatters: [ FilteringTextInputFormatter.digitsOnly ],
                          decoration: InputDecoration(hintText: 'q', contentPadding: EdgeInsets.all(6)),
                        ),
                      ),
                      GestureDetector(
                        onTap: () { 
                          c.barangC.value.removeAt(i); c.barangC.refresh(); 
                          c.banyakC.value.removeAt(i); c.banyakC.refresh(); 
                        },
                        child: Icon(Icons.delete)
                      ),
                    ],
                  );
                }
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ElevatedButton(onPressed: () {
                  c.barangC.add(TextEditingController());
                  c.banyakC.add(TextEditingController());
                }, child: Icon(Icons.add)),
              ),
              AutoHideTextField(
                labelText: 'Tanggal Pinjam',
                errorText: c.mulaiE.value,
                controller: c.mulaiC,
                keyboardType: TextInputType.datetime,
                decoration: InputDecoration(
                  hintText: 'yyyy/mm/dd',
                  suffixIcon: IconButton(onPressed: () => c.pickDate(context, c.mulaiC), icon: Icon(Icons.date_range))
                ),
                onChanged: (v) {
                  if (v.length > 10) c.mulaiC.text = v.substring(0, 10);
                },
              ),
              AutoHideTextField(
                labelText: 'Tanggal Pengembalian',
                errorText: c.akhirE.value,
                controller: c.akhirC,
                keyboardType: TextInputType.datetime,
                decoration: InputDecoration(
                  hintText: 'yyyy/mm/dd',
                  suffixIcon: IconButton(onPressed: () => c.pickDate(context, c.akhirC), icon: Icon(Icons.date_range))
                ),
                onChanged: (v) {
                  if (v.length > 10) c.akhirC.text = v.substring(0, 10);
                },
              ),
              SizedBox(height: 8,),
              ElevatedButton(onPressed: c.pinjam, child: Text('pinjam'), style: ElevatedButton.styleFrom(backgroundColor: appTheme.colorScheme.secondary)),
            ],
          )),
        ),
      ),
    ); 
  }
}
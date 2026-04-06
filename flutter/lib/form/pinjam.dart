import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dropdown_flutter/custom_dropdown.dart';
import 'package:get/get.dart';
import 'package:form_itb/misc/global.dart';
import 'package:form_itb/core/controller.dart';
import 'package:form_itb/core/custom-widget.dart';

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
            onPressed: () => Get.offNamed('/'),
          ),
        title: Text('Form Peminjaman Peralatan')
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: [
              Text('Catatan: Kosongkan kolom jika ingin diisi menggunakan menggunakan tulisan tangan',),
              AutoHideTextField(
                labelText: 'Nama',
                decoration: InputDecoration(hintText: '-'),
                controller: c.namaC,
                errorText: c.namaE.value,
              ),
              AutoHideTextField(
                labelText: 'NIM',
                decoration: InputDecoration(hintText: '-'),
                controller: c.nimC,
                errorText: c.nimE.value,
                keyboardType: TextInputType.number,
                inputFormatters: [ FilteringTextInputFormatter.allow(RegExp(r'[0-9\-\/\s]')) ],
              ),
              Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Text('Fakultas/Sekolah ', textScaleFactor: 1.02,),
                  DropdownFlutter<String>(
                    listItemBuilder: (context, item, isSelected, onItemSelect) => 
                      Text('${item}', style: TextStyle(color: item == 'reset' ? Colors.red : isSelected ? Colors.black : null)),
                    decoration: CustomDropdownDecoration(
                      expandedFillColor: appTheme.inputDecorationTheme.fillColor,
                      closedFillColor: appTheme.inputDecorationTheme.fillColor,
                      listItemStyle: TextStyle(color: Colors.black),
                    ),
                    excludeSelected: false,
                    items: ['reset', ...fakultas],
                    controller: c.fakultasC,
                    onChanged: (value) { 
                      if (value == 'reset') c.fakultasC.value = null;
                      c.setProdi(); 
                    },
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Text('Program Studi ', textScaleFactor: 1.02,),
                  DropdownFlutter<String>(
                    listItemBuilder: (context, item, isSelected, onItemSelect) => 
                      Text('${item}', style: TextStyle(color: item == 'reset' ? Colors.red : isSelected ? Colors.black : null)),
                    decoration: CustomDropdownDecoration(
                      expandedFillColor: appTheme.inputDecorationTheme.fillColor,
                      closedFillColor: appTheme.inputDecorationTheme.fillColor,
                      listItemStyle: TextStyle(color: Colors.black),
                    ),
                    excludeSelected: false,
                    items: ['reset', ...c.prodiList.value],
                    controller: c.prodiC,
                    onChanged: (value) {
                      if (value == 'reset') c.prodiC.value = null;
                    },
                  ),
                ],
              ),
              AutoHideTextField(
                labelText: 'Dosen Pembimbing',
                decoration: InputDecoration(hintText: '-'),
                controller: c.dosenC,
                errorText: c.dosenE.value,
              ),
              AutoHideTextField(
                labelText: 'Ketua Prodi',
                decoration: InputDecoration(hintText: '-'),
                controller: c.ketuaC,
                errorText: c.ketuaE.value,
              ),
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
                  var change = true;
                  return Row(
                    spacing: 8,
                    children: [
                      Expanded(
                        child: DropdownFlutter<String>.search(
                          controller: c.barangDC.value[i],
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
                              onChanged: (value) {
                                change = false;
                                var contain = items.where((v) => v.toLowerCase() == value.toLowerCase());
                                if (contain.isEmpty) {
                                  c.barangDC.value[i].value = 'custom';
                                } else c.barangDC.value[i].value = contain.first;
                                change = true;
                              },
                            );
                          },
                          excludeSelected: false,
                          items: items,
                          hintText: 'select',
                          onChanged: (v) {
                            if (!change) return;
                            var text = v;
                            if (v == 'custom') text = null;
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
                          c.barangDC.value.removeAt(i); c.barangDC.refresh(); 
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
                  c.barangDC.add(SingleSelectController<String>('custom'));
                  c.barangC.add(TextEditingController());
                  c.banyakC.add(TextEditingController());
                }, child: Icon(Icons.add), style: ElevatedButton.styleFrom(backgroundColor: appTheme.colorScheme.secondary)),
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
              SizedBox(height: 8),
              ElevatedButton(onPressed: c.preview, child: Text('Pinjam')),
            ],
          )),
        ),
      ),
    ); 
  }
}
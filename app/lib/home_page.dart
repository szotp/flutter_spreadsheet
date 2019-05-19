import 'dart:io';

import 'package:csv/csv.dart';
import 'model.dart';
import 'sheet.dart';

import 'package:flutter/material.dart';
//import 'package:menubar/menubar.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<SpreadSheetModel> future;
  SpreadSheetModel model;
  final file = File('data.csv');

  @override
  void initState() {
    super.initState();
    future = loadModel();

    // setApplicationMenu([
    //   Submenu(label: 'Data', children: [
    //     MenuItem(
    //       label: 'Clear all',
    //       onClicked: () {
    //         setState(() {
    //           model.clearAll();
    //         });
    //       },
    //     ),
    //     MenuDivider(),
    //   ])
    // ]);
  }

  Future<SpreadSheetModel> loadModelOnly() async {
    final exists = file.existsSync();

    if (exists) {
      final string = await file.readAsString();
      final csv = CsvToListConverter().convert(string);

      List<String> convert(List<dynamic> input) {
        return input.map((x) => '$x').toList();
      }

      final mapped = csv.map(convert).toList();

      return SpreadSheetModel.fromList(mapped);
    } else {
      return SpreadSheetModel(10, 100);
    }
  }

  Future<SpreadSheetModel> loadModel() async {
    model = await loadModelOnly();
    model.onChanged = saveModel;
    return model;
  }

  Future<void> saveModel() async {
    final csv = ListToCsvConverter().convert(model.cells);

    await file.writeAsString(csv);
    print('did save');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<SpreadSheetModel>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
          }

          if (!snapshot.hasData) {
            return Center(
              child: Text('LOADING'),
            );
          }

          final model = snapshot.data;
          final widths = List.filled(model.width, 150);
          return SpreadSheet(model: snapshot.data, columnWidths: widths);
        },
      ),
    );
  }
}

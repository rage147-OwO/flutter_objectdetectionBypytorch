import 'dart:io';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'model_manager.dart';
import 'RunModelByCamera.dart';

void main() {
  runApp(ModelManagementApp());
}

class ModelManagementApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Model Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ModelListScreen(),
    );
  }
}

class ModelListScreen extends StatefulWidget {
  @override
  _ModelListScreenState createState() => _ModelListScreenState();
}

class _ModelListScreenState extends State<ModelListScreen> {
  List<Model> models = [];
  final ModelManager modelManager = ModelManager();

  @override
  void initState() {
    super.initState();
    _loadModels();
  }

  void _loadModels() async {
    models = await modelManager.loadModels();
    if (models == null) {
      models = [];
    }
    setState(() {});
  }

  void _saveModels() async {
    await modelManager.saveModels(models);
  }

  void _deleteModel(int index) {
    setState(() {
      models.removeAt(index);
    });
    _saveModels();
  }

  void _addNewModelDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String name = '';
        List<String> classes = [];
        List<int> inputSize = [];
        String description = '';
        String filePath = '';

        return AlertDialog(
          title: Text('Add New Model'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(labelText: 'Name'),
                  onChanged: (value) {
                    name = value;
                  },
                ),
                TextField(
                  decoration: InputDecoration(
                      labelText: 'Classes (comma-separated)'),
                  onChanged: (value) {
                    classes = value.split(',');
                  },
                ),
                TextField(
                  decoration: InputDecoration(
                      labelText: 'Input Size (width,height)'),
                  onChanged: (value) {
                    List<String> sizes = value.split(',');
                    inputSize = sizes.map((size) =>
                    int.tryParse(size.trim()) ?? 0).toList();
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Description'),
                  onChanged: (value) {
                    description = value;
                  },
                ),
                ElevatedButton(
                  onPressed: () async {
                    FilePickerResult? result = await FilePicker.platform
                        .pickFiles();
                    Directory appDocDir = await getApplicationDocumentsDirectory();
                    File file = File(result!.files.single.path!);
                    String newPath = '${appDocDir.path}/${result.files.single
                        .name}';
                    File copiedFile = await file.copy(newPath);
                    filePath = copiedFile.path;
                  },
                  child: Text("Select model(.torchscript) file"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Model newModel = Model(
                    name, classes, inputSize, description, filePath);
                setState(() {
                  models.add(newModel);
                });
                _saveModels();
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Model List'),
        ),
        body: ListView.builder(
          itemCount: models.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(models[index].name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Classes: ${models[index].classes.join(', ')}'),
                  Text(
                      'Input Size: ${models[index].inputSize[0]}x${models[index]
                          .inputSize[1]}'),
                  Text('Class Count: ${models[index].nc}'),
                  Text('Description: ${models[index].description}'),
                  Text('File Path: ${models[index].filePath}'),
                ],
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _deleteModel(index);
                },
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RunModelByCamera(models[index]),
                  ),
                );
              },

            );
          },
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    _addNewModelDialog();
                    },
                  child: Icon(Icons.add),
                ),
              ],
            ),
          ],
        )
    );
  }
}

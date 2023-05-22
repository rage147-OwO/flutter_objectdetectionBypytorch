import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class Model {
  final String name;
  final List<String> classes;
  final List<int> inputSize;
  final int nc;
  final String description;
  String filePath;

  Model(this.name, this.classes, this.inputSize, this.description, this.filePath)
      : nc = classes.length;

  Map<String, dynamic> toJson() => {
    'name': name,
    'classes': classes,
    'inputSize': inputSize,
    'nc': nc,
    'description': description,
    'filePath': filePath,
  };

  factory Model.fromJson(Map<String, dynamic> json) {
    return Model(
      json['name'],
      List<String>.from(json['classes']),
      List<int>.from(json['inputSize']),
      json['description'],
      json['filePath'],
    );
  }
}

class ModelManager {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _modelListJsonFile async {
    final path = await _localPath;
    return File('$path/models.json');
  }

  Future<void> saveModels(List<Model> models) async {
    final file = await _modelListJsonFile;
    final jsonModels = models.map((model) => model.toJson()).toList();
    final jsonString = json.encode(jsonModels);

    // Create the file if it doesn't exist
    if (!(await file.exists())) {
      await file.create(recursive: true);
    }

    await file.writeAsString(jsonString);
  }

  Future<List<Model>> loadModels() async {
    try {
      final file = await _modelListJsonFile;
      final jsonString = await file.readAsString();
      final jsonModels = json.decode(jsonString) as List;
      return jsonModels.map((json) => Model.fromJson(json)).toList();
    } catch (e) {
      // If encountering an error, return an empty list
      return [];
    }
  }

  void deleteModelFile() async {
    final file = File('models.json');
    if (await file.exists()) {
      await file.delete();
    }
  }
  Future<void> printAllModelFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = directory.listSync();

      for (var file in files) {
        if (file is File) {
          print(path.basename(file.path));
        }
      }
    } catch (e) {
      print('Error printing model files: $e');
    }
  }
}

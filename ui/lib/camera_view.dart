import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pytorch/flutter_pytorch.dart';
import 'package:flutter_pytorch/pigeon.dart';
import 'package:path_provider/path_provider.dart';
import 'package:object_detection/model_manager.dart';
import 'camera_view_singleton.dart';

class CameraView extends StatefulWidget {
  final Function(List<ResultObjectDetection?> recognitions) resultsCallback;
  final Model model;
  const CameraView({
    required this.resultsCallback,
    required this.model,
  });
  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> with WidgetsBindingObserver {
  /// List of available cameras
  late List<CameraDescription> cameras;

  /// Controller
  CameraController? cameraController;

  /// true when inference is ongoing
  late bool predicting;

  ModelObjectDetection? _objectModel;
  @override
  void initState() {
    super.initState();
    initStateAsync();
  }


  Future loadModel() async {
    try {
      print(widget.model.filePath);
      final directory = await getApplicationDocumentsDirectory();

      print(widget.model.filePath);
      print(widget.model.nc);
      print(widget.model.inputSize[0]);
      print(widget.model.inputSize[1]);
      for (String item in widget.model.classes) {
        print(item);
      }
      _objectModel = await FlutterPytorch.loadObjectDetectionModel(
        widget.model.filePath, widget.model.nc, widget.model.inputSize[0],widget.model.inputSize[1],widget.model.classes
      );
      // ...
    } catch (e) {
      print('Error loading model: $e');
    }
  }



  void initStateAsync() async {
    WidgetsBinding.instance.addObserver(this);
    await loadModel();
    initializeCamera();
    predicting = false;
  }

  /// Initializes the camera by setting [cameraController]
  void initializeCamera() async {
    cameras = await availableCameras();

    // cameras[0] for rear-camera
    cameraController =
        CameraController(cameras[0], ResolutionPreset.high, enableAudio: false);

    cameraController?.initialize().then((_) async {
      // Stream of image passed to [onLatestImageAvailable] callback
      await cameraController?.startImageStream(onLatestImageAvailable);

      /// previewSize is size of each image frame captured by controller
      ///
      /// 352x288 on iOS, 240p (320x240) on Android with ResolutionPreset.low
      Size? previewSize = cameraController?.value.previewSize;

      /// previewSize is size of raw input image to the model
      CameraViewSingleton.inputImageSize = previewSize!;

      // the display width of image on screen is
      // same as screenWidth while maintaining the aspectRatio
      Size screenSize = MediaQuery.of(context).size;
      CameraViewSingleton.screenSize = screenSize;
      CameraViewSingleton.ratio = screenSize.width / previewSize.height;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Return empty container while the camera is not initialized
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return Container();
    }

    return CameraPreview(cameraController!);
    //return cameraController!.buildPreview();

    // return AspectRatio(
    //     // aspectRatio: cameraController.value.aspectRatio,
    //     child: CameraPreview(cameraController));
  }

  /// Callback to receive each frame [CameraImage] perform inference on it
  onLatestImageAvailable(CameraImage cameraImage) async {
    // if (classifier.interpreter != null && classifier.labels != null) {

    // If previous inference has not completed then return
    if (predicting) {
      //print("here processing");
      return;
    }

    setState(() {
      predicting = true;
    });
    if (_objectModel != null) {
      List<ResultObjectDetection?> objDetect = await _objectModel!
          .getImagePredictionFromBytesList(
              cameraImage.planes.map((e) => e.bytes).toList(),
              cameraImage.width,
              cameraImage.height,
              minimumScore: 0.3,
              IOUThershold: 0.3);

      print("data outputted $objDetect");
      widget.resultsCallback(objDetect);
    }
    // set predicting to false to allow new frames
    setState(() {
      predicting = false;
    });
    // }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.paused:
        cameraController?.stopImageStream();
        break;
      case AppLifecycleState.resumed:
        if (!cameraController!.value.isStreamingImages) {
          await cameraController?.startImageStream(onLatestImageAvailable);
        }
        break;
      default:
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    cameraController?.dispose();
    super.dispose();
  }
}



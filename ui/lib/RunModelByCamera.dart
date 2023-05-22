import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pytorch/pigeon.dart';
import 'package:path_provider/path_provider.dart';
import 'package:object_detection/model_manager.dart';
import 'package:performance/performance.dart';
import 'box_widget.dart';
import 'camera_view.dart';




class RunModelByCamera extends StatefulWidget {
  final Model model;
  RunModelByCamera(this.model);
  @override
  _RunModelByCameraState createState() => _RunModelByCameraState();
}

class _RunModelByCameraState extends State<RunModelByCamera> {
  List<ResultObjectDetection?>? results;

  @override void initState() {

    super.initState();
    _updateLabelFile();
  }

  void _updateLabelFile() async {
    final model = widget.model;
    final classes = model.classes;
    final directory = await getApplicationDocumentsDirectory();
    final labelPath = '${directory.path}/label.txt';
    final contents = classes.join('\n');

    try {
      final file = File(labelPath);

      if (!(await file.exists())) {
        await file.create(recursive: true);
      }

      await file.writeAsString(contents);
    } catch (e) {
      print('Error updating label file: $e');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomPerformanceOverlay(
        child: Stack(
        children: <Widget>[
          CameraView(
              resultsCallback:resultsCallback,
              model:widget.model),
          boundingBoxes2(results),
          Align(
            alignment: Alignment.bottomCenter,
            child: DraggableScrollableSheet(
              initialChildSize: 0.4,
              minChildSize: 0.1,
              maxChildSize: 0.5,
              builder: (_, ScrollController scrollController) => Container(
                width: double.maxFinite,
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0))),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.keyboard_arrow_up, size: 48, color: Colors.orange),
                        if (results != null)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ResultsRow(results),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      )
    );
  }

  /// Returns Stack of bounding boxes
  Widget boundingBoxes2(List<ResultObjectDetection?>? results) {
    if (results == null) {
      return Container();
    }
    return Stack(
      children: results.map((e) => BoxWidget(result: e!)).toList(),
    );
  }

  void resultsCallback(List<ResultObjectDetection?> results) {
    if (!mounted) {
      return;
    }

    setState(() {
      this.results = results;
      results.forEach((element) {
        print({
          "rect": {
            "left": element?.rect.left,
            "top": element?.rect.top,
            "width": element?.rect.width,
            "height": element?.rect.height,
            "right": element?.rect.right,
            "bottom": element?.rect.bottom,
          },
          "className": element?.className,
          "score": element?.score,
        });
      });
    });
  }


  static const BORDER_RADIUS_BOTTOM_SHEET = BorderRadius.only(
      topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0));
}

class ResultsRow extends StatelessWidget {
  final List<ResultObjectDetection?>? results;

  ResultsRow(this.results);

  @override
  Widget build(BuildContext context) {
    if (results == null) {
      return Container();
    }
    return Column(
      children: results!.map((result) {
        if (result == null) return SizedBox();
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Class: ${result.className ?? ''}'),
              Text('Score: ${result.score ?? ''}'),

            ],
          ),
        );
      }).toList(),
    );
  }
}







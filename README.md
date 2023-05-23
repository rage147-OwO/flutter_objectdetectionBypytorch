## flutter_objectdetectionBypytorch README

This repository contains the source code for the Flutter object detection app developed as part of the 2023SpringFlutter UI/UX Programming[02] Flutter App Development Project. The app allows real-time object detection using PyTorch-based models. Below is the information and instructions to understand and use the app.

### Project Overview
The aim of the project is to develop a lightweight object detection app that can be run on mobile devices using Flutter and PyTorch. The app enables users to test different object detection models in various mobile environments.

### Project Structure
The project follows a structured organization with different classes responsible for specific functionalities. Here is an overview of the main classes used:

- `MyApp`: The main class that defines the top-level widget of the app, handles screen layout, routing, and overall app functionality.
- `CameraView`: Manages the camera view and implements camera-related functionalities.
- `DetectionModel`: Implements the PyTorch-based real-time object detection model class, including model training and inference.
- `DetectionSettings`: Handles the model settings, such as model selection and input image size configuration.
- `ObjectDetectionResult`: Represents the object detection result class, containing information about the detected objects and their corresponding images.
- `ObjectDetectionView`: Displays the object detection results using the `ObjectDetectionResult` class.
- UI/UX Classes: These classes handle the necessary UI components, including buttons, images, and texts.

### Key Features
The app provides the following main features:

- Real-time frame capturing using the device's camera.
- Object detection on each captured frame.

### Team Roles and Development Timeline
The team roles and development timeline for the project are as follows:

- Team Member: 임준택 (PM, Model, App Implementation, UI)

- Development Timeline:
  - 7th Week: Program structure design and UI/UX design
  - 8-9th Weeks: Camera functionality implementation
  - 10-11th Weeks: Integration of PyTorch models
  - 12th Week: Implementation of model-specific settings UI
  - 13th Week: Implementation of model-specific settings functionality
  - 14th Week: Preparation of presentation material and report writing

### Presentation Material and Report
The project's presentation material and report can be found in the repository. Please refer to the provided links for more information.

- [Link to the Presentation Video](https://www.youtube.com/watch?v=HKiJsClo43w)

### Known Issues
There are a few known issues within the app:

- When selecting model weights that exceed 100 MB, the file copy operation may not work as expected.
- The app does not support iOS devices due to compatibility issues with the PyTorch package, as it operates using Android C++ native code.

### Expected Q&A
Here are some commonly asked questions and their corresponding answers:

- What was the most challenging part of developing the app?
  - One of the challenges was implementing file picking functionality for Android to retrieve absolute file paths. It required writing native code, and instead, the copying method was used by saving the selected file to the Appdata path.
  - Initially, the model management code was implemented using a modelInfo.txt file for each model, but it was later restructured to a different implementation.

- How were exceptions and errors handled during app development?
  - Debugging was done using Android Studio's Log for Android devices. Unfortunately, there was no direct way to debug the app in iOS devices. Dealing with unknown issues posed some challenges, as it was difficult to address them without proper debugging tools.

- What models were used for testing?
  - In the demonstration video, two YOLOv5 models

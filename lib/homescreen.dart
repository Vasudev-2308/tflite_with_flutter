// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List? _outputs;
  File? _image;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loading = true;
    loadModel().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

  loadModel() async {
    await Tflite.loadModel(
        model: 'assets/tf_lite_model.tflite',
        labels: 'assets/labels.txt',
        numThreads: 1);
  }

  classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
        path: image.path,
        imageMean: 0.0,
        imageStd: 255.0,
        numResults: 1,
        threshold: 0.2,
        asynch: true);

    setState(() {
      _loading = false;
      _outputs = output;
    });
  }

  pickImageFromCamera() async{
    var image =
        await ImagePicker.platform.pickImage(source: ImageSource.camera);
    if (image == null) return null;
    setState(() {
      _loading = true;
      _image = image as File;
    });
    classifyImage(_image!);
  }

  pickImage() async {
    var image =
        await ImagePicker.platform.pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    setState(() {
      _loading = true;
      _image = image as File;
    });
    classifyImage(_image!);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    Tflite.close();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _loading? Container(
              height: 300,
              width: 300,
            ):Container(
              margin: EdgeInsets.all(20),
              width: MediaQuery.of(context).size.width*0.8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _image == null ? Container():Image.file(_image!),
                  SizedBox(height: 20,),
                  _image == null ? Container(): _outputs != null ? Text('${_outputs?[0]["label"]}'):Text("Null")
                ],
              ),
            ),

            SizedBox(height: MediaQuery.of(context).size.height*0.01,),

            FloatingActionButton(
              tooltip: 'PickImage from Camera',
              child: Icon(Icons.camera),
              onPressed: pickImageFromCamera,
              ),

            SizedBox(height: MediaQuery.of(context).size.height*0.01,),

            FloatingActionButton(
              tooltip: 'PickImage from Camera',
              child: Icon(Icons.browse_gallery),
              onPressed: pickImage,
              ),


          ],
        ),
      ),
    );
  }
}

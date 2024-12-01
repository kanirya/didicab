import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io';

import 'dart:typed_data';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui' as ui;

import 'package:image_picker/image_picker.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

void showSnackBar(BuildContext context, String content) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(content),
    ),
  );
}

Future<File?> pickImage(BuildContext context) async {
  File? image;
  try {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      image = File(pickedImage.path);
    }
  } catch (e) {
    showSnackBar(context, e.toString());
  }
  return image;
}

class ProfileMenuWidget extends StatelessWidget {
  const ProfileMenuWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.onPress,
    this.endIcon = true,
    this.textColor,
  });

  final String title;
  final IconData icon;
  final VoidCallback onPress;
  final bool endIcon;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: ListTile(
        onTap: onPress,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: Colors.blue.withOpacity(0.1),
          ),
          child: Icon(
            icon,
            color: Colors.blueAccent,
            size: 28,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.apply(color: textColor),
        ),
        trailing: endIcon
            ? Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Colors.grey.withOpacity(0.1),
                ),
                child: const Icon(
                  LineAwesomeIcons.angle_right,
                  size: 18,
                  color: Colors.grey,
                ),
              )
            : null,
      ),
    );
  }
}




Widget textField2(
    {required String hintText,

      required TextInputType inputType,
      required TextEditingController controller}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextFormField(
      keyboardType: inputType,
      controller: controller,
      cursorColor: Colors.black,
      cursorWidth: 1,

      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400,),
      decoration: InputDecoration(
        alignLabelWithHint: true,
        border: OutlineInputBorder(
          borderSide: BorderSide(width: 1,)
        ),
        label: Text(hintText,style: TextStyle(color: Colors.black),),
        enabledBorder: OutlineInputBorder(

          borderSide: const BorderSide(color: Colors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black),
        ),
      ),
    ),
  );
}

Future<BitmapDescriptor> getBytesFromAsset(String path,int width)async{
  ByteData data=await rootBundle.load(path);
  ui.Codec codec=await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
  ui.FrameInfo fi= await codec.getNextFrame();
  final imageData= await fi.image.toByteData(format: ui.ImageByteFormat.png);
  final image=imageData?.buffer.asUint8List();
return BitmapDescriptor.fromBytes(image!);
}


Future<BitmapDescriptor> getBytesFromAsset1(String path, int width) async {
  final ByteData data = await rootBundle.load(path);
  final Codec codec = await instantiateImageCodec(
    data.buffer.asUint8List(),
    targetWidth: width,
  );
  final FrameInfo fi = await codec.getNextFrame();
  final ByteData? bytes = await fi.image.toByteData(format: ImageByteFormat.png);
  return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
}




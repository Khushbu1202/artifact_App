import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../Utilities/app_color.dart';
import '../View/ImageGeneratorAI/image_generated_view.dart';

class HandleAi extends ChangeNotifier {
  bool isLoading = false;
  bool isLoadingEdit = false;

  final String apiKey = "YOUR_API_KEY";

  bool checkEdit = false;

  final List<String> _variationList = [];
  List<String> get variationList => _variationList;

  final List<String> _editImage = [];
  List<String> get editImage => _editImage;

  String? type;

  void getVariation(String value) {
    _variationList.add(value);
    notifyListeners();
  }

  void getEditImage(String value) {
    _editImage.add(value);
    checkEdit = true;
    notifyListeners();
  }

  void getType(String value) {
    type = value;
    notifyListeners();
  }

  void clearVariations() {
    _variationList.clear();
    notifyListeners();
  }

  void clearEditImages() {
    _editImage.clear();
    checkEdit = false;
    notifyListeners();
  }

  Future<void> getImagePost(
      String text,
      String category,
      BuildContext context,
      int count, {
        String? imagePath,
      }) async {
    final bool isEdit = type == "EDIT";
    final bool isVariation = type == "VARIATION";

    if (isEdit) {
      isLoadingEdit = true;
    } else {
      isLoading = true;
    }
    notifyListeners();

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    const String apiUrl = 'https://api.stability.ai/v2beta/stable-image/generate/sd3';

    try {
      final request = http.MultipartRequest('POST', Uri.parse(apiUrl))
        ..headers['Authorization'] = 'Bearer $apiKey'
        ..fields['prompt'] = "$text, $category"
        ..fields['output_format'] = 'png'
        ..fields['model'] = 'sd3';   // ← REQUIRED for SD3

      if ((isEdit || isVariation) && imagePath != null) {
        request.files.add(await http.MultipartFile.fromPath('image', imagePath));
        request.fields['mode'] = 'image-to-image';
        request.fields['strength'] = isVariation ? '0.75' : '0.65'; // Good defaults (tune as needed)
      } else {
        request.fields['mode'] = 'text-to-image';
      }

      if (kDebugMode) {
        print('=== Stability AI Request ===');
        print('Mode: ${request.fields['mode']}');
        print('Model: ${request.fields['model']}');
        print('Strength: ${request.fields['strength']}');
        print('Prompt: ${request.fields['prompt']}');
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Uint8List imageBytes = response.bodyBytes;

        final dir = await getTemporaryDirectory();
        final filePath = '${dir.path}/generated_image_${DateTime.now().millisecondsSinceEpoch}.png';
        final file = File(filePath);
        await file.writeAsBytes(imageBytes);

        await updateUserCount(count);

        if (isVariation) {
          getVariation(filePath);
        } else if (isEdit) {
          getEditImage(filePath);
        } else {
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ImageGeneratorScreen(
                  prompt: text,
                  category: category,
                  imgUrl: filePath,
                  type: "GENERATE",
                ),
              ),
            );
          }
        }
      } else {
        String errorMessage = "Failed to generate image. Status: ${response.statusCode}";
        try {
          final errorBody = jsonDecode(response.body);
          errorMessage = errorBody['errors']?.toString() ?? errorBody.toString();
        } catch (_) {}

        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: ColorX.pinkX),
        );

        if (kDebugMode) {
          print('Stability AI Error: $errorMessage');
          print('Response Body: ${response.body}');
        }
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text("An error occurred during image generation."),
          backgroundColor: ColorX.pinkX,
        ),
      );
      if (kDebugMode) print('Exception: $e');
    } finally {
      if (isEdit) {
        isLoadingEdit = false;
      } else {
        isLoading = false;
      }
      notifyListeners();
    }
  }

  Future<void> updateUserCount(int count) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.email != null) {
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(user!.email);
      await userDocRef.update({'count': count + 1});
    }
    notifyListeners();
  }
}
// import 'dart:async';
// import 'dart:io';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:progress_border/progress_border.dart';
// import 'package:provider/provider.dart';
// import 'package:sizer/sizer.dart';
//
// import '../../Models/signinwithgoogle_model.dart';
// import '../../Provider_Data/dark_mode.dart';
// import '../../Provider_Data/handle_ai.dart';
// import '../../Utilities/app_color.dart';
// import '../../Utilities/constants.dart';
// import 'detail_image_generated_view.dart';
//
// class ImageGeneratorScreen extends StatefulWidget {
//   final String imgUrl;
//   final String prompt;
//   final String category;
//   final String? type;
//
//   const ImageGeneratorScreen({
//     super.key,
//     required this.imgUrl,
//     required this.prompt,
//     required this.category,
//     this.type,
//   });
//
//   @override
//   State<ImageGeneratorScreen> createState() => _ImageGeneratorScreenState();
// }
//
// class _ImageGeneratorScreenState extends State<ImageGeneratorScreen> {
//   late TextEditingController promptController;
//   bool load = false;
//   String checkVariation = "";
//   String checkEdit = "";
//   String? selectedImage;
//
//   UserDetails? data3;
//
//   @override
//   void initState() {
//     promptController = TextEditingController(text: widget.prompt);
//     super.initState();
//
//     // Fetch user details once
//     FirebaseAuth.instance.authStateChanges().listen((User? user) {
//       if (user?.email != null) getUserDetails(user!.email!);
//       print('data show');
//
//     });
//   }
//
//   Future<void> getUserDetails(String email) async {
//     try {
//       final doc = await FirebaseFirestore.instance.collection('users').doc(email).get();
//       if (doc.exists) {
//         data3 = UserDetails.fromJson(doc.data()!);
//         if (mounted) setState(() {});
//       }
//     } catch (e) {
//       if (kDebugMode) print('Error fetching user details: $e');
//     }
//   }
//
//   // ====================== DOWNLOAD HELPERS ======================
//
//   Future<bool> _requestPermission() async {
//     if (Platform.isIOS) {
//       return await Permission.photos.request().isGranted;
//     }
//
//     if (Platform.isAndroid) {
//       final androidInfo = await DeviceInfoPlugin().androidInfo;
//       final sdkInt = androidInfo.version.sdkInt;
//
//       if (sdkInt >= 33) { // Android 13+
//         return await Permission.photos.request().isGranted;
//       } else {
//         return await Permission.storage.request().isGranted;
//       }
//     }
//     return false;
//   }
//
//   Future<void> downloadImage(String imagePath) async {
//     setState(() => load = true);
//     final scaffoldMessenger = ScaffoldMessenger.of(context);
//
//     try {
//       if (!await _requestPermission()) {
//         scaffoldMessenger.showSnackBar(const SnackBar(
//           content: Text('Storage/Photos permission denied.'),
//           backgroundColor: ColorX.pinkX,
//         ));
//         return;
//       }
//
//       Uint8List imageBytes;
//       if (imagePath.startsWith('http')) {
//         final response = await http.get(Uri.parse(imagePath));
//         if (response.statusCode != 200) throw Exception('Failed to download image');
//         imageBytes = response.bodyBytes;
//       } else {
//         final file = File(imagePath);
//         if (!await file.exists()) throw Exception('Image file not found');
//         imageBytes = await file.readAsBytes();
//       }
//
//       final result = await ImageGallerySaverPlus.saveImage(
//         imageBytes,
//         name: 'artifect_${DateTime.now().millisecondsSinceEpoch}.jpg',
//         quality: 100,
//       );
//
//       if (result['isSuccess'] == true) {
//         scaffoldMessenger.showSnackBar(const SnackBar(
//           content: Text('Image saved to gallery'),
//           backgroundColor: ColorX.pinkX,
//         ));
//
//         // Optional: Save to app directory as well
//         final appDir = await getApplicationDocumentsDirectory();
//         final savedDir = Directory('${appDir.path}/Artifect')..createSync(recursive: true);
//         final savedPath = '${savedDir.path}/artifect_${DateTime.now().millisecondsSinceEpoch}.jpg';
//         await File(savedPath).writeAsBytes(imageBytes);
//
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => DetailImageGeneratedScreen(
//               image: savedPath,
//               type: widget.type,
//               savedImagePath: savedPath,
//             ),
//           ),
//         );
//       } else {
//         throw Exception('Failed to save image');
//       }
//     } catch (e) {
//       if (kDebugMode) print('Download error: $e');
//       scaffoldMessenger.showSnackBar(SnackBar(
//         content: Text('Failed to save image: $e'),
//         backgroundColor: ColorX.pinkX,
//       ));
//     } finally {
//       if (mounted) setState(() => load = false);
//     }
//   }
//
//   Future<void> downloadAssets(String assetPath) async {
//     setState(() => load = true);
//     final scaffoldMessenger = ScaffoldMessenger.of(context);
//
//     try {
//       final ByteData data = await DefaultAssetBundle.of(context).load(assetPath);
//       final Uint8List bytes = data.buffer.asUint8List();
//
//       final result = await ImageGallerySaverPlus.saveImage(
//         bytes,
//         name: 'artifect_${DateTime.now().millisecondsSinceEpoch}.jpg',
//       );
//
//       if (result['isSuccess'] == true) {
//         scaffoldMessenger.showSnackBar(const SnackBar(
//           content: Text('Image saved to gallery'),
//           backgroundColor: ColorX.pinkX,
//         ));
//
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => DetailImageGeneratedScreen(
//               image: assetPath,
//               type: 'ASSETS',
//               savedImagePath: result['filePath'] ?? assetPath,
//             ),
//           ),
//         );
//       }
//     } catch (e) {
//       scaffoldMessenger.showSnackBar(SnackBar(
//         content: Text('Failed to save image: $e'),
//         backgroundColor: ColorX.pinkX,
//       ));
//     } finally {
//       if (mounted) setState(() => load = false);
//     }
//   }
//
//   int _getPlanLimit(String? plan) {
//     return plan == "nothing" ? 3 : plan == "Bronze" ? 100 : plan == "Silver" ? 220 : 500;
//   }
//
//   void _showUpgradeSnackBar() {
//     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//       content: Text('Your quota has been completed. Please upgrade your plan.'),
//       backgroundColor: ColorX.pinkX,
//     ));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final themProvider = Provider.of<AppStateNotifier>(context);
//
//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: themProvider.isDarkModeOn ? ColorX.blackX : const Color(0xffebebeb),
//         appBar: PreferredSize(
//           preferredSize: Size.fromHeight(9.h),
//           child: Container(
//             decoration: BoxDecoration(
//               color: themProvider.isDarkModeOn ? ColorX.blackX : ColorX.whiteX,
//               border: Border(
//                 top: BorderSide(width: 10, color: themProvider.isDarkModeOn ? ColorX.blackX : ColorX.whiteX),
//                 bottom: BorderSide(width: 10, color: themProvider.isDarkModeOn ? ColorX.blackX : ColorX.whiteX),
//               ),
//             ),
//             child: Row(
//               children: [
//                 SizedBox(width: 5.w),
//                 themProvider.isDarkModeOn
//                     ? Image.asset('image/Group 37079.png', height: 4.h)
//                     : Image.asset('image/Group 37081.png', height: 4.h),
//               ],
//             ),
//           ),
//         ),
//         body: Consumer<HandleAi>(
//           builder: (context, model, child) {
//             return Padding(
//               padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
//               child: SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // ================== Result + Download Button ==================
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           "Result",
//                           style: GoogleFonts.lexendDeca(
//                             fontSize: 21,
//                             fontWeight: FontWeight.w600,
//                             color: themProvider.isDarkModeOn ? ColorX.whiteX : ColorX.blackX,
//                           ),
//                         ),
//                         // Download Button
//                         InkWell(
//                           onTap: () {
//                             if (checkVariation == "variation" && selectedImage != null) {
//                               downloadImage(selectedImage!);
//                             } else if (model.type == 'EDIT' || checkEdit == "Edit") {
//                               if (model.editImage.isNotEmpty) {
//                                 downloadImage(model.editImage[0]);
//                               }
//                             } else if (widget.type == "TRY") {
//                               downloadAssets(widget.imgUrl);
//                             } else {
//                               downloadImage(widget.imgUrl);
//                             }
//                           },
//                           child: Container(
//                             height: 41,
//                             width: 144,
//                             padding: const EdgeInsets.all(10),
//                             decoration: BoxDecoration(
//                               color: ColorX.pinkX,
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//                             child: load
//                                 ? const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
//                                 : const Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text(
//                                   "Download",
//                                   style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.white),
//                                 ),
//                                 Icon(Icons.file_download_outlined, color: Colors.white),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//
//                     SizedBox(height: 1.h),
//
//                     // ================== Main Image Display ==================
//                     if (checkVariation == "variation" && selectedImage != null)
//                       _buildImageWidget(selectedImage!, screenWidth, themProvider)
//                     else if (model.type == 'EDIT' || checkEdit == "Edit")
//                       model.editImage.isEmpty
//                           ? _loadingContainer(screenWidth)
//                           : _buildImageWidget(model.editImage[0], screenWidth, themProvider)
//                     else if (widget.type == "TRY")
//                         _buildAssetImage(widget.imgUrl, screenWidth, themProvider)
//                       else
//                         _buildImageWidget(widget.imgUrl, screenWidth, themProvider),
//
//                     SizedBox(height: 1.h),
//
//                     // ================== Variations List ==================
//                     if (model.variationList.isNotEmpty)
//                       SizedBox(
//                         height: 10.h,
//                         child: ListView.builder(
//                           scrollDirection: Axis.horizontal,
//                           itemCount: model.variationList.length,
//                           itemBuilder: (context, index) {
//                             final img = model.variationList[index];
//                             return InkWell(
//                               onTap: () {
//                                 setState(() {
//                                   checkVariation = "variation";
//                                   checkEdit = "";
//                                   selectedImage = img;
//                                 });
//                               },
//                               child: Padding(
//                                 padding: EdgeInsets.symmetric(horizontal: 1.w),
//                                 child: Container(
//                                   width: 22.w,
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(10),
//                                     border: index == 0 ? Border.all(color: ColorX.pinkX, width: 2) : null,
//                                   ),
//                                   child: ClipRRect(
//                                     borderRadius: BorderRadius.circular(3.w),
//                                     child: img.startsWith('http')
//                                         ? CachedNetworkImage(imageUrl: img, fit: BoxFit.cover)
//                                         : Image.file(File(img), fit: BoxFit.cover),
//                                   ),
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//
//                     SizedBox(height: 2.h),
//
//                     // ================== Action Buttons ==================
//                     Row(
//                       children: [
//                         // Variations Button
//                         Expanded(
//                           child: InkWell(
//                             onTap: () async {
//                               if (model.variationList.length >= 2) {
//                                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//                                   content: Text('In beta version only 2 variations allowed!'),
//                                 ));
//                                 return;
//                               }
//
//                               model.type = "VARIATION";
//                               model.clearEditImages();
//
//                               final limit = _getPlanLimit(data3?.plan);
//                               if (data3 != null && (data3!.count ?? 0) < limit) {
//                                 model.getImagePost(
//                                   "${promptController.text}, modern variation",
//                                   widget.category,
//                                   context,
//                                   data3!.count!,
//                                   imagePath: selectedImage ?? widget.imgUrl,
//                                 );
//                               } else {
//                                 _showUpgradeSnackBar();
//                               }
//                             },
//                             child: _buildActionButton("Variations", model.isLoading, false),
//                           ),
//                         ),
//                         SizedBox(width: 2.w),
//
//                         // Generate More Button
//                         Expanded(
//                           child: InkWell(
//                             onTap: () {
//                               model.type = "EDIT";
//                               model.clearVariations();
//
//                               final limit = _getPlanLimit(data3?.plan);
//                               if (data3 != null && (data3!.count ?? 0) < limit) {
//                                 model.getImagePost(
//                                   "${promptController.text} modern",
//                                   widget.category,
//                                   context,
//                                   data3!.count!,
//                                   imagePath: selectedImage ?? widget.imgUrl,
//                                 );
//                               } else {
//                                 _showUpgradeSnackBar();
//                               }
//                             },
//                             child: _buildActionButton("Generate More", model.isLoadingEdit, true),
//                           ),
//                         ),
//                       ],
//                     ),
//
//                     SizedBox(height: 2.h),
//
//                     // ================== Edit Idea Section ==================
//                     Row(
//                       children: [
//                         Icon(Icons.edit_outlined, color: themProvider.isDarkModeOn ? ColorX.whiteX : ColorX.blackX),
//                         SizedBox(width: 2.w),
//                         Text(
//                           "Edit Idea",
//                           style: GoogleFonts.poppins(
//                             color: themProvider.isDarkModeOn ? ColorX.whiteX : ColorX.blackX,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 1.h),
//                     Container(
//                       height: 14.h,
//                       decoration: BoxDecoration(
//                         color: themProvider.isDarkModeOn
//                             ? const Color.fromRGBO(238, 238, 238, 0.4)
//                             : const Color.fromRGBO(0, 0, 0, 0.1),
//                         borderRadius: BorderRadius.circular(10),
//                         border: Border.all(
//                           color: themProvider.isDarkModeOn
//                               ? const Color.fromRGBO(255, 255, 255, 0.2)
//                               : const Color.fromRGBO(0, 0, 0, 0.2),
//                         ),
//                       ),
//                       child: TextField(
//                         controller: promptController,
//                         maxLines: 10,
//                         cursorColor: ColorX.pinkX,
//                         style: GoogleFonts.poppins(),
//                         decoration: InputDecoration(
//                           contentPadding: EdgeInsets.only(left: 4.w, top: 1.h),
//                           border: InputBorder.none,
//                           hintText: "Describe what you want to change...",
//                           hintStyle: GoogleFonts.poppins(color: ColorX.greyX, fontSize: 12),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
//
//   Widget _buildImageWidget(String path, double screenWidth, AppStateNotifier themProvider) {
//     return Container(
//       decoration: BoxDecoration(
//         color: themProvider.isDarkModeOn ? ColorX.blackX : ColorX.whiteX,
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(3.w),
//         child: path.startsWith('http')
//             ? CachedNetworkImage(
//           imageUrl: path,
//           fit: BoxFit.fill,
//           height: 2 * (screenWidth / 2.5),
//           progressIndicatorBuilder: (context, url, progress) => Container(
//             decoration: BoxDecoration(
//               border: ProgressBorder.all(color: ColorX.pinkX, width: 4, progress: progress.progress),
//             ),
//           ),
//         )
//             : Image.file(File(path), fit: BoxFit.fill, height: 2 * (screenWidth / 2.5)),
//       ),
//     );
//   }
//
//   Widget _loadingContainer(double screenWidth) => Container(
//     height: 2 * (screenWidth / 2.5),
//     width: screenWidth,
//     decoration: BoxDecoration(border: Border.all(color: Colors.black), borderRadius: BorderRadius.circular(3.w)),
//     child: const Center(child: CircularProgressIndicator(color: ColorX.pinkX)),
//   );
//
//   Widget _buildAssetImage(String asset, double screenWidth, AppStateNotifier themProvider) {
//     return Container(
//       decoration: BoxDecoration(
//         color: themProvider.isDarkModeOn ? ColorX.blackX : ColorX.whiteX,
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: ClipRRect(borderRadius: BorderRadius.circular(3.w), child: Image.asset(asset)),
//     );
//   }
//
//   Widget _buildActionButton(String text, bool isLoading, bool isPink) {
//     return Container(
//       height: 7.h,
//       decoration: BoxDecoration(
//         color: isPink ? ColorX.pinkX : null,
//         border: isPink ? null : Border.all(color: ColorX.pinkX),
//         borderRadius: BorderRadius.circular(50.w),
//       ),
//       child: Center(
//         child: isLoading
//             ? const CircularProgressIndicator(color: Colors.white)
//             : Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             if (!isPink) Image.asset("image/refresh.png", height: 5.h),
//             if (!isPink) const SizedBox(width: 8),
//             if (isPink) const Icon(Icons.add, color: Colors.white),
//             Text(
//               text,
//               style: GoogleFonts.poppins(
//                 fontSize: 15,
//                 fontWeight: FontWeight.bold,
//                 color: isPink ? Colors.white : ColorX.pinkX,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     promptController.dispose();
//     super.dispose();
//   }
// }



import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_border/progress_border.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../Models/signinwithgoogle_model.dart';
import '../../Provider_Data/dark_mode.dart';
import '../../Provider_Data/handle_ai.dart';
import '../../Utilities/app_color.dart';
import 'detail_image_generated_view.dart';

class ImageGeneratorScreen extends StatefulWidget {
  final String imgUrl;
  final String prompt;
  final String category;
  final String? type;

  const ImageGeneratorScreen({
    super.key,
    required this.imgUrl,
    required this.prompt,
    required this.category,
    this.type,
  });

  @override
  State<ImageGeneratorScreen> createState() => _ImageGeneratorScreenState();
}

class _ImageGeneratorScreenState extends State<ImageGeneratorScreen> {
  late TextEditingController promptController;
  bool load = false;
  String? selectedImage;
  String? currentDisplayType; // "variation" or "edit"

  UserDetails? data3;

  @override
  void initState() {
    super.initState();
    promptController = TextEditingController(text: widget.prompt);

    // Fetch user details
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user?.email != null) {
        getUserDetails(user!.email!);
      }
    });
  }

  Future<void> getUserDetails(String email) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(email).get();
      if (doc.exists && mounted) {
        data3 = UserDetails.fromJson(doc.data()!);
        setState(() {});
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching user details: $e');
    }
  }

  // ====================== PERMISSION ======================
  Future<bool> _requestPermission() async {
    if (Platform.isIOS) {
      return await Permission.photos.request().isGranted;
    }

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 33) {
        return await Permission.photos.request().isGranted;
      } else {
        return await Permission.storage.request().isGranted;
      }
    }
    return false;
  }

  // ====================== DOWNLOAD ======================
  Future<void> downloadImage(String imagePath) async {
    if (load) return;
    setState(() => load = true);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      if (!await _requestPermission()) {
        scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text('Storage/Photos permission denied.'),
          backgroundColor: ColorX.pinkX,
        ));
        return;
      }

      Uint8List imageBytes;
      if (imagePath.startsWith('http')) {
        final response = await http.get(Uri.parse(imagePath));
        if (response.statusCode != 200) throw Exception('Failed to download image');
        imageBytes = response.bodyBytes;
      } else {
        final file = File(imagePath);
        if (!await file.exists()) throw Exception('Image file not found');
        imageBytes = await file.readAsBytes();
      }

      final result = await ImageGallerySaverPlus.saveImage(
        imageBytes,
        name: 'artifect_${DateTime.now().millisecondsSinceEpoch}.jpg',
        quality: 100,
      );

      if (result['isSuccess'] == true) {
        scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text('Image saved to gallery'),
          backgroundColor: ColorX.pinkX,
        ));

        // Save to app directory
        final appDir = await getApplicationDocumentsDirectory();
        final savedDir = Directory('${appDir.path}/Artifect')..createSync(recursive: true);
        final savedPath = '${savedDir.path}/artifect_${DateTime.now().millisecondsSinceEpoch}.jpg';
        await File(savedPath).writeAsBytes(imageBytes);

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetailImageGeneratedScreen(
                image: savedPath,
                type: widget.type,
                savedImagePath: savedPath,
              ),
            ),
          );
        }
      } else {
        throw Exception('Failed to save image');
      }
    } catch (e) {
      if (kDebugMode) print('Download error: $e');
      scaffoldMessenger.showSnackBar(SnackBar(
        content: Text('Failed to save image: $e'),
        backgroundColor: ColorX.pinkX,
      ));
    } finally {
      if (mounted) setState(() => load = false);
    }
  }

  Future<void> downloadAssets(String assetPath) async {
    if (load) return;
    setState(() => load = true);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final ByteData data = await DefaultAssetBundle.of(context).load(assetPath);
      final Uint8List bytes = data.buffer.asUint8List();

      final result = await ImageGallerySaverPlus.saveImage(
        bytes,
        name: 'artifect_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      if (result['isSuccess'] == true) {
        scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text('Image saved to gallery'),
          backgroundColor: ColorX.pinkX,
        ));

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailImageGeneratedScreen(
                image: assetPath,
                type: 'ASSETS',
                savedImagePath: result['filePath'] ?? assetPath,
              ),
            ),
          );
        }
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(SnackBar(
        content: Text('Failed to save image: $e'),
        backgroundColor: ColorX.pinkX,
      ));
    } finally {
      if (mounted) setState(() => load = false);
    }
  }

  int _getPlanLimit(String? plan) {
    return plan == "nothing" ? 3 : plan == "Bronze" ? 100 : plan == "Silver" ? 220 : 500;
  }

  void _showUpgradeSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Your quota has been completed. Please upgrade your plan.'),
      backgroundColor: ColorX.pinkX,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final themProvider = Provider.of<AppStateNotifier>(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: themProvider.isDarkModeOn ? ColorX.blackX : const Color(0xffebebeb),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(9.h),
          child: Container(
            decoration: BoxDecoration(
              color: themProvider.isDarkModeOn ? ColorX.blackX : ColorX.whiteX,
              border: Border(
                top: BorderSide(width: 10, color: themProvider.isDarkModeOn ? ColorX.blackX : ColorX.whiteX),
                bottom: BorderSide(width: 10, color: themProvider.isDarkModeOn ? ColorX.blackX : ColorX.whiteX),
              ),
            ),
            child: Row(
              children: [
                SizedBox(width: 5.w),
                themProvider.isDarkModeOn
                    ? Image.asset('image/Group 37079.png', height: 4.h)
                    : Image.asset('image/Group 37081.png', height: 4.h),
              ],
            ),
          ),
        ),
        body: Consumer<HandleAi>(
          builder: (context, model, child) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ================== Result + Download Button ==================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Result",
                          style: GoogleFonts.lexendDeca(
                            fontSize: 21,
                            fontWeight: FontWeight.w600,
                            color: themProvider.isDarkModeOn ? ColorX.whiteX : ColorX.blackX,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            if (currentDisplayType == "variation" && selectedImage != null) {
                              downloadImage(selectedImage!);
                            } else if (currentDisplayType == "edit" && model.editImage.isNotEmpty) {
                              downloadImage(model.editImage[0]);
                            } else if (widget.type == "TRY") {
                              downloadAssets(widget.imgUrl);
                            } else {
                              downloadImage(widget.imgUrl);
                            }
                          },
                          child: Container(
                            height: 41,
                            width: 144,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: ColorX.pinkX,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: load
                                ? const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Download",
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.white),
                                ),
                                Icon(Icons.file_download_outlined, color: Colors.white),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 2.h),

                    // ================== Main Image Display ==================
                    if (currentDisplayType == "variation" && selectedImage != null)
                      _buildImageWidget(selectedImage!, screenWidth, themProvider)
                    else if (currentDisplayType == "edit" && model.editImage.isNotEmpty)
                      _buildImageWidget(model.editImage[0], screenWidth, themProvider)
                    else if (model.variationList.isNotEmpty)
                        _buildImageWidget(model.variationList[0], screenWidth, themProvider)
                      else if (model.editImage.isNotEmpty)
                          _buildImageWidget(model.editImage[0], screenWidth, themProvider)
                        else if (widget.type == "TRY")
                            _buildAssetImage(widget.imgUrl, screenWidth, themProvider)
                          else
                            _buildImageWidget(widget.imgUrl, screenWidth, themProvider),

                    SizedBox(height: 2.h),

                    // ================== Variations List ==================
                    if (model.variationList.isNotEmpty)
                      SizedBox(
                        height: 10.h,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: model.variationList.length,
                          itemBuilder: (context, index) {
                            final img = model.variationList[index];
                            final isSelected = selectedImage == img;

                            return InkWell(
                              onTap: () {
                                setState(() {
                                  currentDisplayType = "variation";
                                  selectedImage = img;
                                });
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 1.w),
                                child: Container(
                                  width: 22.w,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: isSelected
                                        ? Border.all(color: ColorX.pinkX, width: 3)
                                        : null,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(3.w),
                                    child: img.startsWith('http')
                                        ? CachedNetworkImage(imageUrl: img, fit: BoxFit.cover)
                                        : Image.file(File(img), fit: BoxFit.cover),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                    SizedBox(height: 3.h),

                    // ================== Action Buttons ==================
                    Row(
                      children: [
                        // Variations Button
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              if (model.variationList.length >= 2) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                  content: Text('In beta version only 2 variations allowed!'),
                                ));
                                return;
                              }

                              model.type = "VARIATION";
                              model.clearEditImages();

                              final limit = _getPlanLimit(data3?.plan);
                              if (data3 != null && (data3!.count ?? 0) < limit) {
                                setState(() {
                                  currentDisplayType = null;
                                  selectedImage = null;
                                });

                                await model.getImagePost(
                                  "${promptController.text}, modern variation",
                                  widget.category,
                                  context,
                                  data3!.count!,
                                  imagePath: selectedImage ?? widget.imgUrl,
                                );

                                // Auto select first variation
                                if (model.variationList.isNotEmpty && mounted) {
                                  setState(() {
                                    currentDisplayType = "variation";
                                    selectedImage = model.variationList[0];
                                  });
                                }
                              } else {
                                _showUpgradeSnackBar();
                              }
                            },
                            child: _buildActionButton("Variations", model.isLoading, false),
                          ),
                        ),
                        SizedBox(width: 2.w),

                        // Generate More Button
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              model.type = "EDIT";
                              model.clearVariations();

                              final limit = _getPlanLimit(data3?.plan);
                              if (data3 != null && (data3!.count ?? 0) < limit) {
                                setState(() {
                                  currentDisplayType = "edit";
                                  selectedImage = null;
                                });

                                model.getImagePost(
                                  "${promptController.text} modern",
                                  widget.category,
                                  context,
                                  data3!.count!,
                                  imagePath: selectedImage ?? widget.imgUrl,
                                );
                              } else {
                                _showUpgradeSnackBar();
                              }
                            },
                            child: _buildActionButton("Generate More", model.isLoadingEdit, true),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 3.h),

                    // ================== Edit Idea Section ==================
                    Row(
                      children: [
                        Icon(Icons.edit_outlined, color: themProvider.isDarkModeOn ? ColorX.whiteX : ColorX.blackX),
                        SizedBox(width: 2.w),
                        Text(
                          "Edit Idea",
                          style: GoogleFonts.poppins(
                            color: themProvider.isDarkModeOn ? ColorX.whiteX : ColorX.blackX,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    Container(
                      height: 14.h,
                      decoration: BoxDecoration(
                        color: themProvider.isDarkModeOn
                            ? const Color.fromRGBO(238, 238, 238, 0.4)
                            : const Color.fromRGBO(0, 0, 0, 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: themProvider.isDarkModeOn
                              ? const Color.fromRGBO(255, 255, 255, 0.2)
                              : const Color.fromRGBO(0, 0, 0, 0.2),
                        ),
                      ),
                      child: TextField(
                        controller: promptController,
                        maxLines: 10,
                        cursorColor: ColorX.pinkX,
                        style: GoogleFonts.poppins(),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.only(left: 4.w, top: 1.h),
                          border: InputBorder.none,
                          hintText: "Describe what you want to change...",
                          hintStyle: GoogleFonts.poppins(color: ColorX.greyX, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildImageWidget(String path, double screenWidth, AppStateNotifier themProvider) {
    return Container(
      decoration: BoxDecoration(
        color: themProvider.isDarkModeOn ? ColorX.blackX : ColorX.whiteX,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3.w),
        child: path.startsWith('http')
            ? CachedNetworkImage(
          imageUrl: path,
          fit: BoxFit.fill,
          height: 2 * (screenWidth / 2.5),
          progressIndicatorBuilder: (context, url, progress) => Container(
            decoration: BoxDecoration(
              border: ProgressBorder.all(
                color: ColorX.pinkX,
                width: 4,
                progress: progress.progress ?? 0.0,
              ),
            ),
          ),
        )
            : Image.file(File(path), fit: BoxFit.fill, height: 2 * (screenWidth / 2.5)),
      ),
    );
  }

  Widget _buildAssetImage(String asset, double screenWidth, AppStateNotifier themProvider) {
    return Container(
      decoration: BoxDecoration(
        color: themProvider.isDarkModeOn ? ColorX.blackX : ColorX.whiteX,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3.w),
        child: Image.asset(asset, fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildActionButton(String text, bool isLoading, bool isPink) {
    return Container(
      height: 7.h,
      decoration: BoxDecoration(
        color: isPink ? ColorX.pinkX : null,
        border: isPink ? null : Border.all(color: ColorX.pinkX),
        borderRadius: BorderRadius.circular(50.w),
      ),
      child: Center(
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isPink) Image.asset("image/refresh.png", height: 5.h),
            if (!isPink) const SizedBox(width: 8),
            if (isPink) const Icon(Icons.add, color: Colors.white),
            Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isPink ? Colors.white : ColorX.pinkX,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    promptController.dispose();
    super.dispose();
  }
}
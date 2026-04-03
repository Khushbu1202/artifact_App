import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_border/progress_border.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../Provider_Data/dark_mode.dart';
import '../../Routes/roots_name.dart';
import '../../Utilities/app_color.dart';
import 'package:http/http.dart' as http;

class DetailImageGeneratedScreen extends StatefulWidget {
  final String? image;
  final String? savedImagePath;
  final String? type;

  const DetailImageGeneratedScreen({
    super.key,
    this.image,
    this.type,
    this.savedImagePath,
  });

  @override
  State<DetailImageGeneratedScreen> createState() => _DetailImageGeneratedScreenState();
}

class _DetailImageGeneratedScreenState extends State<DetailImageGeneratedScreen> {
  bool load = false;

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      return result == PermissionStatus.granted;
    }
  }

  Future<void> downloadImage(String imagePath) async {
    setState(() {
      load = true;
    });
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      await _requestPermission(Permission.storage);
      final tempDirectory = await getTemporaryDirectory();
      const fileName = 'artifect_detail.jpg';
      final newFilePath = '${tempDirectory.path}/$fileName';
      Uint8List bytes;

      // Handle URL or file path
      if (imagePath.startsWith('http')) {
        final response = await http.get(Uri.parse(imagePath));
        if (response.statusCode == 200) {
          bytes = response.bodyBytes;
          File(newFilePath).writeAsBytesSync(bytes);
        } else {
          throw Exception('Failed to download image from URL');
        }
      } else {
        bytes = await File(imagePath).readAsBytes();
        File(newFilePath).writeAsBytesSync(bytes);
      }

      final appDir = await getApplicationDocumentsDirectory();
      final gallerySubdirectory = Directory('${appDir.path}/Artifect');
      gallerySubdirectory.createSync(recursive: true);
      final savedFilePath = '${gallerySubdirectory.path}/$fileName';
      File(newFilePath).copySync(savedFilePath);

      final result = await ImageGallerySaverPlus.saveImage(bytes);
      if (result != null) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Image saved to gallery'),
            backgroundColor: ColorX.pinkX,
          ),
        );
      } else {
        if (kDebugMode) {
          print('Failed to save the image to the gallery.');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error saving image: $e'),
          backgroundColor: ColorX.pinkX,
        ),
      );
    } finally {
      setState(() {
        load = false;
      });
    }
  }

  Future<void> downloadAsset(String assetPath) async {
    setState(() {
      load = true;
    });
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final ByteData data = await DefaultAssetBundle.of(context).load(assetPath);
      final Uint8List bytes = data.buffer.asUint8List();
      final result = await ImageGallerySaverPlus.saveImage(bytes);

      if (result != null) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Image saved to gallery'),
            backgroundColor: ColorX.pinkX,
          ),
        );
      } else {
        if (kDebugMode) {
          print('Failed to save the image to the gallery.');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error saving image: $e'),
          backgroundColor: ColorX.pinkX,
        ),
      );
    } finally {
      setState(() {
        load = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print("image----->> ${widget.image}");
      print("savedImagePath------>> ${widget.savedImagePath}");
    }
    final themProvider = Provider.of<AppStateNotifier>(context);
    final double screenWidth = MediaQuery.of(context).size.width;
    final InAppReview inAppReview = InAppReview.instance;

    return SafeArea(
      child: Scaffold(
        backgroundColor: themProvider.isDarkModeOn
            ? ColorX.blackX
            : const Color.fromRGBO(225, 225, 225, 1),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(9.h),
          child: Container(
            decoration: BoxDecoration(
              color: themProvider.isDarkModeOn ? ColorX.blackX : ColorX.whiteX,
              border: Border(
                top: BorderSide(
                  width: 10,
                  color: themProvider.isDarkModeOn ? ColorX.blackX : ColorX.whiteX,
                ),
                bottom: BorderSide(
                  width: 10,
                  color: themProvider.isDarkModeOn ? ColorX.blackX : ColorX.whiteX,
                ),
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
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text(
                //   "Result",
                //   style: GoogleFonts.lexendDeca(
                //     fontSize: 21,
                //     fontWeight: FontWeight.w600,
                //     color: themProvider.isDarkModeOn ? ColorX.whiteX : ColorX.blackX,
                //   ),
                // ),
                SizedBox(height: 1.h),
                widget.image == null && widget.savedImagePath == null
                    ? Container(
                  decoration: BoxDecoration(
                    color: themProvider.isDarkModeOn ? ColorX.blackX : ColorX.whiteX,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: themProvider.isDarkModeOn ? ColorX.whiteX : ColorX.blackX,
                    ),
                  ),
                  height: 2 * (screenWidth / 2.5),
                  width: screenWidth,
                  child: const Center(
                    child: Text(
                      'No image available',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                )
                    : Container(
                  decoration: BoxDecoration(
                    color: themProvider.isDarkModeOn ? ColorX.blackX : ColorX.whiteX,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: themProvider.isDarkModeOn ? ColorX.whiteX : ColorX.blackX,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3.w),
                    child: widget.type == "ASSETS" && widget.savedImagePath != null
                        ? Image.asset(
                      widget.savedImagePath!,
                      fit: BoxFit.fill,
                      height: 2 * (screenWidth / 2.5),
                      width: screenWidth,
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Text(
                          'Failed to load asset image',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    )
                        : widget.image != null && widget.image!.startsWith('http')
                        ? CachedNetworkImage(
                      imageUrl: widget.image!,
                      fit: BoxFit.fill,
                      progressIndicatorBuilder: (context, url, downloadProgress) => Container(
                        decoration: BoxDecoration(
                          border: ProgressBorder.all(
                            color: ColorX.pinkX,
                            width: 4,
                            progress: downloadProgress.progress,
                          ),
                        ),
                      ),
                      height: 2 * (screenWidth / 2.5),
                      width: screenWidth,
                      errorWidget: (context, url, error) => const Center(
                        child: Text(
                          'Failed to load image',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    )
                        : widget.image != null
                        ? Image.file(
                      File(widget.image!),
                      fit: BoxFit.fill,
                      height: 2 * (screenWidth / 2.5),
                      width: screenWidth,
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Text(
                          'Failed to load local image',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    )
                        : const Center(
                      child: Text(
                        'No image provided',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 5.h),
                InkWell(
                  onTap: () async {
                    inAppReview.openStoreListing(
                      appStoreId: '...', // Replace with your actual app store ID
                      microsoftStoreId: 'com.logoitechbiz.artifect',
                    );
                  },
                  child: Container(
                    height: 6.h,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: ColorX.pinkX,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 0,
                          child: IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.thumb_up,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 10,
                          child: Center(
                            child: Text(
                              "Share Your Feedback!",
                              style: GoogleFonts.lexendDeca(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // SizedBox(height: 2.h),
                // InkWell(
                //   onTap: () {
                //     if (widget.image != null || (widget.type == "ASSETS" && widget.savedImagePath != null)) {
                //       if (widget.type == "ASSETS" && widget.savedImagePath != null) {
                //         downloadAsset(widget.savedImagePath!);
                //       } else {
                //         downloadImage(widget.image!);
                //       }
                //     } else {
                //       ScaffoldMessenger.of(context).showSnackBar(
                //         const SnackBar(
                //           content: Text('No image available to download'),
                //           backgroundColor: ColorX.pinkX,
                //         ),
                //       );
                //     }
                //   },
                //   child: Container(
                //     height: 6.h,
                //     width: double.infinity,
                //     decoration: BoxDecoration(
                //       color: themProvider.isDarkModeOn ? ColorX.whiteX : ColorX.blackX,
                //       borderRadius: BorderRadius.circular(2.w),
                //     ),
                //     child: Padding(
                //       padding: const EdgeInsets.all(8.0),
                //       child: Center(
                //         child: load
                //             ? const CircularProgressIndicator(color: ColorX.pinkX)
                //             : Text(
                //           "Download",
                //           style: GoogleFonts.lexendDeca(
                //             fontWeight: FontWeight.w500,
                //             fontSize: 20,
                //             color: themProvider.isDarkModeOn ? ColorX.blackX : ColorX.whiteX,
                //           ),
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                SizedBox(height: 2.h),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context, rootNavigator: true).pushNamed(RootsName.bottomBar);
                  },
                  child: Container(
                    height: 6.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: themProvider.isDarkModeOn ? ColorX.whiteX : ColorX.blackX,
                      borderRadius: BorderRadius.circular(2.w),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          "Close",
                          style: GoogleFonts.lexendDeca(
                            fontWeight: FontWeight.w500,
                            fontSize: 20,
                            color: themProvider.isDarkModeOn ? ColorX.blackX : ColorX.whiteX,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
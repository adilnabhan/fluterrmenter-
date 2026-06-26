// import 'package:mentor_mobile_app/imports_bindings.dart';
// import 'package:fc_native_video_thumbnail/fc_native_video_thumbnail.dart';

// ///
// class VideoServices {
//   ///* This constructor body for creating singleton widget
//   factory VideoServices() {
//     return _videoServices ??= VideoServices._(FcNativeVideoThumbnail());
//   }

//   //* This named constructor for create object for this class
//   VideoServices._(this._plugin);

//   //* This variable for store this class object globally
//   static VideoServices? _videoServices;

//   ///*
//   final FcNativeVideoThumbnail _plugin;

//   ///*
//   Directory? tempDir;

//   ///*
//   Future<String> getThumbnail(String path) async {
//     try {
//       final name = path.split(Platform.pathSeparator).last;
//       tempDir ??= await getTemporaryDirectory();
//       final destFile = '${tempDir?.path}/${name.split('.').first}.png';
//       if (File(destFile).existsSync()) {
//         return destFile;
//       }
//       final thumbnailGenerated = await _plugin.getVideoThumbnail(
//         srcFile: path,
//         destFile: destFile,
//         width: 300,
//         height: 300,
//         format: name.split('.').last,
//         quality: 90,
//       );
//       if (thumbnailGenerated) {
//         return destFile;
//       }
//     } catch (err) {
//       write('get Thumbnail error is : $e');
//     }
//     throw Exception("can't generate thumbnail right row.Please try again later");
//   }
// }

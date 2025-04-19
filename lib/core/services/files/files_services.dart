// import 'package:mentor_mobile_app/imports_bindings.dart';

// ///
// @immutable
// class FileServices {
//   ///* This constructor body for creating singleton widget
//   factory FileServices() {
//     return _pickFiles ??= FileServices._(ImagePicker());
//   }

//   //* This named constructor for create object for this class
//   const FileServices._(this._picker);

//   //* This variable for store this class object globally
//   static FileServices? _pickFiles;

//   ///*
//   final ImagePicker _picker;

//   ///*
//   Future<File> pickFile() async {
//     try {
//       final result = await FilePicker.platform.pickFiles();
//       if (result != null) {
//         return File(result.files.single.path!);
//       }
//     } catch (e) {
//       write('pick file error is : $e');
//     }

//     throw Exception("Can't pick file now.Please try again later.");
//   }

//   ///*
//   Future<List<File>> pickFiles() async {
//     try {
//       final result = await FilePicker.platform.pickFiles(allowMultiple: true);

//       if (result?.paths.isNotEmpty ?? false) {
//         return result!.paths.map((path) => File(path!)).toList();
//       }
//     } catch (e) {
//       write('pick files error is : $e');
//     }
//     throw Exception("Can't pick files now.Please try again later.");
//   }

//   ///*
//   Future<XFile> pickImage(ImageSource source) async {
//     try {
//       final result = await _picker.pickImage(source: source);

//       if (result != null) {
//         return result;
//       }
//     } catch (e) {
//       write('pick image error is : $e');
//     }

//     throw Exception("Can't pick Image now.Please try again later.");
//   }

//   ///*
//   Future<List<XFile>> pickImages() async {
//     try {
//       final result = await _picker.pickMultiImage();

//       if (result.isEmpty) {
//         return result;
//       }
//     } catch (e) {
//       write('pick images error is : $e');
//     }

//     throw Exception("Can't pick Images now.Please try again later.");
//   }

//   ///*
//   Future<XFile> pickVideo(ImageSource source) async {
//     try {
//       final result = await _picker.pickVideo(source: source);

//       if (result != null) {
//         return result;
//       }
//     } catch (e) {
//       write('pick video error is : $e');
//     }

//     throw Exception("Can't pick video now.Please try again later.");
//   }

//   ///*
//   Future<List<XFile>> pickVideos() async {
//     try {
//       final result = await _picker.pickMultipleMedia();

//       if (result.isNotEmpty) {
//         return result;
//       }
//     } catch (e) {
//       write('pick videos error is : $e');
//     }

//     throw Exception("Can't pick videos now.Please try again later.");
//   }
// }

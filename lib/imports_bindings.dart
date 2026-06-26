//*================[ app sources ]=============================//

export 'core/core.dart';
export 'src/src.dart';
export 'bootstrap.dart';

//*================[ internal packages  ]=============================//

export 'dart:async';
export 'dart:convert';
export 'dart:io';
export 'dart:math';
import 'dart:developer' as dev;

//*================[ external packages ]=============================//

//* Core

//* Code Generation
export 'package:freezed_annotation/freezed_annotation.dart';
export 'package:json_annotation/json_annotation.dart';

//* State Management
export 'package:bloc/bloc.dart';
export 'package:flutter_bloc/flutter_bloc.dart';
export 'package:hydrated_bloc/hydrated_bloc.dart';

///* Utils
export 'package:intl/intl.dart' show DateFormat, NumberFormat;

//* User Interface
export 'package:cached_network_image/cached_network_image.dart';
export 'package:dio/dio.dart'
    show Dio, DioException, FormData, MultipartFile, Options;
export 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
export 'package:flutter/foundation.dart' hide Category;
export 'package:flutter/material.dart';
export 'package:flutter/rendering.dart';
export 'package:flutter/services.dart';
export 'package:flutter_svg/flutter_svg.dart';
export 'package:internet_connection_checker/internet_connection_checker.dart';
export 'package:package_info_plus/package_info_plus.dart';
export 'package:pinput/pinput.dart';
export 'package:shimmer/shimmer.dart';
export 'package:sms_autofill/sms_autofill.dart'
    show CodeAutoFill, PinFieldAutoFill, SmsAutoFill, TextFieldPinAutoFill;
// export 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
//export 'package:file_picker/file_picker.dart';
export 'package:image_picker/image_picker.dart';
export 'package:path_provider/path_provider.dart';
// export 'package:awesome_notifications/awesome_notifications.dart';
// export 'package:firebase_core/firebase_core.dart';
export 'package:permission_handler/permission_handler.dart';
// export 'package:firebase_messaging/firebase_messaging.dart';
export 'package:percent_indicator/percent_indicator.dart';
export 'package:url_launcher/url_launcher.dart';
export 'package:carousel_slider/carousel_slider.dart';
export 'package:fpdart/fpdart.dart'
    show Either, Left, None, Option, Right, Some, left, none, right, some;
export 'package:feggy_core/feggy_core.dart';
export 'package:easy_debounce/easy_debounce.dart';
export 'package:flutter_spinkit/flutter_spinkit.dart';
export 'package:widget_to_marker/widget_to_marker.dart';

export 'package:google_maps_flutter/google_maps_flutter.dart';
// export 'package:firebase_crashlytics/firebase_crashlytics.dart';
export 'package:flutter_animate/flutter_animate.dart';
export 'package:dotted_line/dotted_line.dart';

export 'package:flutter_dotenv/flutter_dotenv.dart';

// Payment
export 'package:razorpay_flutter/razorpay_flutter.dart';

//*================[ Methods ]=====================================//

//!----------------[ This method for console log ]------------
/// For console log
void write(
  String text, {
  DateTime? time,
  int? sequenceNumber,
  int level = 0,
  String name = '',
  Object? error,
  StackTrace? stackTrace,
}) => dev.log(
  text,
  error: error,
  level: level,
  name: name,
  sequenceNumber: sequenceNumber,
  stackTrace: stackTrace,
  time: time,
);
//!-----------------------------------------------------------

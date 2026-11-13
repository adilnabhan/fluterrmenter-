import 'dart:io';
import 'package:flutter/foundation.dart';

final platformSource = kIsWeb
    ? 'mentor-app-web'
    : (Platform.isAndroid ? 'mentor-app-android' : 'mentor-app-ios');

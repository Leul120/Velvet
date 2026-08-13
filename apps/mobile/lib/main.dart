import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velvet_mobile/app.dart';
import 'package:velvet_mobile/core/push/push_registration.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (FcmPushTokenSource.enabled) {
    await Firebase.initializeApp();
  }
  runApp(const ProviderScope(child: VelvetApp()));
}

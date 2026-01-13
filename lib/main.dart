import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:grampulse/app/app.dart';
import 'package:grampulse/core/config/web3_config.dart';
import 'package:grampulse/core/services/supabase_service.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Web3 configuration (loads .env)
  await Web3Config.initialize();
  
  // Initialize Supabase
  await SupabaseService().initialize();
  
  // Initialize Hive for local storage
  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);
  
  // Initialize SharedPreferences for token storage
  await SharedPreferences.getInstance();
  
  // Set status bar color
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );
  
  runApp(const App());
}

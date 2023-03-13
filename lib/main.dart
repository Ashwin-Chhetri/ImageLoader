import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:imageloader/app.dart';
import 'package:imageloader/provider/category_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => CategoryProvider()),
    ], child: const MyApp()),
  );
}

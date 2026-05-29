import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:rustinnovations_adminpanel/Assets/Colors.dart';
import 'package:flutter_web_plugins/url_strategy.dart'; // add this import
import 'package:supabase_flutter/supabase_flutter.dart';
import 'Widgets/route.dart';


void main()async {

  WidgetsFlutterBinding.ensureInitialized();
  if(kIsWeb) SemanticsBinding.instance.ensureSemantics();

  usePathUrlStrategy();

  await Supabase.initialize(
      url: 'https://qyjvjqfzwyvhqkqkejxd.supabase.co',
      anonKey: 'sb_publishable_4ZUE038KeN-POPssv10uXg_QHpQiJxl',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'RustInnovations',
      supportedLocales: const [Locale('en', "US")],
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: MyColors.PRIMARY_COLOR),
      ),
      routerConfig: route,

    );
  }
}


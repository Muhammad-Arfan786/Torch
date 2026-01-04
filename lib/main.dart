import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'services/torch_service.dart';
import 'services/shake_detection_service.dart';
import 'services/compass_service.dart';
import 'services/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize settings before app starts
  final settingsService = SettingsService();
  await settingsService.loadSettings();

  runApp(MyApp(settingsService: settingsService));
}

class MyApp extends StatelessWidget {
  final SettingsService settingsService;

  const MyApp({super.key, required this.settingsService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settingsService),
        ChangeNotifierProvider(create: (_) => TorchService()),
        ChangeNotifierProvider(create: (_) => CompassService()..initialize()),
        ChangeNotifierProvider(create: (_) => ShakeDetectionService()),
      ],
      child: const TorchApp(),
    );
  }
}

class TorchApp extends StatefulWidget {
  const TorchApp({super.key});

  @override
  State<TorchApp> createState() => _TorchAppState();
}

class _TorchAppState extends State<TorchApp> {
  @override
  void initState() {
    super.initState();
    // Connect shake detection to torch service after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupShakeDetection();
    });
  }

  void _setupShakeDetection() {
    final shakeService = context.read<ShakeDetectionService>();
    final torchService = context.read<TorchService>();
    final settingsService = context.read<SettingsService>();

    // Connect shake callback to torch toggle
    shakeService.onShakeDetected = () {
      torchService.toggleTorch();
    };

    // Apply settings
    shakeService.setSensitivity(settingsService.shakeSensitivity);
    if (settingsService.shakeEnabled) {
      shakeService.startListening();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Torch - Flashlight',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: const Color.fromARGB(255, 163, 130, 80),
          secondary: Colors.orangeAccent,
          surface: Colors.grey[900]!,
        ),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      ),
      home: const HomeScreen(),
    );
  }
}

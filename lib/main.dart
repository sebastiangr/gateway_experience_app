import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';
import 'providers/audio_player_provider.dart';
import 'providers/track_library_provider.dart';
import 'screens/library_screen.dart';
import 'utils/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required for plugins

  // Initialize just_audio_background
  // await JustAudioBackground.init(
  //   androidNotificationChannelId: 'com.mycompany.myapp.channel.audio',
  //   androidNotificationChannelName: 'Gateway Audio Playback',
  //   androidNotificationOngoing: true,
  //   androidStopForegroundOnPause: true, // Keep service running but remove notification on pause
  //   notificationColor: AppColors.mintGreen, // Optional: notification accent color
  // );

  // Set preferred orientations (optional, good for consistency)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Customize system UI overlay style (status bar, navigation bar)
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // Make status bar transparent
    statusBarIconBrightness: Brightness.light, // For dark backgrounds
    systemNavigationBarColor: AppColors.darkBlue, // Match your app's nav bar color
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TrackLibraryProvider()),
        ChangeNotifierProvider(create: (_) => AudioPlayerProvider()),
        // Add PermissionProvider if you make one
      ],
      child: MaterialApp(
        title: 'Gateway Experience Player',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // We are aiming for a custom look, so primary interaction colors are
          // often defined directly on widgets or via AppColors.
          // However, some base themeing is useful.
          scaffoldBackgroundColor: AppColors.darkBlue, // Default background
          fontFamily: 'Roboto', // Or any preferred font (add to pubspec and assets)
          // Override text styles if needed, but often done per widget for custom UI
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: AppColors.lightGray),
            bodyMedium: TextStyle(color: AppColors.lightGray),
            titleLarge: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
          ),
          // Define icon theme globally if desired
          iconTheme: const IconThemeData(color: AppColors.lightGray),
          // Remove Android's overscroll glow
          scrollbarTheme: ScrollbarThemeData(
            thumbVisibility: WidgetStateProperty.all(true),
            thickness: WidgetStateProperty.all(6),
            thumbColor: WidgetStateProperty.all(AppColors.mintGreen.withOpacity(0.7)),
            radius: const Radius.circular(10),
          )
        ),
        home: const LibraryScreen(),
      ),
    );
  }
}
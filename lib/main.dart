import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sizer/sizer.dart'; 
import 'package:google_fonts/google_fonts.dart';
import 'data/models/anime_model.dart';
import 'data/repositories/anime_repository.dart';
import 'logic/cubit/favorite_cubit.dart';
import 'logic/cubit/top_anime_cubit.dart';
import 'presentation/navigation/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  await Hive.initFlutter();
  Hive.registerAdapter(AnimeModelAdapter()); 
  await Hive.openBox<AnimeModel>('favorites'); 

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => AnimeRepository(),
      child: MultiBlocProvider( 
        providers: [
          BlocProvider(
            create: (context) => TopAnimeCubit(
              context.read<AnimeRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => FavoriteCubit()
              ..loadFavorites(),
          ),
        ],
        
        child: Sizer( // <-- BUNGKUS DENGAN SIZER
          builder: (context, orientation, deviceType) {
            final colorScheme = ColorScheme.fromSeed(
              seedColor: const Color(0xFF22D3EE), // cyan accent
              brightness: Brightness.dark,
            );

            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: 'Streamime',
              theme: ThemeData(
                useMaterial3: true,
                colorScheme: colorScheme,
                scaffoldBackgroundColor: const Color(0xFF0B1120), // deep night blue
                visualDensity: VisualDensity.adaptivePlatformDensity,
                pageTransitionsTheme: const PageTransitionsTheme(
                  builders: {
                    TargetPlatform.android: ZoomPageTransitionsBuilder(),
                    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                    TargetPlatform.linux: ZoomPageTransitionsBuilder(),
                    TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
                    TargetPlatform.windows: ZoomPageTransitionsBuilder(),
                    TargetPlatform.fuchsia: ZoomPageTransitionsBuilder(),
                  },
                ),
                appBarTheme: AppBarTheme(
                  backgroundColor: const Color(0xFF0F172A),
                  elevation: 0,
                  centerTitle: true,
                  surfaceTintColor: Colors.transparent,
                  iconTheme: IconThemeData(color: colorScheme.onSurface),
                  titleTextStyle: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                cardTheme: CardThemeData(
                  color: const Color(0xFF111827),
                  elevation: 2,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                textTheme: GoogleFonts.poppinsTextTheme()
                    .apply(
                      bodyColor: colorScheme.onSurface,
                      displayColor: colorScheme.onSurface,
                    ),
                inputDecorationTheme: InputDecorationTheme(
                  filled: true,
                  fillColor: Colors.white10,
                  hintStyle: const TextStyle(color: Colors.white70),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 1.6.h,
                    horizontal: 1.6.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide(color: colorScheme.secondary, width: 1.5),
                  ),
                ),
                chipTheme: ChipThemeData(
                  backgroundColor: colorScheme.secondary.withValues(alpha: 0.12),
                  labelStyle: TextStyle(
                    color: colorScheme.onSecondary,
                    fontSize: 11.sp,
                  ),
                  shape: const StadiumBorder(),
                  side: BorderSide.none,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                ),
                dividerTheme: const DividerThemeData(
                  color: Colors.white24,
                  thickness: 1,
                ),
                snackBarTheme: SnackBarThemeData(
                  backgroundColor: const Color(0xFF111827),
                  contentTextStyle: TextStyle(color: colorScheme.onSurface),
                  behavior: SnackBarBehavior.floating,
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                iconButtonTheme: IconButtonThemeData(
                  style: IconButton.styleFrom(
                    foregroundColor: colorScheme.onSurface,
                  ),
                ),
                progressIndicatorTheme: ProgressIndicatorThemeData(
                  color: colorScheme.secondary,
                ),
                listTileTheme: ListTileThemeData(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                bottomNavigationBarTheme: BottomNavigationBarThemeData(
                  backgroundColor: const Color(0xFF0B1120),
                  selectedItemColor: colorScheme.secondary,
                  unselectedItemColor: Colors.white70,
                  elevation: 8,
                  type: BottomNavigationBarType.fixed,
                  showUnselectedLabels: false,
                ),
              ),
              routerConfig: appRouter,
            );
          },
        ),
      ),
    );
  }
}

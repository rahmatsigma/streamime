import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sizer/sizer.dart'; 
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
            return MaterialApp.router(
              debugShowCheckedModeBanner: false, 
              title: 'Streamime',
              theme: ThemeData(
                primarySwatch: Colors.cyan,
                brightness: Brightness.dark,
              ),
              routerConfig: appRouter, 
            );
          },
        ),
      ),
    );
  }
}
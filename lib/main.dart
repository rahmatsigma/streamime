import 'package:manga_read/features/home/data/repositories/i_manga_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:manga_read/core/app_router.dart';
import 'package:manga_read/features/home/data/repositories/manga_repository_impl.dart';
import 'package:manga_read/features/home/logic/manga_list_cubit.dart';
import 'package:sizer/sizer.dart';

void main() {
  final IMangaRepository mangaRepository = MangaRepositoryImpl();

  runApp(
    BlocProvider(
      create: (context) => MangaListCubit(mangaRepository),
      child: const MangaReadApp(),
    ),
  );
}

class MangaReadApp extends StatelessWidget {
  const MangaReadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'MangaRead',
          theme: ThemeData.dark(),
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}

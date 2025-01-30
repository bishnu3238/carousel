import 'package:carousel/features/edit_wallpaper/core/edit_wallpaper_provider.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/full_image_view/core/full_image_view_provider.dart';
import '../../features/settings/core/settings_provider.dart';
import '../../theme/theme_manager.dart';
import '../data/datasources/wallpaper_local_datasource.dart';
import '../data/datasources/wallpaper_local_datasource_impl.dart';
import '../data/datasources/wallpaper_remote_datasource.dart';
import '../data/repositories/wallpaper_repository_impl.dart';
import '../domain/repositories/wallpaper_repository.dart';
import '../domain/usecases/add_wallpaper_usecase.dart';
import '../domain/usecases/get_wallpaper_usecase.dart';
import '../domain/usecases/wallpaper_usecase.dart';
import '../services/image_click_service.dart';
import '../services/platform_service.dart';
import '../state/image_selection_state.dart';
import '../state/wallpaper_provider.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  final ImagePicker picker = ImagePicker();
  final sharedPreferences = await SharedPreferences.getInstance();
  //
  sl.registerLazySingleton(() => sharedPreferences);
  // Service
  sl.registerLazySingleton(() => PlatformService());
  sl.registerLazySingleton(() => ImageClickService(picker: picker));
  sl.registerLazySingleton<ThemeManager>(() => ThemeManager());
  // Data sources
  sl.registerLazySingleton<WallpaperLocalDataSource>(
      () => WallpaperLocalDataSourceImpl(sharedPreferences: sl()));
  sl.registerLazySingleton<WallpaperRemoteDataSource>(
      () => WallpaperRemoteDataSourceImpl());

  // Repository
  sl.registerLazySingleton<WallpaperRepository>(
      () => WallpaperRepositoryImpl(localDataSource: sl(), remoteDataSource: sl()));
  // Use Cases
  sl.registerLazySingleton(() => WallpaperUseCase(repository: sl()));
  sl.registerLazySingleton(() => AddWallpaperUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetWallpaperUseCase(repository: sl()));

  //Provider
  sl.registerLazySingleton(() => WallpaperProvider());
  sl.registerLazySingleton(() => ImageSelectionState(sharedPreferences: sl()));

  sl.registerLazySingleton(() => SettingsProvider());
  sl.registerLazySingleton(() => FullImageViewProvider());

  sl.registerLazySingleton(() => EditWallpaperProvider(
        sl<ImageClickService>(),
        sl<WallpaperUseCase>(),
        imageSelectionState: sl<ImageSelectionState>(),
        wallpaperProvider: sl<WallpaperProvider>(),
      ));
}

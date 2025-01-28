import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/carousel/data/datasources/wallpaper_local_datasource.dart';
import '../../features/carousel/data/datasources/wallpaper_remote_datasource.dart';
import '../../features/carousel/data/repositories/wallpaper_repository_impl.dart';
import '../../features/carousel/domain/repositories/wallpaper_repository.dart';
import '../../features/carousel/domain/usecases/wallpaper_usecase.dart';
import '../../features/carousel/presentation/state/home_provider.dart';
import '../../features/carousel/presentation/state/image_selection_state.dart';
import '../../features/carousel/presentation/state/settings_provider.dart';
import '../../theme/theme_manager.dart';
import '../services/image_click_service.dart';
import '../services/platform_service.dart';
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

  //Provider
  sl.registerLazySingleton(() => WallpaperProvider());
  sl.registerLazySingleton(() => HomePageProvider());
  sl.registerLazySingleton(() => ImageSelectionState(sharedPreferences: sl()));
  sl.registerLazySingleton(() => SettingsProvider());
}

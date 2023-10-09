import 'package:admin_panel/services/backend/data_service.dart';
import 'package:admin_panel/services/providers/base_provider.dart';
import 'package:admin_panel/services/providers/block_provider.dart';
import 'package:admin_panel/services/providers/playlist_provider.dart';
import 'package:admin_panel/services/providers/ringtones_provider.dart';
import 'package:get_it/get_it.dart';

final locator = GetIt.instance;

void setupLocator() {
  locator.registerSingleton<BaseProvider>(BaseProvider());
  locator.registerSingleton<BlockProvider>(BlockProvider());
  locator.registerSingleton<PlaylistProvider>(PlaylistProvider());
  locator.registerSingleton<RingtonesProvider>(RingtonesProvider());
  locator.registerSingleton<DataService>(DataService());

}
import 'package:bloc/bloc.dart';
import '../../../../core/data/hive_database.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  static const String _profileKey = 'profileImagePath';
  static const String _coverKey = 'coverImagePath';

  SettingsBloc() : super(const SettingsState()) {
    on<LoadSettingsEvent>(_onLoad);
    on<UpdateImageEvent>(_onUpdateImage);
  }

  Future<void> _onLoad(
      LoadSettingsEvent event, Emitter<SettingsState> emit) async {
    try {
      final box = HiveDatabase.settingsBox;
      final profile = box.get(_profileKey) as String?;
      final cover = box.get(_coverKey) as String?;
      emit(SettingsState(profileImagePath: profile, coverImagePath: cover));
    } catch (e) {
      emit(SettingsState(error: e.toString()));
    }
  }

  Future<void> _onUpdateImage(
      UpdateImageEvent event, Emitter<SettingsState> emit) async {
    try {
      final box = HiveDatabase.settingsBox;
      if (event.profileImagePath != null) {
        await box.put(_profileKey, event.profileImagePath);
      }
      if (event.coverImagePath != null) {
        await box.put(_coverKey, event.coverImagePath);
      }
      final profile = box.get(_profileKey) as String?;
      final cover = box.get(_coverKey) as String?;
      emit(SettingsState(profileImagePath: profile, coverImagePath: cover));
    } catch (e) {
      emit(SettingsState(error: e.toString()));
    }
  }
}

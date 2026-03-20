import 'package:equatable/equatable.dart';

class SettingsState extends Equatable {
  final String? profileImagePath;
  final String? coverImagePath;
  final bool loading;
  final String? error;

  const SettingsState(
      {this.profileImagePath,
      this.coverImagePath,
      this.loading = false,
      this.error});

  SettingsState copyWith(
      {String? profileImagePath,
      String? coverImagePath,
      bool? loading,
      String? error}) {
    return SettingsState(
      profileImagePath: profileImagePath ?? this.profileImagePath,
      coverImagePath: coverImagePath ?? this.coverImagePath,
      loading: loading ?? this.loading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [profileImagePath, coverImagePath, loading, error];
}

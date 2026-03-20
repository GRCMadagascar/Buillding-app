import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override
  List<Object?> get props => [];
}

class LoadSettingsEvent extends SettingsEvent {}

class UpdateImageEvent extends SettingsEvent {
  final String? profileImagePath;
  final String? coverImagePath;

  const UpdateImageEvent({this.profileImagePath, this.coverImagePath});

  @override
  List<Object?> get props => [profileImagePath, coverImagePath];
}

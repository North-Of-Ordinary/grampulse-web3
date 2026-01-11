import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:grampulse/features/report/domain/models/updated_report_models.dart';

abstract class CaptureMediaEvent extends Equatable {
  const CaptureMediaEvent();

  @override
  List<Object?> get props => [];
}

class InitializeCamera extends CaptureMediaEvent {
  const InitializeCamera();
}

class ToggleFlash extends CaptureMediaEvent {
  const ToggleFlash();
}

class CaptureImage extends CaptureMediaEvent {
  const CaptureImage();
}

class SelectFromGallery extends CaptureMediaEvent {
  const SelectFromGallery();
}

class AddMedia extends CaptureMediaEvent {
  final File file;
  final MediaType type;

  const AddMedia({
    required this.file,
    required this.type,
  });

  @override
  List<Object?> get props => [file.path, type];
}

class RemoveMedia extends CaptureMediaEvent {
  final String mediaId;

  const RemoveMedia({required this.mediaId});

  @override
  List<Object?> get props => [mediaId];
}

class StartVoiceRecording extends CaptureMediaEvent {
  const StartVoiceRecording();
}

class StopVoiceRecording extends CaptureMediaEvent {
  const StopVoiceRecording();
}

class RefreshLocation extends CaptureMediaEvent {
  const RefreshLocation();
}

class ValidateAndProceed extends CaptureMediaEvent {
  const ValidateAndProceed();
}

class DisposeCamera extends CaptureMediaEvent {
  const DisposeCamera();
}
